import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingHelper', () {
    test('isFirstLaunch returns true when no preference is set', () {
      SharedPreferences.setMockInitialValues({});
      return SharedPreferences.getInstance().then((prefs) {
        final helper = OnboardingHelper(prefs);
        expect(helper.isFirstLaunch, isTrue);
      });
    });

    test('isFirstLaunch returns false after completeOnboarding', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final helper = OnboardingHelper(prefs);

      await helper.completeOnboarding();

      expect(helper.isFirstLaunch, isFalse);
    });

    test(
      'isFirstLaunch returns false when preference is already true',
      () async {
        SharedPreferences.setMockInitialValues({
          'app_onboarding_complete': true,
        });
        final prefs = await SharedPreferences.getInstance();
        final helper = OnboardingHelper(prefs);

        expect(helper.isFirstLaunch, isFalse);
      },
    );

    test('isFirstLaunch returns true when preference is false', () async {
      SharedPreferences.setMockInitialValues({
        'app_onboarding_complete': false,
      });
      final prefs = await SharedPreferences.getInstance();
      final helper = OnboardingHelper(prefs);

      expect(helper.isFirstLaunch, isTrue);
    });
  });
}
