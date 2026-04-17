import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';

/// Dismissible banner shown at the top of the main shell when a newer app
/// version is available but the current version is still above the min
/// required threshold.
///
/// Pure view — dismissal persistence (e.g. SharedPreferences) must be handled
/// by the caller via [onDismiss].
class SoftUpdateBanner extends StatelessWidget {
  const SoftUpdateBanner({super.key, required this.latestVersion, required this.onUpdate, required this.onDismiss});

  /// Latest version string pulled from remote config. Displayed next to the
  /// banner message so the user knows what they're updating to.
  final String latestVersion;

  /// Called when the user taps the primary action. Should open the store URL.
  final VoidCallback onUpdate;

  /// Called when the user dismisses the banner. The caller should persist the
  /// dismissed version so the banner does not reappear until [latestVersion]
  /// changes.
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.softUpdateBannerMessage,
                    style: tt.bodyMedium?.copyWith(color: cs.onPrimaryContainer, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'v$latestVersion',
                    style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onUpdate,
              style: TextButton.styleFrom(foregroundColor: cs.onPrimaryContainer),
              child: Text(l10n.softUpdateBannerAction),
            ),
            IconButton(
              tooltip: l10n.softUpdateBannerDismiss,
              icon: Icon(Icons.close, color: cs.onPrimaryContainer),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
