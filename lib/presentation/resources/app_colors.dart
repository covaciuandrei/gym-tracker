import 'package:flutter/material.dart';

/// All color constants for the Gym Tracker app.
///
/// Dark mode is the default theme. Light mode uses inverted values for the
/// neutral surfaces while reusing the accent and semantic colors.
abstract final class AppColors {
  // ── Accent ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFF6C63FF);

  // ── Dark-theme surfaces ──────────────────────────────────────────────────
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceElevatedDark = Color(0xFF252525);
  static const Color borderDark = Color(0xFF333333);

  // ── Light-theme surfaces ─────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFEEEEEE);
  static const Color borderLight = Color(0xFFCCCCCC);

  // ── Text (dark theme) ────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF888888);
  static const Color textMuted = Color(0xFF555555);

  // ── Text (light theme) ──────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF0F0F0F);
  static const Color textSecondaryLight = Color(0xFF555555);
  static const Color textMutedLight = Color(0xFF888888);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF6C63FF); // same as accent
  static const Color danger = Color(0xFFFF4444);
  static const Color warning = Color(0xFFFF9800);
}
