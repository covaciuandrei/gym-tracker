import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/gym_membership.dart';

void main() {
  group('MembershipDuration', () {
    test('one-month option adds exactly 30 date-only days', () {
      expect(MembershipDuration.oneMonth.validUntilFrom(DateTime(2026, 7, 22, 18)), DateTime(2026, 8, 21));
      expect(MembershipDuration.oneMonth.validUntilFrom(DateTime(2025, 1, 31)), DateTime(2025, 3, 2));
    });

    test('longer options use calendar months and clamp end-of-month dates', () {
      expect(MembershipDuration.threeMonths.validUntilFrom(DateTime(2025, 11, 30)), DateTime(2026, 2, 28));
      expect(MembershipDuration.sixMonths.validUntilFrom(DateTime(2025, 8, 31)), DateTime(2026, 2, 28));
      expect(MembershipDuration.twelveMonths.validUntilFrom(DateTime(2024, 2, 29)), DateTime(2025, 2, 28));
    });

    test('maps supported month counts and defaults unknown values', () {
      expect(MembershipDuration.fromMonths(6), MembershipDuration.sixMonths);
      expect(MembershipDuration.fromMonths(2), MembershipDuration.oneMonth);
    });
  });

  group('GymMembership status', () {
    final membership = GymMembership(
      id: 'membership_1',
      gymName: 'Test Gym',
      startDate: DateTime(2025, 6, 1),
      durationMonths: 1,
      validUntil: DateTime(2025, 7, 1),
      priceMinor: 15000,
      currency: 'RON',
    );

    test('treats start and valid-until dates as inclusive', () {
      expect(membership.isActiveAt(DateTime(2025, 6, 1, 23)), isTrue);
      expect(membership.isActiveAt(DateTime(2025, 7, 1, 23)), isTrue);
      expect(membership.isExpiredAt(DateTime(2025, 7, 2)), isTrue);
      expect(membership.isUpcomingAt(DateTime(2025, 5, 31)), isTrue);
    });

    test('returns date-only remaining days', () {
      expect(membership.daysRemainingAt(DateTime(2025, 6, 30, 22)), 1);
      expect(membership.daysRemainingAt(DateTime(2025, 7, 2)), 0);
    });

    test('new one-month period starts with 30 days remaining', () {
      final startDate = DateTime(2026, 7, 22);
      final oneMonthMembership = GymMembership(
        id: 'one_month',
        gymName: 'Test Gym',
        startDate: startDate,
        durationMonths: 1,
        validUntil: MembershipDuration.oneMonth.validUntilFrom(startDate),
        priceMinor: 15000,
        currency: 'RON',
      );

      expect(oneMonthMembership.validUntil, DateTime(2026, 8, 21));
      expect(oneMonthMembership.daysRemainingAt(startDate), 30);
    });
  });

  test('copy draft preserves details and accepts a new start date', () {
    final membership = GymMembership(
      id: 'membership_1',
      gymName: 'Test Gym',
      startDate: DateTime(2025, 1, 1),
      durationMonths: 3,
      validUntil: DateTime(2025, 4, 1),
      priceMinor: 20000,
      currency: 'RON',
    );
    final draft = GymMembershipDraft.fromMembership(membership, startDate: DateTime(2026, 7, 21));

    expect(draft.gymName, membership.gymName);
    expect(draft.duration, MembershipDuration.threeMonths);
    expect(draft.priceMinor, membership.priceMinor);
    expect(draft.currency, membership.currency);
    expect(draft.startDate, DateTime(2026, 7, 21));
    expect(draft.validUntil, DateTime(2026, 10, 21));
  });
}
