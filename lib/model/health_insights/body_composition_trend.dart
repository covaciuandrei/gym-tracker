import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/health_insights/population_benchmark.dart';

/// Plain-language direction for a body-composition change.
enum BodyCompositionDirection {
  /// Weight down, lean mass held \u2014 fat loss with muscle retained.
  cutting,

  /// Weight up, lean mass up roughly in proportion.
  bulking,

  /// Weight roughly flat, lean mass up \u2014 fat replaced by muscle.
  recomposition,
  stable,
  insufficientData,
}

/// One point on the body-composition trend sparkline.
class BodyCompositionPoint extends Equatable {
  const BodyCompositionPoint({required this.date, required this.weightKg, this.leanBodyMassKg});

  final DateTime date;
  final double weightKg;
  final double? leanBodyMassKg;

  @override
  List<Object?> get props => [date, weightKg, leanBodyMassKg];
}

/// Body-recomposition analysis: current weight / lean mass / body fat, the
/// change over the comparison window, and a plain-language direction.
class BodyCompositionTrend extends Equatable {
  const BodyCompositionTrend({
    required this.currentWeightKg,
    required this.direction,
    required this.history,
    this.currentLeanBodyMassKg,
    this.currentBodyFatPercent,
    this.weightChangeKg,
    this.leanBodyMassChangeKg,
    this.bodyFatPercentChange,
    this.compareLabel,
    this.benchmark,
  });

  final double currentWeightKg;
  final double? currentLeanBodyMassKg;
  final double? currentBodyFatPercent;

  /// Change vs. the comparison baseline. Null when in population-comparison
  /// mode (population norms don't have a "your weight changed by" figure)
  /// or when there is no reading old enough for the selected window.
  final double? weightChangeKg;
  final double? leanBodyMassChangeKg;
  final double? bodyFatPercentChange;
  final String? compareLabel;

  final BodyCompositionDirection direction;
  final List<BodyCompositionPoint> history;
  final PopulationBenchmark? benchmark;

  @override
  List<Object?> get props => [
    currentWeightKg,
    currentLeanBodyMassKg,
    currentBodyFatPercent,
    weightChangeKg,
    leanBodyMassChangeKg,
    bodyFatPercentChange,
    compareLabel,
    direction,
    history,
    benchmark,
  ];
}
