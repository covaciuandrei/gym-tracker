import 'package:gym_tracker/model/health_insights/body_composition_trend.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/population_benchmark.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';
import 'package:injectable/injectable.dart';

/// Analyzes weight + lean-body-mass trends into a [BodyCompositionTrend]:
/// current body-fat % (derived as `(weight - leanMass) / weight`, since
/// Apple Health does not report body-fat % directly for this device), the
/// change over the selected comparison window, and a plain-language
/// direction (cutting / bulking / recomposition / stable).
@injectable
class BodyCompositionAnalyzer {
  const BodyCompositionAnalyzer(this._norms);

  final PopulationNorms _norms;

  /// Weight change smaller than this (kg) is treated as "roughly flat" when
  /// classifying [BodyCompositionDirection].
  static const _flatThresholdKg = 0.8;

  /// [weightSamples] and [leanMassSamples] must be ascending by date.
  /// Returns `null` when there's no weight data at all.
  BodyCompositionTrend? analyze({
    required List<HealthSample> weightSamples,
    required List<HealthSample> leanMassSamples,
    required Sex? sex,
    required ComparisonMode comparisonMode,
    required ComparisonWindow comparisonWindow,
    DateTime? now,
  }) {
    if (weightSamples.isEmpty) return null;
    final today = now ?? DateTime.now();

    final currentWeight = weightSamples.last;
    final currentLean = _latestOnOrBefore(leanMassSamples, currentWeight.dateFrom);
    final currentBodyFat = currentLean != null ? _bodyFatPercent(currentWeight.value, currentLean.value) : null;

    final history = [
      for (final w in weightSamples)
        BodyCompositionPoint(
          date: w.dateFrom,
          weightKg: w.value,
          leanBodyMassKg: _latestOnOrBefore(leanMassSamples, w.dateFrom)?.value,
        ),
    ];

    double? weightChangeKg;
    double? leanChangeKg;
    double? bodyFatChange;
    String? compareLabel;
    PopulationBenchmark? benchmark;

    if (comparisonMode == ComparisonMode.pastSelf) {
      final cutoff = today.subtract(Duration(days: comparisonWindow.days));
      final compareWeight = _closestTo(weightSamples, cutoff);
      if (compareWeight != null) {
        weightChangeKg = currentWeight.value - compareWeight.value;
        final compareLean = _latestOnOrBefore(leanMassSamples, compareWeight.dateFrom);
        if (compareLean != null) {
          if (currentLean != null) leanChangeKg = currentLean.value - compareLean.value;
          if (currentBodyFat != null) {
            bodyFatChange = currentBodyFat - _bodyFatPercent(compareWeight.value, compareLean.value);
          }
        }
        compareLabel = 'You, ${_windowLabel(comparisonWindow)} ago';
      }
    } else if (sex != null && currentBodyFat != null) {
      benchmark = _norms.bodyFatBenchmark(bodyFatPercent: currentBodyFat, sex: sex);
      compareLabel = benchmark.cohortLabel;
    }

    return BodyCompositionTrend(
      currentWeightKg: currentWeight.value,
      currentLeanBodyMassKg: currentLean?.value,
      currentBodyFatPercent: currentBodyFat,
      weightChangeKg: weightChangeKg,
      leanBodyMassChangeKg: leanChangeKg,
      bodyFatPercentChange: bodyFatChange,
      compareLabel: compareLabel,
      direction: _direction(weightChangeKg: weightChangeKg, leanChangeKg: leanChangeKg),
      history: history,
      benchmark: benchmark,
    );
  }

  double _bodyFatPercent(double weightKg, double leanMassKg) =>
      ((weightKg - leanMassKg) / weightKg * 100).clamp(0, 100);

  BodyCompositionDirection _direction({required double? weightChangeKg, required double? leanChangeKg}) {
    if (weightChangeKg == null) return BodyCompositionDirection.insufficientData;

    final weightFlat = weightChangeKg.abs() < _flatThresholdKg;
    if (weightFlat) {
      // Weight held steady but lean mass grew: fat replaced by muscle.
      if (leanChangeKg != null && leanChangeKg > _flatThresholdKg) return BodyCompositionDirection.recomposition;
      return BodyCompositionDirection.stable;
    }

    // Weight is the primary signal once it has moved meaningfully — a
    // modest lean-mass dip alongside a larger weight drop is normal for a
    // cut and doesn't change the direction (the size of that dip is still
    // reported separately via `leanBodyMassChangeKg` for the UI to note).
    return weightChangeKg < 0 ? BodyCompositionDirection.cutting : BodyCompositionDirection.bulking;
  }

  /// Most recent sample at or before [cutoff], or `null` if none exists.
  HealthSample? _latestOnOrBefore(List<HealthSample> samples, DateTime cutoff) {
    HealthSample? result;
    for (final s in samples) {
      if (!s.dateFrom.isAfter(cutoff)) {
        if (result == null || s.dateFrom.isAfter(result.dateFrom)) result = s;
      }
    }
    return result;
  }

  /// The sample whose date is closest to [target] — prefers the most recent
  /// sample at or before it, falling back to the earliest available sample
  /// so a comparison window longer than the history still resolves to
  /// "your very first reading" instead of `null`.
  HealthSample? _closestTo(List<HealthSample> samples, DateTime target) {
    if (samples.isEmpty) return null;
    return _latestOnOrBefore(samples, target) ?? samples.first;
  }

  String _windowLabel(ComparisonWindow window) => switch (window) {
    ComparisonWindow.threeMonths => '3 months',
    ComparisonWindow.sixMonths => '6 months',
    ComparisonWindow.oneYear => '1 year',
  };
}
