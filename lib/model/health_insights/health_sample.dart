import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';

/// A single point-in-time (or pre-aggregated interval) health measurement \u2014
/// the shape every `HealthRepository` returns, live (Apple Health) or
/// fixture-backed (tests).
class HealthSample extends Equatable {
  const HealthSample({
    required this.metric,
    required this.value,
    required this.unit,
    required this.dateFrom,
    required this.dateTo,
    required this.sourceName,
  });

  final HealthMetric metric;
  final double value;
  final String unit;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String sourceName;

  @override
  List<Object?> get props => [metric, value, unit, dateFrom, dateTo, sourceName];
}
