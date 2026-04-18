import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Modal bottom sheet content announcing a big (major or ≥2-minor) app
/// update. The sheet is purely presentational — the caller wires
/// [onUpdate] and [onLater] to launch the store URL and persist dismissal.
///
/// Typical usage (from [MainShellPage]):
/// ```
/// showModalBottomSheet<void>(
///   context: context,
///   isScrollControlled: true,
///   showDragHandle: true,
///   builder: (ctx) => BigUpdateBottomSheet(
///     latestVersion: status.latestVersion,
///     onUpdate: () => Navigator.of(ctx).pop('update'),
///     onLater: () => Navigator.of(ctx).pop('later'),
///   ),
/// );
/// ```
class BigUpdateBottomSheet extends StatelessWidget {
  const BigUpdateBottomSheet({super.key, required this.latestVersion, required this.onUpdate, required this.onLater});

  /// Latest released version as advertised by remote config. Rendered inside
  /// the localized body text.
  final String latestVersion;

  /// Called when the user taps the primary action. The caller is responsible
  /// for closing the sheet and opening the store URL.
  final VoidCallback onUpdate;

  /// Called when the user taps the secondary "Remind me later" action. The
  /// caller closes the sheet and persists a 3-day dismissal.
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Center(child: EmojiText(Emojis.rocket, style: TextStyle(fontSize: 56))),
            const SizedBox(height: 16),
            Text(
              l10n.bigUpdateTitle,
              style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.bigUpdateBody(latestVersion),
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(label: l10n.bigUpdateAction, isLoading: false, onTap: onUpdate),
            const SizedBox(height: 8),
            TextButton(onPressed: onLater, child: Text(l10n.bigUpdateLater)),
          ],
        ),
      ),
    );
  }
}
