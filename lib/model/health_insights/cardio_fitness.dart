import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/health_insights/population_benchmark.dart';

/// Weight-adjusted VO2Max analysis.
///
/// Apple already reports VO2Max in weight-relative units (mL/(min\u00b7kg)), but
/// never explains that a bodyweight change alone moves the number even when
/// aerobic capacity hasn't changed. [vo2MaxAtCompareWeight] answers "what
/// would my current VO2Max reading be if only my weight had changed back to
/// what it was at the comparison point, with fitness held constant?" \u2014
/// letting the UI say "your engine is the same size; the number moved
/// because your weight did" when that's what the data shows.
class CardioFitness extends Equatable {
  const CardioFitness({
    required this.currentVo2Max,
    required this.currentWeightKg,
    this.compareVo2Max,
    this.compareWeightKg,
    this.vo2MaxAtCompareWeight,
    this.compareLabel,
    this.history = const [],
    this.benchmark,
  });

  /// Latest measured VO2Max, mL/(min\u00b7kg), as reported by the Watch.
  final double currentVo2Max;
  final double currentWeightKg;

  final double? compareVo2Max;
  final double? compareWeightKg;

  /// `currentVo2Max` rescaled to `compareWeightKg` assuming absolute aerobic
  /// capacity (VO2Max \u00d7 weight) stayed constant. Compare this \u2014 not
  /// `currentVo2Max` \u2014 against `compareVo2Max` to separate a real fitness
  /// change from a bodyweight-driven one.
  final double? vo2MaxAtCompareWeight;
  final String? compareLabel;

  final List<MapEntry<DateTime, double>> history;
  final PopulationBenchmark? benchmark;

  @override
  List<Object?> get props => [
    currentVo2Max,
    currentWeightKg,
    compareVo2Max,
    compareWeightKg,
    vo2MaxAtCompareWeight,
    compareLabel,
    history,
    benchmark,
  ];
}
