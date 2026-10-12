import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_insights_result.dart';
import 'package:gym_tracker/service/health_insights/health_insights_service.dart';
import 'package:injectable/injectable.dart';

part 'health_insights_states.dart';

/// Drives the Health Insights page: loads the physical overview plus the
/// four insight cards.
///
/// Cards compare against population norms by default (fixed \u2014 there's no
/// page-level toggle anymore; the Physical Overview's own dedicated detail
/// page owns the population/past-you choice for itself).
@injectable
class HealthInsightsCubit extends BaseCubit {
  HealthInsightsCubit(this._service);

  final HealthInsightsService _service;

  static const _comparisonMode = ComparisonMode.population;
  static const _comparisonWindow = ComparisonWindow.oneYear;

  /// Loads every insight, from today's cached Apple Health snapshot when there is one.
  Future<void> load() async {
    safeEmit(const PendingState());
    try {
      final result = await _service.load(comparisonMode: _comparisonMode, comparisonWindow: _comparisonWindow);
      safeEmit(HealthInsightsReadyState(result: result));
    } on HealthPermissionDeniedException {
      safeEmit(const HealthInsightsPermissionDeniedState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Re-reads Apple Health instead of the cached snapshot (pull-to-refresh, "no data" retry).
  Future<void> refresh() async {
    await _service.clearCache();
    await load();
  }
}
