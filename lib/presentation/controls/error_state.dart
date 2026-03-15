import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Full-section error state with an emoji icon, title, message and optional
/// action buttons.
///
/// Mirrors Angular `.error-state` (auth-action.component):
///   centered column · emoji 4rem · h1 1.75rem/700 · p 1rem/secondary
///   action buttons in a row below the message
///
/// Usage — single retry button:
/// ```dart
/// ErrorStateWidget(
///   message: 'Could not load data.',
///   onRetry: () => cubit.reload(),
/// )
/// ```
///
/// Usage — custom action buttons:
/// ```dart
/// ErrorStateWidget(
///   emoji: Emojis.warning,
///   title: 'Something went wrong',
///   message: errorMessage,
///   actions: [
///     ElevatedButton(onPressed: () {}, child: const Text('Try Again')),
///     OutlinedButton(onPressed: () {}, child: const Text('Go Back')),
///   ],
/// )
/// ```
class ErrorStateWidget extends StatelessWidget {
  const ErrorStateWidget({
    super.key,
    required this.message,
    this.title,
    this.emoji = Emojis.warning,
    this.onRetry,
    this.retryLabel,
    this.actions,
  });

  final String message;
  final String? title;
  final String emoji;

  /// Convenience shortcut: renders a single ElevatedButton labelled [retryLabel].
  /// Ignored when [actions] is provided.
  final VoidCallback? onRetry;
  final String? retryLabel;

  /// Custom list of buttons rendered in a Row below the message.
  /// If provided, [onRetry]/[retryLabel] are ignored.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final resolvedTitle = title ?? l10n.errorsUnknown;
    final resolvedRetryLabel = retryLabel ?? l10n.globalTryAgain;

    final List<Widget> resolvedActions =
        actions ?? (onRetry != null ? [ElevatedButton(onPressed: onRetry, child: Text(resolvedRetryLabel))] : []);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Emoji icon (4rem ≈ 56px)
            EmojiText(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            // Title
            Text(resolvedTitle, textAlign: TextAlign.center, style: tt.headlineMedium),
            const SizedBox(height: 12),
            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.6),
            ),
            if (resolvedActions.isNotEmpty) ...[
              const SizedBox(height: 24),
              Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: resolvedActions),
            ],
          ],
        ),
      ),
    );
  }
}
