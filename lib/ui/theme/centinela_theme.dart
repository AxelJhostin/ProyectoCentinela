import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'centinela_spacing.dart';

/// Tokens del design system (Figma Wireframes MVP).
abstract final class CentinelaColors {
  static const background = Color(0xFFF9FAFB);
  static const surface = Colors.white;
  static const alertCritical = Color(0xFFDC2626);
  static const whatsApp = Color(0xFF25D366);
  static const community = Color(0xFF2563EB);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const border = Color(0xFFE5E7EB);
  static const mapGrid = Color(0xFFD1D5DB);
}

ThemeData buildCentinelaTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CentinelaColors.alertCritical,
      primary: CentinelaColors.alertCritical,
      surface: CentinelaColors.background,
    ),
    scaffoldBackgroundColor: CentinelaColors.background,
  );

  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: CentinelaColors.textPrimary,
      displayColor: CentinelaColors.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: CentinelaColors.surface,
      foregroundColor: CentinelaColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: CentinelaColors.textPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CentinelaColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: CentinelaSpacing.md,
        vertical: CentinelaSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        borderSide: const BorderSide(color: CentinelaColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        borderSide: const BorderSide(color: CentinelaColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        borderSide: const BorderSide(color: CentinelaColors.community, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        borderSide: const BorderSide(color: CentinelaColors.alertCritical),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CentinelaColors.alertCritical,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CentinelaSpacing.radiusMd),
        ),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}
