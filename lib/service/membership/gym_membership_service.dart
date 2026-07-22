import 'package:gym_tracker/data/remote/membership/gym_membership_source.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:injectable/injectable.dart';

part 'gym_membership_service_exceptions.dart';

@injectable
class GymMembershipService {
  const GymMembershipService(this._source);

  final GymMembershipSource _source;

  Future<List<GymMembership>> getAll({required String userId}) => _source.getAll(userId: userId);

  Future<GymMembership?> getRelevant({required String userId, DateTime? at}) async {
    final memberships = await getAll(userId: userId);
    if (memberships.isEmpty) return null;

    final date = at ?? DateTime.now();
    for (final membership in memberships) {
      if (membership.isActiveAt(date)) return membership;
    }

    final upcoming = memberships.where((membership) => membership.isUpcomingAt(date)).toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
    if (upcoming.isNotEmpty) return upcoming.first;

    final expired = memberships.where((membership) => membership.isExpiredAt(date)).toList()
      ..sort((a, b) => b.validUntil.compareTo(a.validUntil));
    return expired.first;
  }

  Future<String> create({required String userId, required GymMembership membership}) =>
      _source.create(userId: userId, membership: membership);

  Future<void> update({required String userId, required GymMembership membership}) async {
    final existing = await _source.getById(userId: userId, membershipId: membership.id);
    if (existing == null) throw const GymMembershipNotFoundException();
    await _source.update(userId: userId, membership: membership);
  }

  Future<void> delete({required String userId, required String membershipId}) async {
    final existing = await _source.getById(userId: userId, membershipId: membershipId);
    if (existing == null) throw const GymMembershipNotFoundException();
    await _source.delete(userId: userId, membershipId: membershipId);
  }
}
