import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/membership/gym_membership_source.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/service/membership/gym_membership_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGymMembershipSource extends Mock implements GymMembershipSource {}

class FakeGymMembership extends Fake implements GymMembership {}

void main() {
  const userId = 'user_1';
  final expired = GymMembership(
    id: 'expired',
    gymName: 'Old Gym',
    startDate: DateTime(2025, 1, 1),
    durationMonths: 1,
    validUntil: DateTime(2025, 2, 1),
    priceMinor: 10000,
    currency: 'RON',
  );
  final active = GymMembership(
    id: 'active',
    gymName: 'Current Gym',
    startDate: DateTime(2025, 5, 1),
    durationMonths: 3,
    validUntil: DateTime(2025, 8, 1),
    priceMinor: 20000,
    currency: 'RON',
  );
  final upcoming = GymMembership(
    id: 'upcoming',
    gymName: 'Next Gym',
    startDate: DateTime(2025, 9, 1),
    durationMonths: 1,
    validUntil: DateTime(2025, 10, 1),
    priceMinor: 15000,
    currency: 'RON',
  );

  setUpAll(() => registerFallbackValue(FakeGymMembership()));

  late MockGymMembershipSource source;
  late GymMembershipService service;

  setUp(() {
    source = MockGymMembershipSource();
    service = GymMembershipService(source);
  });

  test('getRelevant prefers a currently active membership', () async {
    when(() => source.getAll(userId: userId)).thenAnswer((_) async => [upcoming, active, expired]);

    final result = await service.getRelevant(userId: userId, at: DateTime(2025, 6, 1));

    expect(result, active);
  });

  test('getRelevant returns the nearest upcoming membership', () async {
    final laterUpcoming = GymMembership(
      id: 'later',
      gymName: 'Later Gym',
      startDate: DateTime(2025, 12, 1),
      durationMonths: 1,
      validUntil: DateTime(2026, 1, 1),
      priceMinor: 10000,
      currency: 'RON',
    );
    when(() => source.getAll(userId: userId)).thenAnswer((_) async => [laterUpcoming, upcoming, expired]);

    final result = await service.getRelevant(userId: userId, at: DateTime(2025, 6, 1));

    expect(result, upcoming);
  });

  test('getRelevant returns the membership that expired most recently', () async {
    final olderStartButLaterExpiry = GymMembership(
      id: 'long_membership',
      gymName: 'Long Membership Gym',
      startDate: DateTime(2024, 1, 1),
      durationMonths: 12,
      validUntil: DateTime(2025, 5, 1),
      priceMinor: 50000,
      currency: 'RON',
    );
    when(() => source.getAll(userId: userId)).thenAnswer((_) async => [expired, olderStartButLaterExpiry]);

    final result = await service.getRelevant(userId: userId, at: DateTime(2025, 6, 1));

    expect(result, olderStartButLaterExpiry);
  });

  test('update throws when membership no longer exists', () async {
    when(() => source.getById(userId: userId, membershipId: active.id)).thenAnswer((_) async => null);

    expect(() => service.update(userId: userId, membership: active), throwsA(isA<GymMembershipNotFoundException>()));
    verifyNever(
      () => source.update(
        userId: any(named: 'userId'),
        membership: any(named: 'membership'),
      ),
    );
  });
}
