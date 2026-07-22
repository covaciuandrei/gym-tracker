import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/membership/membership_cubit.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/model/user.dart';
import 'package:gym_tracker/service/membership/gym_membership_service.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGymMembershipService extends Mock implements GymMembershipService {}

class MockUserService extends Mock implements UserService {}

class FakeGymMembership extends Fake implements GymMembership {}

void main() {
  const userId = 'user_1';
  final draft = GymMembershipDraft(
    gymName: 'Test Gym',
    startDate: DateTime(2026, 7, 22),
    duration: MembershipDuration.oneMonth,
    priceMinor: 15000,
    currency: 'RON',
  );
  final membership = GymMembership(
    id: 'membership_1',
    gymName: 'Test Gym',
    startDate: DateTime(2026, 7, 22),
    durationMonths: 1,
    validUntil: DateTime(2026, 8, 21),
    priceMinor: 15000,
    currency: 'RON',
  );

  setUpAll(() => registerFallbackValue(FakeGymMembership()));

  late MockGymMembershipService service;
  late MockUserService userService;
  late MembershipCubit cubit;

  setUp(() {
    service = MockGymMembershipService();
    userService = MockUserService();
    when(() => userService.getById(userId: any(named: 'userId'))).thenAnswer((_) async => null);
    cubit = MembershipCubit(service, userService);
  });

  tearDown(() => cubit.close());

  test('load emits pending then loaded history', () async {
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => [membership]);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const PendingState(),
        isA<MembershipsLoadedState>()
            .having((state) => state.memberships, 'memberships', [membership])
            .having((state) => state.defaultCurrency, 'defaultCurrency', 'EUR'),
      ]),
    );
    await cubit.load(userId: userId);
    await expectation;
  });

  test('load exposes the account currency for blank drafts', () async {
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => []);
    when(() => userService.getById(userId: userId)).thenAnswer(
      (_) async => User(
        id: userId,
        email: 'user@test.com',
        displayName: 'User',
        theme: 'dark',
        language: 'ro',
        currency: 'RON',
        lastLoginAt: DateTime(2026),
        createdAt: DateTime(2026),
        totalAttendances: 0,
      ),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const PendingState(),
        isA<MembershipsLoadedState>().having((state) => state.defaultCurrency, 'defaultCurrency', 'RON'),
      ]),
    );

    await cubit.load(userId: userId);
    await expectation;
  });

  test('create computes validity and emits refreshed history', () async {
    when(
      () => service.create(
        userId: userId,
        membership: any(named: 'membership'),
      ),
    ).thenAnswer((_) async => 'membership_1');
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => [membership]);

    final expectation = expectLater(cubit.stream, emitsInOrder([const PendingState(), isA<MembershipCreatedState>()]));
    await cubit.create(userId: userId, draft: draft);
    await expectation;

    final captured =
        verify(
              () => service.create(
                userId: userId,
                membership: captureAny(named: 'membership'),
              ),
            ).captured.single
            as GymMembership;
    expect(captured.validUntil, DateTime(2026, 8, 21));
    expect(captured.daysRemainingAt(captured.startDate), 30);
    expect(captured.priceMinor, 15000);
  });

  test('create emits catch-all error on failure', () async {
    when(
      () => service.create(
        userId: userId,
        membership: any(named: 'membership'),
      ),
    ).thenThrow(Exception('network'));

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
    );
    await cubit.create(userId: userId, draft: draft);
    await expectation;
  });
}
