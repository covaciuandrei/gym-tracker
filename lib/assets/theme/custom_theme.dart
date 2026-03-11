import 'package:flutter/material.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';

/// Provides the [darkTheme] and [lightTheme] [ThemeData] instances used
/// throughout the app.
abstract final class CustomTheme {
  // ── Full text theme (15-role M3 scale) ───────────────────────────────────
  //
  // | Role            | Size | Weight | Typical usage                         |
  // |-----------------|------|--------|---------------------------------------|
  // | displayLarge    |  32  |  w700  | Hero headings                         |
  // | displayMedium   |  28  |  w700  | Splash / marketing headings           |
  // | displaySmall    |  24  |  w600  | Page titles                           |
  // | headlineLarge   |  22  |  w600  | Card titles                           |
  // | headlineMedium  |  20  |  w600  | Dialog / sheet titles                 |
  // | headlineSmall   |  18  |  w600  | Sub-section titles                    |
  // | titleLarge      |  16  |  w600  | AppBar title, list headers            |
  // | titleMedium     |  15  |  w500  | List item primary text                |
  // | titleSmall      |  14  |  w500  | Settings section headers, badges      |
  // | bodyLarge       |  16  |  w400  | Body paragraphs                       |
  // | bodyMedium      |  14  |  w400  | Default body text                     |
  // | bodySmall       |  12  |  w400  | Helper / secondary text, labels       |
  // | labelLarge      |  14  |  w600  | Buttons, active tabs                  |
  // | labelMedium     |  12  |  w500  | Chips, badges                         |
  // | labelSmall      |  11  |  w600  | Section headers (all-caps)            |
  static TextTheme _buildTextTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color primary,
  }) {
    return TextTheme(
      // ── Display ──────────────────────────────────────────────────────────
      displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
      displayMedium: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
      displaySmall: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),
      // ── Headline ─────────────────────────────────────────────────────────
      headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
      headlineMedium: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),
      // ── Title ─────────────────────────────────────────────────────────────
      titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: TextStyle(
          fontSize: 15, fontWeight: FontWeight.w500, color: onSurface),
      titleSmall: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),
      // ── Body ──────────────────────────────────────────────────────────────
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant),
      // ── Label ─────────────────────────────────────────────────────────────
      labelLarge: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600, color: primary),
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: outline,
          letterSpacing: 1.2),
    );
  }

  // ── Dark theme (default) ─────────────────────────────────────────────────
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.primary,
      onSecondary: AppColors.textPrimary,
      tertiary: AppColors.healthTealDark,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.textMuted,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      dividerColor: AppColors.borderDark,
      textTheme: _buildTextTheme(
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.textMuted,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }

  // ── Light theme ──────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.primary,
      onSecondary: AppColors.textPrimary,
      tertiary: AppColors.healthTealLight,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.textMutedLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      dividerColor: AppColors.borderLight,
      textTheme: _buildTextTheme(
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        outline: AppColors.textMutedLight,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevatedLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: TextStyle(color: AppColors.textMutedLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textPrimary,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
    );
  }
}
