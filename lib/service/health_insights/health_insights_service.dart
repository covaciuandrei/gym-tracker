import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/model/health_insights/body_composition_trend.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_insights_result.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/physical_overview.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/health_insights/body_composition_analyzer.dart';
import 'package:gym_tracker/service/health_insights/cardio_fitness_analyzer.dart';
import 'package:gym_tracker/service/health_insights/heart_rate_recovery_analyzer.dart';
import 'package:gym_tracker/service/health_insights/metabolic_analyzer.dart';
import 'package:gym_tracker/service/health_insights/metric_timeline_builder.dart';
import 'package:gym_tracker/service/health_insights/stress_index_analyzer.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:injectable/injectable.dart';

/// Thrown by [HealthInsightsService.load] when Apple Health is unavailable or
/// returns no data at all — iOS doesn't reveal whether read access was
/// denied, so "nothing came back" is the only signal.
class HealthPermissionDeniedException implements Exception {
  const HealthPermissionDeniedException();
}

/// Orchestrates a full Health Insights load: fetches every metric this
/// feature needs from [HealthRepository], resolves the user's sex/birth
/// date/height (self-reported profile first, HealthKit characteristics as
/// fallback), runs every analyzer, and composes the [PhysicalOverview]
/// snapshot.
///
/// Every fetch is bounded to [MetricTimelineBuilder.reportingWindowStart]
/// (the last 24 months) so the page loads fast and every chart
/// stays readable — this is the only place that knows about every analyzer
/// and every [HealthMetric] this feature reads; analyzers themselves stay
/// pure (samples + profile facts in, a result model out) so they're
/// trivial to unit test in isolation.
@injectable
class HealthInsightsService {
  HealthInsightsService(
    this._repository,
    this._userService,
    this._authService,
    this._bodyCompositionAnalyzer,
    this._cardioFitnessAnalyzer,
    this._heartRateRecoveryAnalyzer,
    this._stressIndexAnalyzer,
    this._metabolicAnalyzer,
  );

  final HealthRepository _repository;
  final UserService _userService;
  final AuthService _authService;
  final BodyCompositionAnalyzer _bodyCompositionAnalyzer;
  final CardioFitnessAnalyzer _cardioFitnessAnalyzer;
  final HeartRateRecoveryAnalyzer _heartRateRecoveryAnalyzer;
  final StressIndexAnalyzer _stressIndexAnalyzer;
  final MetabolicAnalyzer _metabolicAnalyzer;

  /// Body-fat-enabling data (weight + lean mass) must be at least this
  /// recent for Physical Overview's row 2 to render.
  static const _row2RecencyWindow = Duration(days: 90);

  /// Makes the next [load] re-read Apple Health instead of today's cached snapshot.
  Future<void> clearCache() => _repository.clearCache();

  Future<HealthInsightsResult> load({required ComparisonMode comparisonMode, required ComparisonWindow comparisonWindow}) async {
    final granted = await _repository.requestAuthorization();
    if (!granted) throw const HealthPermissionDeniedException();

    final userId = _authService.currentUserId;
    final user = userId != null ? await _userService.getById(userId: userId) : null;
    final characteristics = await _repository.characteristics();

    final sex = user?.sex ?? characteristics?.sex;
    final birthDate = user?.birthDate ?? characteristics?.birthDate;
    final age = birthDate != null ? _ageFrom(birthDate) : null;

    final from = MetricTimelineBuilder.reportingWindowStart();
    final weightSamples = await _repository.samples(HealthMetric.bodyMass, from: from);
    final leanMassSamples = await _repository.samples(HealthMetric.leanBodyMass, from: from);
    // Height is a lifetime-stable trait rarely re-logged — never bounded by
    // the reporting window (mirrors the same exemption in
    // MockHealthRepository/the fixture-extraction script).
    final heightSamples = await _repository.samples(HealthMetric.height);
    final vo2MaxSamples = await _repository.samples(HealthMetric.vo2Max, from: from);
    final hrvSamples = await _repository.samples(HealthMetric.heartRateVariabilitySdnn, from: from);
    final hrrSamples = await _repository.samples(HealthMetric.heartRateRecovery, from: from);
    final basalSamples = await _repository.samples(HealthMetric.basalEnergyBurned, from: from);
    final activeSamples = await _repository.samples(HealthMetric.activeEnergyBurned, from: from);

    final hasHealthData =
        characteristics?.sex != null ||
        characteristics?.birthDate != null ||
        [
          weightSamples,
          leanMassSamples,
          heightSamples,
          vo2MaxSamples,
          hrvSamples,
          hrrSamples,
          basalSamples,
          activeSamples,
        ].any((samples) => samples.isNotEmpty);
    if (!hasHealthData) {
      // Usually means access was declined — don't keep an empty snapshot for the rest of the day.
      await _repository.clearCache();
      throw const HealthPermissionDeniedException();
    }

    // Height, like sex and birth date, prefers the self-reported profile
    // value (deliberate, current) over a HealthKit sample (which is rarely
    // re-logged and may be stale).
    final heightCm = user?.heightCm ?? (heightSamples.isNotEmpty ? heightSamples.last.value : null);
    final currentWeightKg = weightSamples.isNotEmpty ? weightSamples.last.value : user?.weightKg;
    final currentLeanMassKg = leanMassSamples.isNotEmpty ? leanMassSamples.last.value : null;

    final bodyComposition = _bodyCompositionAnalyzer.analyze(
      weightSamples: weightSamples,
      leanMassSamples: leanMassSamples,
      sex: sex,
      comparisonMode: comparisonMode,
      comparisonWindow: comparisonWindow,
    );

    final cardioFitness = _cardioFitnessAnalyzer.analyze(
      vo2MaxSamples: vo2MaxSamples,
      weightSamples: weightSamples,
      sex: sex,
      ageYears: age,
      comparisonMode: comparisonMode,
      comparisonWindow: comparisonWindow,
    );

    final heartRateRecovery = _heartRateRecoveryAnalyzer.analyze(hrrSamples: hrrSamples);

    final metabolic = _metabolicAnalyzer.analyze(
      weightKg: currentWeightKg,
      heightCm: heightCm,
      ageYears: age,
      sex: sex,
      leanBodyMassKg: currentLeanMassKg,
      basalEnergySamples: basalSamples,
      activeEnergySamples: activeSamples,
    );

    final overview = _buildOverview(
      heightCm: heightCm,
      age: age,
      sex: sex,
      currentWeightKg: currentWeightKg,
      leanMassSamples: leanMassSamples,
      bodyComposition: bodyComposition,
      hrvSamples: hrvSamples,
    );

    return HealthInsightsResult(
      overview: overview,
      comparisonMode: comparisonMode,
      comparisonWindow: comparisonWindow,
      bodyComposition: bodyComposition,
      cardioFitness: cardioFitness,
      heartRateRecovery: heartRateRecovery,
      metabolic: metabolic,
    );
  }

  PhysicalOverview _buildOverview({
    required double? heightCm,
    required int? age,
    required Sex? sex,
    required double? currentWeightKg,
    required List<HealthSample> leanMassSamples,
    required BodyCompositionTrend? bodyComposition,
    required List<HealthSample> hrvSamples,
  }) {
    final now = DateTime.now();

    final latestLeanMass = leanMassSamples.isNotEmpty ? leanMassSamples.last : null;
    final row2Visible = latestLeanMass != null && !latestLeanMass.dateFrom.isBefore(now.subtract(_row2RecencyWindow));

    final bodyFatPercent = row2Visible ? bodyComposition?.currentBodyFatPercent : null;
    final stressIndex = row2Visible ? _stressIndexAnalyzer.analyze(hrvSamples: hrvSamples) : null;

    return PhysicalOverview(
      asOf: now,
      heightCm: heightCm ?? 0,
      weightKg: currentWeightKg,
      age: age,
      sex: sex,
      bodyFatPercent: bodyFatPercent,
      stressIndex: stressIndex,
      row2Visible: row2Visible,
    );
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
