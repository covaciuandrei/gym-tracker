import 'package:flutter/material.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';

/// Provides the [darkTheme] and [lightTheme] [ThemeData] instances used
/// throughout the app.
abstract final class CustomTheme {
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
    required Color primary,
  }) {
    return TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: onSurface),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: onSurface),
      displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: onSurface),

      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: onSurface),
      headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: onSurface),

      titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: onSurface),
      titleMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: onSurface),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: onSurface),

      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: onSurface),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: onSurface),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: onSurfaceVariant),

      // labelLarge: no color set — inherits from parent (e.g. button foreground)
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: onSurfaceVariant),
      // labelSmall: used for section headers (ABOUT, SECURITY, etc.)
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: onSurfaceVariant, letterSpacing: 1.2),
    );
  }

  static ThemeData get darkTheme {
    // ColorScheme maps 1-to-1 with Angular CSS variables:
    //   surface              = --card-bg    (#1e293b, Slate 800)
    //   surfaceContainerHigh = --card-bg    (same, for card widgets)
    //   surfaceContainerHighest = --surface-overlay (#334155, Slate 700)
    //   surfaceContainerLow  = --bg-color   (#0f172a, Slate 900)
    //   outline              = --border-color (#334155)
    //   primaryContainer     = --primary-light overlay (~rgba(99,102,241,0.2))
    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainerDark,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primaryContainerDark,
      onSecondaryContainer: AppColors.primary,
      tertiary: AppColors.statsCyan,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.borderDark,
      outlineVariant: AppColors.surfaceElevatedDark,
      surfaceContainerLow: AppColors.backgroundDark,
      surfaceContainer: AppColors.surfaceDark,
      surfaceContainerHigh: AppColors.surfaceDark,
      surfaceContainerHighest: AppColors.surfaceElevatedDark,
    );

    return ThemeData(
      fontFamily: 'Raleway',
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.surfaceDark,
      dividerColor: AppColors.borderDark,
      textTheme: _buildTextTheme(
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      // M3 NavigationBar — mirrors Angular bottom-nav:
      //   active item: primary color + primary-light indicator pill
      //   inactive item: text-secondary
      //   background: card-bg (--card-bg with top border)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        indicatorColor: AppColors.primaryContainerDark,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      // Cards: 16px radius + 1px border (Angular card / supplement-card pattern)
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderDark),
        ),
      ),
      // Inputs: 12px radius + 2px border (Angular: border-radius 0.75rem, border 2px)
      // fill = backgroundDark so inputs look recessed inside cards
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.borderDark, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.borderDark, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintStyle: TextStyle(color: AppColors.textMuted),
      ),
      // Primary button: gradient in Angular (.btn-primary), use solid primary here
      // Gradient can be applied per-widget with Ink(decoration: BoxDecoration(gradient:...))
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      // Secondary/Cancel button (.btn-secondary in Angular)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: const BorderSide(color: AppColors.borderDark),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
    );
  }

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryContainerLight,
      onPrimaryContainer: AppColors.primary,
      secondary: AppColors.primary,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.primaryContainerLight,
      onSecondaryContainer: AppColors.primary,
      tertiary: AppColors.statsCyan,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      outline: AppColors.borderLight,
      outlineVariant: AppColors.surfaceElevatedLight,
      surfaceContainerLow: AppColors.backgroundLight,
      surfaceContainer: AppColors.surfaceLight,
      surfaceContainerHigh: AppColors.surfaceLight,
      surfaceContainerHighest: AppColors.surfaceElevatedLight,
    );

    return ThemeData(
      fontFamily: 'Raleway',
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.surfaceLight,
      dividerColor: AppColors.borderLight,
      textTheme: _buildTextTheme(
        onSurface: AppColors.textPrimaryLight,
        onSurfaceVariant: AppColors.textSecondaryLight,
        primary: AppColors.primary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        indicatorColor: AppColors.primaryContainerLight,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          return IconThemeData(
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondaryLight,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return TextStyle(
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
            color: states.contains(WidgetState.selected) ? AppColors.primary : AppColors.textSecondaryLight,
          );
        }),
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
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.borderLight),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.borderLight, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.borderLight, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondaryLight),
        hintStyle: TextStyle(color: AppColors.textMutedLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondaryLight,
          side: const BorderSide(color: AppColors.borderLight),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary)),
    );
  }
}
