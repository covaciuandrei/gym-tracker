import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/heart_rate_recovery.dart';
import 'package:injectable/injectable.dart';

/// Reads the latest Heart Rate Recovery (HRR) reading directly \u2014 Apple
/// computes this natively per workout
/// (`HKQuantityTypeIdentifierHeartRateRecoveryOneMinute`), so no derivation
/// from raw continuous heart-rate streams is needed.
///
/// Band source: Cole et al., "Heart-rate recovery immediately after exercise
/// as a predictor of mortality", NEJM 1999 \u2014 an HRR of 12 bpm or less at one
/// minute (with an active cool-down) was associated with increased
/// all-cause mortality risk in that study. The higher bands are commonly
/// used practical extensions, not individually cited \u2014 presented as a
/// wellness estimate, never a diagnostic figure.
@injectable
class HeartRateRecoveryAnalyzer {
  const HeartRateRecoveryAnalyzer();

  /// [hrrSamples] must be ascending by date. Returns `null` when empty.
  HeartRateRecovery? analyze({required List<HealthSample> hrrSamples}) {
    if (hrrSamples.isEmpty) return null;
    final current = hrrSamples.last.value;
    return HeartRateRecovery(
      currentBpm: current,
      band: _bandFor(current),
      history: [for (final s in hrrSamples) MapEntry(s.dateFrom, s.value)],
    );
  }

  HeartRateRecoveryBand _bandFor(double bpm) {
    if (bpm <= 12) return HeartRateRecoveryBand.low;
    if (bpm <= 20) return HeartRateRecoveryBand.fair;
    if (bpm <= 30) return HeartRateRecoveryBand.good;
    return HeartRateRecoveryBand.excellent;
  }
}
