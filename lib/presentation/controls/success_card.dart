import 'package:flutter/material.dart';

import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';

/// Reusable success confirmation card.
///
/// Shown after a successful async action (e.g. account creation, password
/// reset). Renders a coloured banner with an [icon], [title], [message], and
/// a primary [GradientButton] that calls [onAction].
class SuccessCard extends StatelessWidget {
  const SuccessCard({
    super.key,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onAction,
    this.icon = '✅',
  });

  /// Emoji or short glyph shown at the top of the card.
  final String icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            title,
            style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GradientButton(
            label: buttonLabel,
            isLoading: false,
            onTap: onAction,
          ),
        ],
      ),
    );
  }
}
