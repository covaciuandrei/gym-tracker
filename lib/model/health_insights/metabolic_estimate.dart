import 'package:equatable/equatable.dart';

/// Personalized resting-metabolic-rate and total-daily-energy-expenditure
/// estimate.
///
/// [mifflinStJeorKcal] uses the classic age/sex/height/weight formula \u2014
/// roughly what Apple's own `BasalEnergyBurned` estimate tracks.
/// [cunninghamKcal] uses the Cunningham equation (lean-body-mass based),
/// available only when a recent lean-body-mass reading exists; it is
/// generally considered more accurate for people who track body
/// composition, since it does not assume a "typical" body-fat percentage
/// for the given age/sex/weight the way Mifflin-St Jeor implicitly does.
class MetabolicEstimate extends Equatable {
  const MetabolicEstimate({
    required this.mifflinStJeorKcal,
    this.cunninghamKcal,
    this.watchBasalAvgKcal,
    this.watchActiveAvgKcal,
    this.totalDailyEnergyKcal,
  });

  final double mifflinStJeorKcal;
  final double? cunninghamKcal;

  /// Average of Apple's own daily `BasalEnergyBurned` totals over the
  /// comparison window, shown alongside our estimates for reference.
  final double? watchBasalAvgKcal;
  final double? watchActiveAvgKcal;

  /// Best available total-daily-energy-expenditure estimate: the preferred
  /// resting-rate estimate (Cunningham if available, else Mifflin-St Jeor)
  /// plus the Watch's own average active-energy burn.
  final double? totalDailyEnergyKcal;

  @override
  List<Object?> get props => [
    mifflinStJeorKcal,
    cunninghamKcal,
    watchBasalAvgKcal,
    watchActiveAvgKcal,
    totalDailyEnergyKcal,
  ];
}
