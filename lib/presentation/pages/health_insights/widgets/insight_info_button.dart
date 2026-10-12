import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';

/// The (i) button shown in every Health Insights card header. Opens a short
/// dialog explaining what the card means and exactly what it shows.
class InsightInfoButton extends StatelessWidget {
  const InsightInfoButton({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return IconButton(
      icon: Icon(Icons.info_outline, color: cs.onSurfaceVariant, size: 20),
      tooltip: title,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      visualDensity: VisualDensity.compact,
      onPressed: () => _showInfo(context),
    );
  }

  void _showInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(message)),
        actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: Text(l10n.healthInsightsInfoClose))],
      ),
    );
  }
}
