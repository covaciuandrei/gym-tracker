import 'package:flutter/material.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Empty / no-data state with an emoji icon, title, description and an
/// optional action button.
///
/// Mirrors Angular `.empty-state` (workout-types, stats components):
///   flex-column centered · padding 64px 32px · emoji 4rem
///   h3 1.25rem/600 · p secondary/max-width 250px · optional btn-primary
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   emoji: Emojis.weightLifting,
///   title: 'No workout types yet',
///   message: 'Create your first type to start tracking.',
///   actionLabel: 'Create',
///   onAction: () => cubit.openCreateModal(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.message,
    this.emoji = Emojis.emptyMailbox,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String emoji;

  /// Label for the optional primary action button.
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
            Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleLarge,
            ),
            const SizedBox(height: 8),
            // Description (max-width 250px equivalent via ConstrainedBox)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
