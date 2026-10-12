part of 'metric_timeline_cubit.dart';

/// Every requested series has loaded, aggregated to monthly points.
class MetricTimelineReadyState extends BaseState {
  const MetricTimelineReadyState({required this.series, required this.availableRanges});

  final List<MetricSeriesData> series;
  final List<TimelineRange> availableRanges;

  @override
  List<Object?> get props => [series, availableRanges];
}
