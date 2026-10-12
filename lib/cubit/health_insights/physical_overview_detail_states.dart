part of 'physical_overview_detail_cubit.dart';

/// Loaded successfully. [comparison] is `null` when there isn't enough
/// profile data (weight/height/age) for a population comparison \u2014
/// past-you mode still works from [weightPoints]/[leanMassPoints] alone.
class PhysicalOverviewDetailReadyState extends BaseState {
  const PhysicalOverviewDetailReadyState({
    required this.comparison,
    required this.weightPoints,
    required this.leanMassPoints,
    required this.availableRanges,
  });

  final PopulationPhysicalComparison? comparison;
  final List<MonthlyPoint> weightPoints;
  final List<MonthlyPoint> leanMassPoints;
  final List<TimelineRange> availableRanges;

  @override
  List<Object?> get props => [comparison, weightPoints, leanMassPoints, availableRanges];
}
