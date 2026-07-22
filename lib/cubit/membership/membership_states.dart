part of 'membership_cubit.dart';

abstract class MembershipsReadyState extends BaseState {
  const MembershipsReadyState({required this.memberships, required this.defaultCurrency});

  final List<GymMembership> memberships;
  final String defaultCurrency;

  @override
  List<Object?> get props => [memberships, defaultCurrency];
}

class MembershipsLoadedState extends MembershipsReadyState {
  const MembershipsLoadedState({required super.memberships, required super.defaultCurrency});
}

class MembershipCreatedState extends MembershipsReadyState {
  const MembershipCreatedState({required super.memberships, required super.defaultCurrency});
}

class MembershipUpdatedState extends MembershipsReadyState {
  const MembershipUpdatedState({required super.memberships, required super.defaultCurrency});
}

class MembershipDeletedState extends MembershipsReadyState {
  const MembershipDeletedState({required super.memberships, required super.defaultCurrency});
}
