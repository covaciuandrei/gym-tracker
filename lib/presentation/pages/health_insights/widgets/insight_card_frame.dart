import 'package:flutter/material.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/surface_section_card.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_info_button.dart';

/// Shared card frame for every Health Insights card: emoji + title header
/// with an (i) info button, then [child] below.
///
/// When [onTap] is provided, the whole card becomes tappable (used by cards
/// that open a monthly-history detail page) and a trailing chevron is shown
/// next to the info button to signal that.
class InsightCardFrame extends StatelessWidget {
  const InsightCardFrame({
    super.key,
    required this.emoji,
    required this.title,
    required this.infoTitle,
    required this.infoMessage,
    required this.child,
    this.onTap,
  });

  final String emoji;
  final String title;
  final String infoTitle;
  final String infoMessage;
  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final card = SurfaceSectionCard(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              EmojiText(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
              InsightInfoButton(title: infoTitle, message: infoMessage),
              if (onTap != null) Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
        Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: child),
      ],
    );

    final tapHandler = onTap;
    if (tapHandler == null) return card;
    return InkWell(borderRadius: BorderRadius.circular(16), onTap: tapHandler, child: card);
  }
}

