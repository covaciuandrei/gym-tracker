import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper that persists and exposes the user's preferred [Locale].
///
/// The locale is stored in [SharedPreferences] under [_key].
/// Supported locales mirror the ARB files: English (`en`) and Romanian (`ro`).
class LocaleHelper extends ChangeNotifier {
  LocaleHelper(this._prefs) {
    final saved = _prefs.getString(_key);
    if (saved != null) {
      _locale = Locale(saved);
    }
  }

  static const String _key = 'app_locale';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ro'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_key, locale.languageCode);
    notifyListeners();
  }

  final SharedPreferences _prefs;
}
