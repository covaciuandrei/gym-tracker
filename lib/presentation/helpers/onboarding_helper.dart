import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes whether the app is being launched for the first time.
///
/// [isFirstLaunch] returns `true` until [completeOnboarding] is called (which
/// happens on the user's first successful sign-in).
class OnboardingHelper {
  OnboardingHelper(this._prefs);

  static const String _key = 'app_onboarding_complete';

  final SharedPreferences _prefs;

  bool get isFirstLaunch => !(_prefs.getBool(_key) ?? false);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(_key, true);
  }
}
