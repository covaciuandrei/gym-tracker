import 'package:flutter/material.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/custom_text_field.dart';
import 'package:gym_tracker/presentation/controls/error_banner.dart';
import 'package:gym_tracker/presentation/controls/form_card.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/controls/password_match_indicator.dart';
import 'package:gym_tracker/presentation/controls/password_strength_indicator.dart';

/// Reusable set-/change-password form used in both the password-reset (auth
/// action) and the in-app change-password (settings) flows.
///
/// Pass [currentPasswordCtrl] to show a "Current Password" field above the
/// new-password section — required for the settings change-password flow where
/// Firebase needs re-authentication via the current password.
///
/// Example — password reset (auth action page):
/// ```dart
/// SetPasswordCard(
///   title: l10n.authActionSetNewPasswordTitle,
///   subtitle: 'Create a new password for $email',
///   buttonLabel: l10n.authActionResetPasswordButton,
///   formKey: _formKey,
///   passwordCtrl: _passwordCtrl,
///   confirmCtrl: _confirmCtrl,
///   isLoading: isLoading,
///   onSubmit: _onSubmit,
/// )
/// ```
///
/// Example — change password (settings page):
/// ```dart
/// SetPasswordCard(
///   title: l10n.settingsChangePassword,
///   buttonLabel: l10n.settingsChangePassword,
///   formKey: _formKey,
///   currentPasswordCtrl: _currentPasswordCtrl,
///   passwordCtrl: _passwordCtrl,
///   confirmCtrl: _confirmCtrl,
///   isLoading: isLoading,
///   onSubmit: _onSubmit,
///   errorMessage: errorMessage,   // e.g. l10n.errorsInvalidCredentials
/// )
/// ```
class SetPasswordCard extends StatelessWidget {
  const SetPasswordCard({
    super.key,
    this.icon = '🔒',
    required this.title,
    this.subtitle,
    required this.buttonLabel,
    required this.formKey,
    this.currentPasswordCtrl,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onSubmit,
    this.errorMessage,
  });

  /// Emoji displayed at the top of the header. Defaults to `'🔒'`.
  final String icon;

  /// Primary title rendered below the [icon].
  final String title;

  /// Optional subtitle rendered below [title] (e.g. "Create a new password for
  /// user@example.com").
  final String? subtitle;

  /// Label for the submit [GradientButton].
  final String buttonLabel;

  final GlobalKey<FormState> formKey;

  /// When non-null, a "Current Password" field is rendered above the new
  /// password section. Used in the settings change-password flow.
  final TextEditingController? currentPasswordCtrl;

  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  /// When non-null, an [ErrorBanner] is shown inside the card above the submit
  /// button. Useful when the error should not replace the form (e.g. wrong
  /// current password in the settings flow).
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final labelStyle = tt.bodySmall?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: cs.onSurface,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ── Header ───────────────────────────────────────────────────────────
        Text(icon, style: const TextStyle(fontSize: 48)),
        const SizedBox(height: 16),
        Text(
          title,
          style: tt.headlineLarge?.copyWith(
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 32),
        // ── Form ─────────────────────────────────────────────────────────────
        FormCard(
          formKey: formKey,
          children: [
            // ── Current password (settings change-password only) ─────────────
            if (currentPasswordCtrl != null) ...[
              Text(l10n.settingsCurrentPassword, style: labelStyle),
              const SizedBox(height: 8),
              CustomTextField(
                controller: currentPasswordCtrl!,
                label: l10n.settingsCurrentPassword,
                isPassword: true,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.password],
                enabled: !isLoading,
                validator: (v) {
                  if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
                  return null;
                },
              ),
              const SizedBox(height: 20),
            ],
            // ── New password ─────────────────────────────────────────────────
            Text(l10n.settingsNewPassword, style: labelStyle),
            const SizedBox(height: 8),
            CustomTextField(
              controller: passwordCtrl,
              label: l10n.settingsNewPassword,
              isPassword: true,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !isLoading,
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
                if (v.length < 8) return l10n.errorsPasswordTooShort;
                if (!v.contains(RegExp(r'[A-Z]')) ||
                    !v.contains(RegExp(r'[a-z]')) ||
                    !v.contains(RegExp(r'[0-9]'))) {
                  return l10n.errorsWeakPassword;
                }
                return null;
              },
            ),
            PasswordStrengthIndicator(controller: passwordCtrl),
            const SizedBox(height: 20),
            // ── Confirm password ─────────────────────────────────────────────
            Text(l10n.authRegisterConfirmPassword, style: labelStyle),
            const SizedBox(height: 8),
            CustomTextField(
              controller: confirmCtrl,
              label: l10n.authRegisterConfirmPassword,
              isPassword: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.newPassword],
              enabled: !isLoading,
              onFieldSubmitted: isLoading ? null : (_) => onSubmit(),
              validator: (v) {
                if (v == null || v.isEmpty) return l10n.errorsFieldRequired;
                if (v != passwordCtrl.text) return l10n.errorsPasswordMismatch;
                return null;
              },
            ),
            PasswordMatchIndicator(
              passwordCtrl: passwordCtrl,
              confirmCtrl: confirmCtrl,
            ),
            const SizedBox(height: 20),
            // ── Inline error banner (optional) ───────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: errorMessage != null
                  ? Column(
                      key: ValueKey(errorMessage),
                      children: [
                        ErrorBanner(message: errorMessage!),
                        const SizedBox(height: 20),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            // ── Submit ───────────────────────────────────────────────────────
            GradientButton(
              label: buttonLabel,
              isLoading: isLoading,
              onTap: onSubmit,
            ),
          ],
        ),
      ],
    );
  }
}
