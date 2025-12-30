import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for managing app theme (light/dark mode)
class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _isInitialized;

  /// Initialize theme from saved preferences
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themeKey);

      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preference: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }

  /// Set specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _themeKey,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (e) {
      print('Error saving theme preference: $e');
    }
  }
}
