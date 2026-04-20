import 'package:flutter/material.dart';

// class ThemeController extends ChangeNotifier {
//
//   ThemeMode _themeMode = ThemeMode.system;
//
//   ThemeMode get themeMode => _themeMode;
//
//   // bool get isDarkMode => _themeMode == ThemeMode.dark;
//
//
//   bool isDark(BuildContext context) {
//     if (_themeMode == ThemeMode.system) {
//       return Theme.of(context).brightness == Brightness.dark;
//     }
//     return _themeMode == ThemeMode.dark;
//   }
//
//
//   void toggleTheme(bool isOn) {
//     _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
//     notifyListeners();
//   }
//
//   void changeTheme(ThemeMode mode) {
//     print("Chnage theme Provider ${mode}");
//     _themeMode = mode;
//     notifyListeners();
//   }
// }

class ThemeController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// MUST be called once at startup
  void resolveSystemTheme(BuildContext context) {
    if (_themeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      _themeMode =
      brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  void changeTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

