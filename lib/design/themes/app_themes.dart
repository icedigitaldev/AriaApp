import 'package:flutter/material.dart';

class AppThemes {
  static Brightness _brightness = Brightness.light;

  static void init(BuildContext context) {
    _brightness = Theme.of(context).brightness;
  }

  static bool get isDarkMode => _brightness == Brightness.dark;

  static Color select(Color light, Color dark) => isDarkMode ? dark : light;
}
