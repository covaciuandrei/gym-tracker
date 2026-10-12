import 'package:flutter/material.dart';

/// A simple "label ⟷ value" row used inside every Health Insights card.
class InsightStatRow extends StatelessWidget {
  const InsightStatRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
          const SizedBox(width: 12),
          Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
