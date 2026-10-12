import 'package:gym_tracker/model/health_insights/cardio_fitness.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/population_benchmark.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';
import 'package:injectable/injectable.dart';

/// Analyzes VO2Max readings into a weight-adjusted [CardioFitness] view.
///
/// The key reframe this analyzer exists for: Apple reports VO2Max in
/// weight-relative units (mL/(min·kg)) but never explains that a bodyweight
/// change alone moves the number even when aerobic capacity hasn't changed.
/// [CardioFitness.vo2MaxAtCompareWeight] rescales the current reading to the
/// comparison point's bodyweight (assuming absolute aerobic capacity —
/// VO2Max × weight — stayed constant) so the UI can separate a real fitness
/// change from a bodyweight-driven one.
@injectable
class CardioFitnessAnalyzer {
  const CardioFitnessAnalyzer(this._norms);

  final PopulationNorms _norms;

  /// [vo2MaxSamples] and [weightSamples] must be ascending by date. Returns
  /// `null` when there isn't at least one reading of each.
  CardioFitness? analyze({
    required List<HealthSample> vo2MaxSamples,
    required List<HealthSample> weightSamples,
    required Sex? sex,
    required int? ageYears,
    required ComparisonMode comparisonMode,
    required ComparisonWindow comparisonWindow,
    DateTime? now,
  }) {
    if (vo2MaxSamples.isEmpty || weightSamples.isEmpty) return null;
    final today = now ?? DateTime.now();

    final currentVo2 = vo2MaxSamples.last;
    final currentWeight = _closestTo(weightSamples, currentVo2.dateFrom);

    double? compareVo2Max;
    double? compareWeightKg;
    double? vo2AtCompareWeight;
    String? compareLabel;
    PopulationBenchmark? benchmark;

    if (comparisonMode == ComparisonMode.pastSelf) {
      final cutoff = today.subtract(Duration(days: comparisonWindow.days));
      final pastVo2 = _closestTo(vo2MaxSamples, cutoff);
      compareVo2Max = pastVo2.value;
      final pastWeight = _closestTo(weightSamples, pastVo2.dateFrom);
      compareWeightKg = pastWeight.value;
      vo2AtCompareWeight = currentVo2.value * currentWeight.value / pastWeight.value;
      compareLabel = 'You, ${_windowLabel(comparisonWindow)} ago';
    } else if (sex != null && ageYears != null) {
      benchmark = _norms.vo2MaxBenchmark(vo2Max: currentVo2.value, age: ageYears, sex: sex);
      compareLabel = benchmark.cohortLabel;
    }

    return CardioFitness(
      currentVo2Max: currentVo2.value,
      currentWeightKg: currentWeight.value,
      compareVo2Max: compareVo2Max,
      compareWeightKg: compareWeightKg,
      vo2MaxAtCompareWeight: vo2AtCompareWeight,
      compareLabel: compareLabel,
      history: [for (final s in vo2MaxSamples) MapEntry(s.dateFrom, s.value)],
      benchmark: benchmark,
    );
  }

  /// The sample whose date is closest to [target] — prefers the most recent
  /// sample at or before it, falling back to the earliest available sample.
  HealthSample _closestTo(List<HealthSample> samples, DateTime target) {
    HealthSample? result;
    for (final s in samples) {
      if (!s.dateFrom.isAfter(target)) {
        if (result == null || s.dateFrom.isAfter(result.dateFrom)) result = s;
      }
    }
    return result ?? samples.first;
  }

  String _windowLabel(ComparisonWindow window) => switch (window) {
    ComparisonWindow.threeMonths => '3 months',
    ComparisonWindow.sixMonths => '6 months',
    ComparisonWindow.oneYear => '1 year',
  };
}
