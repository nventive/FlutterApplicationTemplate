import 'package:flutter/material.dart';

class GlobalThemeData {
  static ThemeData lightThemeData = themeData(lightColorScheme);
  static ThemeData darkThemeData = themeData(darkColorScheme);

  static ThemeData themeData(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Guillon',
      colorScheme: colorScheme,
    );
  }

  static const ColorScheme lightColorScheme = ColorScheme(
    primary: Color(0xFF0D59CD),
    onPrimary: Colors.white,
    secondary: Color(0xFF5BC5F2),
    onSecondary: Color(0xFF001E60),
    error: Color(0xFFD93B27),
    onError: Color(0xFFFDEFED),
    surface: Color(0xFFF5FAFF),
    onSurface: Color(0xFF001E60),
    brightness: Brightness.light,
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    primary: Color(0xFF89C5FF),
    onPrimary: Color(0xFF121821),
    secondary: Color(0xFFFCA58B),
    onSecondary: Color(0xFF302B29),
    error: Color(0xFFE8897D),
    onError: Color(0xFF32110D),
    surface: Color(0xFF2C3034),
    onSurface: Colors.white,
    brightness: Brightness.dark,
  );
}
