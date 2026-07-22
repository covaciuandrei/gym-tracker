part of 'membership_cubit.dart';

abstract class MembershipsReadyState extends BaseState {
  const MembershipsReadyState({required this.memberships});

  final List<GymMembership> memberships;

  @override
  List<Object?> get props => [memberships];
}

class MembershipsLoadedState extends MembershipsReadyState {
  const MembershipsLoadedState({required super.memberships});
}

class MembershipCreatedState extends MembershipsReadyState {
  const MembershipCreatedState({required super.memberships});
}

class MembershipUpdatedState extends MembershipsReadyState {
  const MembershipUpdatedState({required super.memberships});
}

class MembershipDeletedState extends MembershipsReadyState {
  const MembershipDeletedState({required super.memberships});
}
