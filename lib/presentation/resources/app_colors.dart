import 'package:flutter/material.dart';

/// All color constants for the Gym Tracker app.
///
/// Colors are sourced from the Angular reference app's CSS design system
/// (src/styles.css) and match the Tailwind Slate & Indigo scale exactly.
///
/// Dark mode is the default theme. Light mode uses inverted surface values
/// while reusing accent and semantic colors.
abstract final class AppColors {
  // ── Primary — Angular --primary-color / --primary-dark ──────────────────
  // Tailwind Indigo 500 / Indigo 600
  static const Color primary     = Color(0xFF6366F1); // #6366f1
  static const Color primaryDark = Color(0xFF4F46E5); // #4f46e5

  // ── Dark-theme surfaces — Tailwind Slate scale ───────────────────────────
  // Angular: --bg-color / --card-bg / --surface-overlay / --border-color
  static const Color backgroundDark      = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark         = Color(0xFF1E293B); // Slate 800
  static const Color surfaceElevatedDark = Color(0xFF334155); // Slate 700
  static const Color borderDark          = Color(0xFF334155); // Slate 700

  // ── Light-theme surfaces — Tailwind Slate scale ──────────────────────────
  // Angular: --bg-color / --card-bg / --surface-ground / --border-color
  static const Color backgroundLight      = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceLight         = Color(0xFFFFFFFF); // White
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9); // Slate 100
  static const Color borderLight          = Color(0xFFE2E8F0); // Slate 200

  // ── Primary containers — rgba(primary, 0.2) composited over surface ──────
  // Used for NavigationBar indicator, avatar backgrounds, selected states
  static const Color primaryContainerDark  = Color(0xFF2C355F); // indigo 0.2 over Slate 800
  static const Color primaryContainerLight = Color(0xFFEEF2FF); // Indigo 50

  // ── Text — dark theme ────────────────────────────────────────────────────
  // Angular: --text-primary / --text-secondary
  static const Color textPrimary    = Color(0xFFF1F5F9); // Slate 100
  static const Color textSecondary  = Color(0xFF94A3B8); // Slate 400
  static const Color textMuted      = Color(0xFF64748B); // Slate 500

  // ── Text — light theme ──────────────────────────────────────────────────
  static const Color textPrimaryLight    = Color(0xFF1E293B); // Slate 800
  static const Color textSecondaryLight  = Color(0xFF64748B); // Slate 500
  static const Color textMutedLight      = Color(0xFF94A3B8); // Slate 400

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success     = Color(0xFF10B981); // Emerald 500
  static const Color danger      = Color(0xFFEF4444); // Red 500
  static const Color warning     = Color(0xFFF59E0B); // Amber 500
  // Angular --accent-green (verified badge text color)
  static const Color accentGreen = Color(0xFF097853);

  // ── Calendar activity states — Angular --cal-* variables ────────────────
  static const Color calWorkout    = Color(0xFF3B82F6); // Blue 500   --cal-workout
  static const Color calSupplement = Color(0xFF10B981); // Emerald 500 --cal-supp
  static const Color calBoth       = Color(0xFF06B6D4); // Cyan 500   --cal-both

  // ── Stats gradient palette ───────────────────────────────────────────────
  // Sourced from stats-shared.css gradient fills on stat-card variants
  static const Color statsPink        = Color(0xFFEC4899); // Pink 500
  static const Color statsPinkDark    = Color(0xFFBE185D); // Pink 700
  static const Color statsViolet      = Color(0xFF8B5CF6); // Violet 500
  static const Color statsVioletDark  = Color(0xFF7C3AED); // Violet 600
  static const Color statsEmerald     = Color(0xFF10B981); // Emerald 500
  static const Color statsEmeraldDark = Color(0xFF059669); // Emerald 600
  static const Color statsTeal        = Color(0xFF14B8A6); // Teal 500
  static const Color statsTealDark    = Color(0xFF0D9488); // Teal 600
  static const Color statsCyan        = Color(0xFF06B6D4); // Cyan 500
  static const Color statsCyanDark    = Color(0xFF0891B2); // Cyan 600
}
