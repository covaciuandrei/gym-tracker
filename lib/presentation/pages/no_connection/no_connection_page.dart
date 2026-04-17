import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Full-screen blocker shown when the remote config cannot be fetched on
/// launch. The app does not support offline use, so a retry is the only path
/// forward.
@RoutePage()
class NoConnectionPage extends StatelessWidget {
  const NoConnectionPage({super.key});

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
                  EmojiText(Emojis.satelliteAntenna, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 24),
                  Text(l10n.noConnectionTitle, textAlign: TextAlign.center, style: tt.headlineSmall),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noConnectionBody,
                    textAlign: TextAlign.center,
                    style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 40),
                  GradientButton(
                    label: l10n.noConnectionRetry,
                    isLoading: false,
                    onTap: () => context.router.replaceAll([const SplashRoute()]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
