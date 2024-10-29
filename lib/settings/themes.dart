import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();
  static const primaryColor = Colors.blue;
  static const _shadowColor = Colors.black;
  static final ThemeData defaultTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        shadow: _shadowColor),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black, fontSize: 15),
    ),
  );
}
