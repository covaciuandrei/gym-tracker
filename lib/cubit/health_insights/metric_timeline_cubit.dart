import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline_spec.dart';
import 'package:gym_tracker/model/health_insights/timeline_range.dart';
import 'package:gym_tracker/service/health_insights/metric_timeline_builder.dart';
import 'package:injectable/injectable.dart';

part 'metric_timeline_states.dart';

/// Drives [MetricTimelinePage]: loads the raw samples for every requested
/// [MetricTimelineSeriesSpec], aggregates each into a monthly series, and
/// resolves which [TimelineRange]s the combined history can support.
///
/// Generic and reusable across every "tap a card to see its monthly chart
/// history" entry point in Health Insights (currently Body Recomposition
/// and Cardio Fitness) \u2014 callers only need to supply which [HealthMetric]s
/// to load. Every fetch is bounded to
/// [MetricTimelineBuilder.reportingWindowStart] (the last 24 months) so
/// charts load fast and stay readable.
@injectable
class MetricTimelineCubit extends BaseCubit {
  MetricTimelineCubit(this._repository, this._timelineBuilder);

  final HealthRepository _repository;
  final MetricTimelineBuilder _timelineBuilder;

  /// [derivedBodyFatLabel] / [derivedBodyFatUnit], when provided, add an
  /// extra series computed by pairing each month's average weight with that
  /// month's average lean mass (`(weight - lean) / weight * 100`) \u2014 used by
  /// Body Recomposition, which shows weight + derived body-fat % rather
  /// than weight + lean mass.
  Future<void> load({required List<MetricTimelineSeriesSpec> specs, String? derivedBodyFatLabel, String? derivedBodyFatUnit}) async {
    safeEmit(const PendingState());
    try {
      final from = MetricTimelineBuilder.reportingWindowStart();
      final seriesList = <MetricSeriesData>[];
      DateTime? earliest;

      void trackEarliest(List<HealthSample> samples) {
        if (samples.isEmpty) return;
        final firstDate = samples.map((s) => s.dateFrom).reduce((a, b) => a.isBefore(b) ? a : b);
        if (earliest == null || firstDate.isBefore(earliest!)) earliest = firstDate;
      }

      for (final spec in specs) {
        final samples = await _repository.samples(spec.metric, from: from);
        trackEarliest(samples);
        seriesList.add(MetricSeriesData(label: spec.label, unit: spec.unit, monthlyPoints: _timelineBuilder.buildMonthlyPoints(samples)));
      }

      if (derivedBodyFatLabel != null) {
        final weightSamples = await _repository.samples(HealthMetric.bodyMass, from: from);
        final leanSamples = await _repository.samples(HealthMetric.leanBodyMass, from: from);
        trackEarliest(weightSamples);
        final bodyFatPoints = _deriveBodyFatPoints(weightSamples, leanSamples);
        if (bodyFatPoints.isNotEmpty) {
          seriesList.add(MetricSeriesData(label: derivedBodyFatLabel, unit: derivedBodyFatUnit ?? '%', monthlyPoints: bodyFatPoints));
        }
      }

      final ranges = earliest != null ? _timelineBuilder.availableRanges(earliestDataDate: earliest!) : const <TimelineRange>[];
      safeEmit(MetricTimelineReadyState(series: seriesList, availableRanges: ranges));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  List<MonthlyPoint> _deriveBodyFatPoints(List<HealthSample> weightSamples, List<HealthSample> leanSamples) {
    if (weightSamples.isEmpty || leanSamples.isEmpty) return const [];

    final weightPoints = _timelineBuilder.buildMonthlyPoints(weightSamples);
    final leanByMonth = {for (final p in _timelineBuilder.buildMonthlyPoints(leanSamples)) p.month: p.value};

    final points = <MonthlyPoint>[];
    for (final w in weightPoints) {
      final lean = leanByMonth[w.month];
      if (lean == null || w.value <= 0) continue;
      points.add(MonthlyPoint(month: w.month, value: (w.value - lean) / w.value * 100));
    }
    return points;
  }
}
