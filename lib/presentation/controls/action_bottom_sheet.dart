import 'package:flutter/material.dart';

class ActionBottomSheet extends StatelessWidget {
  const ActionBottomSheet({
    super.key,
    required this.title,
    required this.body,
    this.footer,
    this.initialChildSize = 0.85,
    this.maxChildSize = 0.95,
  });

  final String title;
  final Widget body;
  final Widget? footer;
  final double initialChildSize;
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outline,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title, style: tt.headlineSmall),
                const SizedBox(height: 24),
                body,
                if (footer != null) ...[const SizedBox(height: 24), footer!],
              ],
            ),
          ),
        );
      },
    );
  }
}
