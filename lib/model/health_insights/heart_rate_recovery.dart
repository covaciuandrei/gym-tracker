import 'package:equatable/equatable.dart';

enum HeartRateRecoveryBand { low, fair, good, excellent }

/// Heart Rate Recovery (HRR): the drop in heart rate, in bpm, from peak
/// effort to one minute after stopping exercise. A well-established marker
/// of cardiovascular fitness and autonomic (parasympathetic) recovery \u2014
/// Apple computes this natively per workout on supported hardware/watchOS
/// versions (`HKQuantityTypeIdentifierHeartRateRecoveryOneMinute`), so this
/// is read directly rather than derived from raw heart-rate streams.
///
/// Band source: Cole et al., "Heart-rate recovery immediately after exercise
/// as a predictor of mortality", NEJM 1999 \u2014 an HRR of 12 bpm or less at one
/// minute (with an active cool-down) was associated with increased
/// all-cause mortality risk in that study. The higher bands are commonly
/// used practical extensions, not individually cited \u2014 presented as a
/// wellness estimate, never a diagnostic figure.
class HeartRateRecovery extends Equatable {
  const HeartRateRecovery({required this.currentBpm, required this.band, this.history = const []});

  final double currentBpm;
  final HeartRateRecoveryBand band;

  /// Full history for the trend chart, ascending by date.
  final List<MapEntry<DateTime, double>> history;

  @override
  List<Object?> get props => [currentBpm, band, history];
}
