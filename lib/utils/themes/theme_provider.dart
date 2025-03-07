import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mithc_koko_chat_app/utils/themes/light_mode.dart';
import 'package:mithc_koko_chat_app/utils/themes/dark_mode.dart';

class ThemeProvider extends ChangeNotifier {
  final GetStorage _storage = GetStorage();
  static const String _themeKey = 'isDarkMode';
  static const String _fontKey = 'selectedFont';

  ThemeData _themeData;
  String _selectedFont;

  ThemeProvider()
      : _themeData = (GetStorage().read<bool>(_themeKey) ?? false)
            ? darkMode
            : lightMode,
        _selectedFont = GetStorage().read<String>(_fontKey) ?? 'Recursive';

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData == darkMode;
  String get selectedFont => _selectedFont;

  void toggleTheme() {
    _themeData = isDarkMode ? lightMode : darkMode;
    _storage.write(_themeKey, isDarkMode);
    notifyListeners();
  }

  void updateFont(String font) {
    _selectedFont = font;
    _storage.write(_fontKey, font);
    notifyListeners();
  }

  ThemeData getThemeWithFont() {
    // notifyListeners();
    return _themeData.copyWith(
      textTheme: GoogleFonts.getTextTheme(_selectedFont),
    );
  }
}
