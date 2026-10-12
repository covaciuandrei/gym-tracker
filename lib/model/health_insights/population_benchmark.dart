import 'package:equatable/equatable.dart';

/// Where a measured value falls relative to a bundled population reference
/// table for the user's sex and age.
///
/// Percentiles are approximate \u2014 derived from published normative ranges
/// (Cooper Institute / ACSM cardiorespiratory fitness norms, ACE body
/// composition categories, typical HRV/RHR-by-age bands), not an
/// individually-fitted statistical distribution. Always presented as a
/// fitness/wellness estimate, never a clinical or diagnostic percentile.
class PopulationBenchmark extends Equatable {
  const PopulationBenchmark({required this.percentile, required this.band, required this.cohortLabel, required this.averageValue});

  /// Approximate 0-100 standing within the cohort. Higher always means
  /// "better for this metric" \u2014 callers invert the underlying value first
  /// for "lower is better" metrics (e.g. resting heart rate) so this field's
  /// meaning never depends on the metric.
  final int percentile;

  /// Human-readable category, e.g. "Above average", "Excellent".
  final String band;

  /// Describes the reference cohort, e.g. "Men, 20-29".
  final String cohortLabel;

  /// The cohort's median/average reference value, in the same unit as the
  /// measured value \u2014 shown alongside [band] so the comparison row states
  /// an actual number, not just a qualitative label.
  final double averageValue;

  @override
  List<Object?> get props => [percentile, band, cohortLabel, averageValue];
}
