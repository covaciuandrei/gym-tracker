import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the Calendar membership-reminder dismissal and applies the grace
/// period for accounts that have never recorded a membership.
@injectable
class MembershipReminderService {
  const MembershipReminderService();

  /// New accounts are given time to explore the app before the first missing
  /// membership reminder is shown.
  static const Duration initialReminderDelay = Duration(hours: 2);

  static String dismissedPrefsKey(String userId) => 'membership_reminder_dismissed_$userId';

  Future<bool> isPermanentlyDismissed({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(dismissedPrefsKey(userId)) ?? false;
  }

  Future<void> rememberPermanentDismissal({required String userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(dismissedPrefsKey(userId), true);
  }

  /// Remaining grace period for an account with no membership history.
  ///
  /// A missing creation timestamp is treated as an established account so a
  /// migrated user is not kept in the grace period forever.
  Duration remainingInitialDelay({required DateTime? accountCreatedAt, DateTime? now}) {
    if (accountCreatedAt == null) return Duration.zero;

    final eligibleAt = accountCreatedAt.add(initialReminderDelay);
    final remaining = eligibleAt.difference(now ?? DateTime.now());
    if (remaining.isNegative) return Duration.zero;
    if (remaining > initialReminderDelay) return initialReminderDelay;
    return remaining;
  }
}
