import 'package:equatable/equatable.dart';

/// A simple "you vs. an average person of your sex/age/height" comparison,
/// shown when the Physical Overview's comparison row is tapped in
/// population mode.
///
/// The "average" weight is approximated from a mid-healthy-range BMI (22)
/// applied to the user's own height \u2014 a deliberately simple, clearly
/// labeled approximation (not a fitted age-banded population weight table,
/// which would overstate precision this app doesn't have data to back).
class PopulationPhysicalComparison extends Equatable {
  const PopulationPhysicalComparison({
    required this.yourWeightKg,
    required this.averageWeightKg,
    required this.heightCm,
    required this.cohortLabel,
    this.yourBodyFatPercent,
    this.averageBodyFatPercent,
  });

  final double yourWeightKg;
  final double averageWeightKg;
  final double heightCm;
  final String cohortLabel;
  final double? yourBodyFatPercent;
  final double? averageBodyFatPercent;

  @override
  List<Object?> get props => [yourWeightKg, averageWeightKg, heightCm, cohortLabel, yourBodyFatPercent, averageBodyFatPercent];
}
