import 'package:flutter/material.dart';

/// Reusable auth-screen footer: a [Divider] followed by a centred prompt
/// text and a tappable action label.
///
/// Used at the bottom of every auth screen to navigate between pages
/// (e.g. "Already have an account? **Sign in**").
///
/// Set [enabled] to `!isLoading` to disable the button while a cubit
/// request is in flight, preventing double-navigation.
class AuthFooterLink extends StatelessWidget {
  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    required this.onTap,
    this.enabled = true,
  });

  /// Plain-text prefix shown before the action button.
  final String prompt;

  /// Clickable label, e.g. "Sign in".
  final String actionLabel;

  /// Called when the action button is tapped.
  final VoidCallback onTap;

  /// Whether the button responds to taps. Defaults to `true`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(color: cs.outline, thickness: 1),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            Text(
              prompt,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: enabled ? onTap : null,
              child: Text(
                actionLabel,
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
