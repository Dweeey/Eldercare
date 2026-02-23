import 'package:flutter/material.dart';

/// Simple app-wide theme controller.
///
/// - Call ThemeProvider.of(context).toggleTheme() or setTheme(true/false)
///   to switch between light and dark mode.
/// - main.dart listens to this via a Consumer and updates MaterialApp.themeMode.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// Toggle between light and dark theme.
  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Set theme explicitly: [dark] = true for dark mode, false for light.
  void setTheme(bool dark) {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
