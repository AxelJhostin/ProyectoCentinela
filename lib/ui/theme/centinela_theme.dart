import 'package:flutter/material.dart';

/// Tokens del design system (Figma Wireframes MVP).
abstract final class CentinelaColors {
  static const background = Color(0xFFF9FAFB);
  static const alertCritical = Color(0xFFDC2626);
  static const whatsApp = Color(0xFF25D366);
  static const community = Color(0xFF2563EB);
}

ThemeData buildCentinelaTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CentinelaColors.alertCritical,
      primary: CentinelaColors.alertCritical,
      surface: CentinelaColors.background,
    ),
    scaffoldBackgroundColor: CentinelaColors.background,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: CentinelaColors.alertCritical,
      foregroundColor: Colors.white,
    ),
  );
}
