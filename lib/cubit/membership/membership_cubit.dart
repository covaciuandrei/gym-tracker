import 'package:gym_tracker/core/constants/currencies.dart';
import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/service/membership/gym_membership_service.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:injectable/injectable.dart';

part 'membership_states.dart';

@injectable
class MembershipCubit extends BaseCubit {
  MembershipCubit(this._service, this._userService);

  final GymMembershipService _service;
  final UserService _userService;

  String _defaultCurrency = fallbackCurrencyCode;

  Future<void> load({required String userId}) async {
    safeEmit(const PendingState());
    try {
      final memberships = await _service.getAll(userId: userId);
      _defaultCurrency = await _loadDefaultCurrency(userId: userId);
      safeEmit(MembershipsLoadedState(memberships: memberships, defaultCurrency: _defaultCurrency));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> create({required String userId, required GymMembershipDraft draft}) async {
    await guardedAction(() async {
      try {
        final membership = _membershipFromDraft(id: '', draft: draft);
        await _service.create(userId: userId, membership: membership);
        final memberships = await _service.getAll(userId: userId);
        safeEmit(MembershipCreatedState(memberships: memberships, defaultCurrency: _defaultCurrency));
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  Future<void> update({
    required String userId,
    required GymMembership current,
    required GymMembershipDraft draft,
  }) async {
    await guardedAction(() async {
      try {
        final membership = _membershipFromDraft(
          id: current.id,
          draft: draft,
          createdAt: current.createdAt,
          updatedAt: current.updatedAt,
        );
        await _service.update(userId: userId, membership: membership);
        final memberships = await _service.getAll(userId: userId);
        safeEmit(MembershipUpdatedState(memberships: memberships, defaultCurrency: _defaultCurrency));
      } on GymMembershipNotFoundException {
        safeEmit(const SomethingWentWrongState());
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  Future<void> delete({required String userId, required String membershipId}) async {
    await guardedAction(() async {
      try {
        await _service.delete(userId: userId, membershipId: membershipId);
        final memberships = await _service.getAll(userId: userId);
        safeEmit(MembershipDeletedState(memberships: memberships, defaultCurrency: _defaultCurrency));
      } on GymMembershipNotFoundException {
        safeEmit(const SomethingWentWrongState());
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  Future<String> _loadDefaultCurrency({required String userId}) async {
    try {
      final user = await _userService.getById(userId: userId);
      return normalizeCurrencyCode(user?.currency);
    } catch (_) {
      return fallbackCurrencyCode;
    }
  }

  GymMembership _membershipFromDraft({
    required String id,
    required GymMembershipDraft draft,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GymMembership(
      id: id,
      gymName: draft.gymName.trim(),
      startDate: DateTime(draft.startDate.year, draft.startDate.month, draft.startDate.day),
      durationMonths: draft.duration.months,
      validUntil: draft.validUntil,
      priceMinor: draft.priceMinor,
      currency: draft.currency,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
