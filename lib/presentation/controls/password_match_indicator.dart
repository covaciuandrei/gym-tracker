import 'package:flutter/material.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';

/// Inline match indicator shown below the confirm-password field.
///
/// Mirrors Angular `.match-indicator`:
///   .match  → color #10b981 (success)
///   .no-match → color #ef4444 (danger)
///   font-size 12px
///
/// Hides itself when [confirmCtrl] is empty.
/// Reacts to changes in both controllers without setState.
class PasswordMatchIndicator extends StatelessWidget {
  const PasswordMatchIndicator({
    super.key,
    required this.passwordCtrl,
    required this.confirmCtrl,
  });

  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([passwordCtrl, confirmCtrl]),
      builder: (context, _) {
        if (confirmCtrl.text.isEmpty) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context);
        final matches = passwordCtrl.text == confirmCtrl.text;

        return Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            matches ? l10n.authPasswordsMatch : l10n.authPasswordsNoMatch,
            style: TextStyle(
              fontSize: 12,
              color: matches ? AppColors.success : AppColors.danger,
            ),
          ),
        );
      },
    );
  }
}
