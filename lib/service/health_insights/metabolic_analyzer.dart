import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/metabolic_estimate.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:injectable/injectable.dart';

/// Estimates resting metabolic rate and total daily energy expenditure.
///
/// [MetabolicEstimate.mifflinStJeorKcal] needs a complete profile (age, sex,
/// height, weight) — roughly what Apple's own `BasalEnergyBurned` estimate
/// tracks. [MetabolicEstimate.cunninghamKcal] only needs a recent
/// lean-body-mass reading and is generally considered more accurate for
/// people who track body composition, since it doesn't assume a "typical"
/// body-fat percentage for the given age/sex/weight the way Mifflin-St Jeor
/// implicitly does.
@injectable
class MetabolicAnalyzer {
  const MetabolicAnalyzer();

  /// Returns `null` only when none of the required profile fields
  /// (weight/height/age/sex) are available — Cunningham and the Watch
  /// averages are still included whenever their own inputs exist.
  MetabolicEstimate? analyze({
    required double? weightKg,
    required double? heightCm,
    required int? ageYears,
    required Sex? sex,
    required double? leanBodyMassKg,
    required List<HealthSample> basalEnergySamples,
    required List<HealthSample> activeEnergySamples,
    ComparisonWindow window = ComparisonWindow.threeMonths,
    DateTime? now,
  }) {
    if (weightKg == null || heightCm == null || ageYears == null || sex == null) return null;

    final mifflinStJeorKcal = sex == Sex.male
        ? 10 * weightKg + 6.25 * heightCm - 5 * ageYears + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * ageYears - 161;

    final cunninghamKcal = leanBodyMassKg != null ? 500 + 22 * leanBodyMassKg : null;

    final today = now ?? DateTime.now();
    final cutoff = today.subtract(Duration(days: window.days));
    final watchBasalAvgKcal = _average(_valuesInRange(basalEnergySamples, cutoff, today));
    final watchActiveAvgKcal = _average(_valuesInRange(activeEnergySamples, cutoff, today));

    final restingEstimate = cunninghamKcal ?? mifflinStJeorKcal;
    final totalDailyEnergyKcal = watchActiveAvgKcal != null ? restingEstimate + watchActiveAvgKcal : null;

    return MetabolicEstimate(
      mifflinStJeorKcal: mifflinStJeorKcal,
      cunninghamKcal: cunninghamKcal,
      watchBasalAvgKcal: watchBasalAvgKcal,
      watchActiveAvgKcal: watchActiveAvgKcal,
      totalDailyEnergyKcal: totalDailyEnergyKcal,
    );
  }

  double? _average(List<double> values) {
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  List<double> _valuesInRange(List<HealthSample> samples, DateTime from, DateTime to) =>
      samples.where((s) => !s.dateFrom.isBefore(from) && !s.dateFrom.isAfter(to)).map((s) => s.value).toList();
}
