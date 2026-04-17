import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen blocker shown when the installed app version is below the
/// minimum required version from remote config.
///
/// Has no back button — the app cannot continue until the user updates.
@RoutePage()
class ForceUpdatePage extends StatelessWidget {
  const ForceUpdatePage({
    super.key,
    required this.currentVersion,
    required this.requiredVersion,
    required this.storeUrl,
  });

  final String currentVersion;
  final String requiredVersion;
  final String storeUrl;

  Future<void> _openStore() async {
    final uri = Uri.tryParse(storeUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmojiText(Emojis.rocket, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 24),
                  Text(l10n.forceUpdateTitle, textAlign: TextAlign.center, style: tt.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    l10n.forceUpdateBody,
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 32),
                  _VersionRow(label: l10n.forceUpdateCurrentVersion, value: currentVersion),
                  const SizedBox(height: 8),
                  _VersionRow(label: l10n.forceUpdateRequiredVersion, value: requiredVersion, highlight: true),
                  const SizedBox(height: 40),
                  GradientButton(label: l10n.forceUpdateButton, isLoading: false, onTap: _openStore),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.label, required this.value, this.highlight = false});

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        Text(
          value,
          style: tt.titleMedium?.copyWith(color: highlight ? cs.primary : cs.onSurface, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
