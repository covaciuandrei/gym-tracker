import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Full-screen blocker shown when remote config has `maintenanceMode: true`.
///
/// Retry re-runs the gate by replacing the stack with Splash.
@RoutePage()
class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key, required this.message});

  /// Localized maintenance message picked from remote config by the splash gate.
  final String message;

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
                  EmojiText(Emojis.hammerAndWrench, style: const TextStyle(fontSize: 72)),
                  const SizedBox(height: 24),
                  Text(l10n.maintenanceTitle, textAlign: TextAlign.center, style: tt.headlineSmall),
                  if (message.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 40),
                  GradientButton(
                    label: l10n.maintenanceRetry,
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
