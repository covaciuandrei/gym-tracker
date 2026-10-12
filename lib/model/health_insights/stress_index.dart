import 'package:equatable/equatable.dart';

enum StressBand { low, typical, elevated, high }

/// A wellness-estimate "stress index" (0-100) derived from how far today's
/// heart-rate variability sits below the user's own rolling 60-day baseline
/// \u2014 lower HRV relative to personal baseline is a commonly-cited proxy for
/// higher physiological stress load. 50 = typical for you; higher = more
/// stressed than usual, lower = more relaxed than usual.
///
/// Intentionally self-baselined only (like heart-rate recovery and unlike
/// the population-benchmarked cards) \u2014 there is no population norm for
/// "stress" that would be meaningful to compare against.
class StressIndex extends Equatable {
  const StressIndex({required this.value, required this.band, this.hrvMs, this.baselineHrvMs});

  /// 0-100.
  final int value;
  final StressBand band;
  final double? hrvMs;
  final double? baselineHrvMs;

  @override
  List<Object?> get props => [value, band, hrvMs, baselineHrvMs];
}
