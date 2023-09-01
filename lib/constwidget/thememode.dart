import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode? themeMode;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;

    notifyListeners();
  }
}

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: const ColorScheme.dark(),
  );

  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(),
    inputDecorationTheme: InputDecorationTheme(
      focusColor: Colors.green.shade500,
      iconColor: Colors.green.shade500,
    ),
  );
}
