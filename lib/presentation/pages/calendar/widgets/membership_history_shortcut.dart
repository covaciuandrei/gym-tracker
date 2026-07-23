import 'package:flutter/material.dart';

/// Calendar app-bar shortcut shown when no membership is active.
class MembershipHistoryShortcut extends StatelessWidget {
  const MembershipHistoryShortcut({super.key, required this.tooltip, required this.onPressed});

  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton(
      tooltip: tooltip,
      color: colorScheme.error,
      onPressed: onPressed,
      icon: const Icon(Icons.card_membership_outlined),
    );
  }
}
