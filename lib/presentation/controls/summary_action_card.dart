import 'package:flutter/material.dart';

class SummaryActionCard extends StatelessWidget {
  const SummaryActionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.actions = const <Widget>[],
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final String? description;
  final List<Widget> actions;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subtitle != null && subtitle!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    subtitle!,
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              Text(title, style: tt.titleMedium),
              if (description != null && description!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    description!,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: actions),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
