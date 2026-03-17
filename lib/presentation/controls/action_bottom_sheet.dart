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

  /// Shows this popup as a centered dialog instead of a bottom sheet.
  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    Widget? footer,
  }) {
    return showDialog<T>(
      context: context,
      builder: (_) =>
          ActionBottomSheet(title: title, body: body, footer: footer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with title + close button
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 8, top: 16),
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: tt.headlineSmall)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: body,
                ),
              ),
              // Sticky footer
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: footer!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
