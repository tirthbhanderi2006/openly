import 'package:flutter/material.dart';
import 'package:mithc_koko_chat_app/utils/themes/light_mode.dart';
import 'package:mithc_koko_chat_app/utils/themes/dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  // Default theme set to light mode
  ThemeData _themeData = lightMode;

  // Getter for the current theme
  ThemeData get themeData => _themeData;

  // Getter to check if dark mode is active
  bool get isDarkMode => _themeData == darkMode;

  // Setter for theme data
  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners(); // Notify listeners of the theme change
  }

  // Method to toggle between light and dark mode
  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
  }
}
