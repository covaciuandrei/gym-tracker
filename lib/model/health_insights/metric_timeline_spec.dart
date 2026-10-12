import 'package:gym_tracker/model/health_insights/health_metric.dart';

/// Describes one raw [HealthMetric] to load and aggregate into a monthly
/// series for [MetricTimelinePage] \u2014 e.g. "load bodyMass samples, label the
/// resulting series 'Weight', unit 'kg'".
class MetricTimelineSeriesSpec {
  const MetricTimelineSeriesSpec({required this.metric, required this.label, required this.unit});

  final HealthMetric metric;
  final String label;
  final String unit;
}
