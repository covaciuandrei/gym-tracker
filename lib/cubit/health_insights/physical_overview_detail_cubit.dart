import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline.dart';
import 'package:gym_tracker/model/health_insights/population_physical_comparison.dart';
import 'package:gym_tracker/model/health_insights/timeline_range.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/health_insights/metric_timeline_builder.dart';
import 'package:gym_tracker/service/health_insights/population_comparison_analyzer.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:injectable/injectable.dart';

part 'physical_overview_detail_states.dart';

/// Drives `PhysicalOverviewDetailPage`: loads weight / lean-mass / height /
/// age / sex fresh (bounded to the reporting window), computes the
/// population comparison, and aggregates weight + lean-mass into monthly
/// series for past-you mode's charts.
///
/// Deliberately its own cubit rather than reusing [HealthInsightsResult]:
/// this page opens from a card tap, well after the main page's load, so a
/// fresh (fast, bounded) fetch here is simpler than threading extra state
/// through the main result just for this one entry point.
@injectable
class PhysicalOverviewDetailCubit extends BaseCubit {
  PhysicalOverviewDetailCubit(this._repository, this._userService, this._authService, this._timelineBuilder, this._populationComparisonAnalyzer);

  final HealthRepository _repository;
  final UserService _userService;
  final AuthService _authService;
  final MetricTimelineBuilder _timelineBuilder;
  final PopulationComparisonAnalyzer _populationComparisonAnalyzer;

  Future<void> load() async {
    safeEmit(const PendingState());
    try {
      final userId = _authService.currentUserId;
      final user = userId != null ? await _userService.getById(userId: userId) : null;
      final characteristics = await _repository.characteristics();

      final sex = user?.sex ?? characteristics?.sex;
      final birthDate = user?.birthDate ?? characteristics?.birthDate;
      final age = birthDate != null ? _ageFrom(birthDate) : null;

      final from = MetricTimelineBuilder.reportingWindowStart();
      final weightSamples = await _repository.samples(HealthMetric.bodyMass, from: from);
      final leanSamples = await _repository.samples(HealthMetric.leanBodyMass, from: from);
      final heightSamples = await _repository.samples(HealthMetric.height);

      final heightCm = user?.heightCm ?? (heightSamples.isNotEmpty ? heightSamples.last.value : null);
      final weightKg = weightSamples.isNotEmpty ? weightSamples.last.value : user?.weightKg;

      double? bodyFatPercent;
      if (weightKg != null && leanSamples.isNotEmpty) {
        bodyFatPercent = (weightKg - leanSamples.last.value) / weightKg * 100;
      }

      final comparison = _populationComparisonAnalyzer.build(
        weightKg: weightKg,
        heightCm: heightCm,
        age: age,
        sex: sex,
        bodyFatPercent: bodyFatPercent,
      );

      DateTime? earliest;
      if (weightSamples.isNotEmpty) {
        earliest = weightSamples.map((s) => s.dateFrom).reduce((a, b) => a.isBefore(b) ? a : b);
      }
      final ranges = earliest != null ? _timelineBuilder.availableRanges(earliestDataDate: earliest) : const <TimelineRange>[];

      safeEmit(
        PhysicalOverviewDetailReadyState(
          comparison: comparison,
          weightPoints: _timelineBuilder.buildMonthlyPoints(weightSamples),
          leanMassPoints: _timelineBuilder.buildMonthlyPoints(leanSamples),
          availableRanges: ranges,
        ),
      );
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  int _ageFrom(DateTime birthDate) {
    final now = DateTime.now();
    var age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}
