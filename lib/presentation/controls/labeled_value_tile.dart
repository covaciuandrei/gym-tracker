import 'package:flutter/material.dart';

class LabeledValueTile extends StatelessWidget {
  const LabeledValueTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: cs.onSurfaceVariant),
      title: Text(label),
      trailing: Text(value, style: TextStyle(color: cs.onSurfaceVariant)),
    );
  }
}
