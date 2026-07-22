import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/service/membership/membership_reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const userId = 'user_1';
  const service = MembershipReminderService();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('applies a two-hour grace period to new accounts', () {
    final createdAt = DateTime(2026, 7, 21, 10);

    expect(
      service.remainingInitialDelay(accountCreatedAt: createdAt, now: DateTime(2026, 7, 21, 11)),
      const Duration(hours: 1),
    );
    expect(service.remainingInitialDelay(accountCreatedAt: createdAt, now: DateTime(2026, 7, 21, 12)), Duration.zero);
    expect(
      service.remainingInitialDelay(accountCreatedAt: DateTime(2026, 7, 21, 13), now: DateTime(2026, 7, 21, 12)),
      MembershipReminderService.initialReminderDelay,
    );
  });

  test('treats a missing account creation timestamp as already eligible', () {
    expect(service.remainingInitialDelay(accountCreatedAt: null), Duration.zero);
  });

  test('persists dismissal forever for the selected user only', () async {
    expect(await service.isPermanentlyDismissed(userId: userId), isFalse);

    await service.rememberPermanentDismissal(userId: userId);

    expect(await service.isPermanentlyDismissed(userId: userId), isTrue);
    expect(await service.isPermanentlyDismissed(userId: 'user_2'), isFalse);
  });
}
