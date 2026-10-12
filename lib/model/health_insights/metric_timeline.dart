import 'package:equatable/equatable.dart';

/// One month's aggregated value (mean of that month's samples) for a
/// metric-timeline chart.
class MonthlyPoint extends Equatable {
  const MonthlyPoint({required this.month, required this.value});

  /// First day of the month this point summarizes.
  final DateTime month;
  final double value;

  @override
  List<Object?> get props => [month, value];
}

/// A single trackable series' full monthly history (unfiltered by any
/// selected range \u2014 range filtering happens client-side in the page, since
/// re-fetching on every range tap would be both slower and unnecessary for
/// this data volume).
class MetricSeriesData extends Equatable {
  const MetricSeriesData({required this.label, required this.unit, required this.monthlyPoints});

  final String label;
  final String unit;

  /// Ascending by month, one point per calendar month with data.
  final List<MonthlyPoint> monthlyPoints;

  @override
  List<Object?> get props => [label, unit, monthlyPoints];
}
