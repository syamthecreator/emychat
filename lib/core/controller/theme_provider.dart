import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized Theme Controller supporting Dark, Light, and System modes
/// with local persistent selection and zero flashing.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider({SharedPreferences? prefs}) {
    _prefs = prefs;
    _loadFromPrefs();
  }

  static const String _prefKey = 'emychat_theme_mode';
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;

  /// Check active brightness given the current BuildContext
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    _saveToPrefs(mode);
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      setThemeMode(ThemeMode.dark);
    }
  }

  Future<void> _loadFromPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final val = _prefs?.getString(_prefKey);
      if (val != null) {
        switch (val) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
          case 'dark':
          default:
            _themeMode = ThemeMode.dark;
            break;
        }
        notifyListeners();
      }
    } catch (_) {
      // Default to dark mode on error
    }
  }

  Future<void> _saveToPrefs(ThemeMode mode) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      String val = 'dark';
      if (mode == ThemeMode.light) val = 'light';
      if (mode == ThemeMode.system) val = 'system';
      await _prefs?.setString(_prefKey, val);
    } catch (_) {}
  }
}
