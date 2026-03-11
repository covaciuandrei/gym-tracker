import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and exposes the user's preferred [ThemeMode].
///
/// Call [setDark] to toggle. [MyApp] should listen and rebuild on change.
class ThemeHelper extends ChangeNotifier {
  ThemeHelper(this._prefs) {
    final saved = _prefs.getBool(_key);
    if (saved != null) {
      _isDark = saved;
    }
  }

  static const String _key = 'app_theme_dark';

  bool _isDark = true; // dark is the default

  bool get isDark => _isDark;

  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDark(bool isDark) async {
    if (_isDark == isDark) return;
    _isDark = isDark;
    await _prefs.setBool(_key, isDark);
    notifyListeners();
  }

  final SharedPreferences _prefs;
}
