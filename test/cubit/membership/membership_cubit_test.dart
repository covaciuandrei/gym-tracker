import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/membership/membership_cubit.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/service/membership/gym_membership_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGymMembershipService extends Mock implements GymMembershipService {}

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
  late MembershipCubit cubit;

  setUp(() {
    service = MockGymMembershipService();
    cubit = MembershipCubit(service);
  });

  tearDown(() => cubit.close());

  test('load emits pending then loaded history', () async {
    when(() => service.getAll(userId: userId)).thenAnswer((_) async => [membership]);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        const PendingState(),
        isA<MembershipsLoadedState>().having((state) => state.memberships, 'memberships', [membership]),
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
