part of 'health_insights_cubit.dart';

/// Every insight has loaded (individual cards may still be `null` inside
/// [result] when there isn't enough data for that specific card \u2014 the page
/// renders that card's own empty state rather than hiding it).
class HealthInsightsReadyState extends BaseState {
  const HealthInsightsReadyState({required this.result});

  final HealthInsightsResult result;

  @override
  List<Object?> get props => [result];
}

/// [HealthRepository.requestAuthorization] returned `false`. Unreachable
/// with the mock repository (which always grants); becomes reachable once a
/// real HealthKit-backed repository is wired in.
class HealthInsightsPermissionDeniedState extends BaseState {
  const HealthInsightsPermissionDeniedState();
}
