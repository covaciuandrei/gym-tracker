// Unit tests for CheckingUpdateService.
//
// url_launcher is a plugin and cannot be exercised from a unit test, so only
// the prefs + cool-down rules are covered here (launchStoreUrl is verified
// indirectly via the cubit-level tests).

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/service/checking_update/checking_update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppVersionStatus status;
  late CheckingUpdateService sut;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    status = AppVersionStatus();
    sut = CheckingUpdateService(status);
  });

  group('shouldShowBigUpdate', () {
    test('returns false when bigUpdateAvailable is false', () async {
      status
        ..bigUpdateAvailable = false
        ..latestVersion = '3.0.0';

      expect(await sut.shouldShowBigUpdate(), isFalse);
    });

    test('returns false when latestVersion is empty', () async {
      status
        ..bigUpdateAvailable = true
        ..latestVersion = '';

      expect(await sut.shouldShowBigUpdate(), isFalse);
    });

    test('returns true when eligible and no dismissal recorded', () async {
      status
        ..bigUpdateAvailable = true
        ..latestVersion = '3.0.0';

      expect(await sut.shouldShowBigUpdate(), isTrue);
    });

    test('returns false when dismissed for the same version within the cool-down', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        CheckingUpdateService.dismissedVersionPrefsKey: '3.0.0',
        CheckingUpdateService.dismissedAtPrefsKey: DateTime.now().millisecondsSinceEpoch,
      });
      status
        ..bigUpdateAvailable = true
        ..latestVersion = '3.0.0';

      expect(await sut.shouldShowBigUpdate(), isFalse);
    });

    test('returns true when the dismissal is older than the cool-down', () async {
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      SharedPreferences.setMockInitialValues(<String, Object>{
        CheckingUpdateService.dismissedVersionPrefsKey: '3.0.0',
        CheckingUpdateService.dismissedAtPrefsKey: fourDaysAgo.millisecondsSinceEpoch,
      });
      status
        ..bigUpdateAvailable = true
        ..latestVersion = '3.0.0';

      expect(await sut.shouldShowBigUpdate(), isTrue);
    });

    test('returns true when the dismissed version differs from the latest', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        CheckingUpdateService.dismissedVersionPrefsKey: '2.0.0',
        CheckingUpdateService.dismissedAtPrefsKey: DateTime.now().millisecondsSinceEpoch,
      });
      status
        ..bigUpdateAvailable = true
        ..latestVersion = '3.0.0';

      expect(await sut.shouldShowBigUpdate(), isTrue);
    });
  });

  group('rememberDismissal', () {
    test('writes the current latest version + now() into SharedPreferences', () async {
      status
        ..bigUpdateAvailable = true
        ..latestVersion = '3.0.0';

      await sut.rememberDismissal();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(CheckingUpdateService.dismissedVersionPrefsKey), '3.0.0');
      expect(prefs.getInt(CheckingUpdateService.dismissedAtPrefsKey), isNotNull);
    });
  });
}
