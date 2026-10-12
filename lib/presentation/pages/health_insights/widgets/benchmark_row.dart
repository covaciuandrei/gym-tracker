import 'package:flutter/material.dart';

/// A small pill summarizing a comparison — either a population benchmark
/// ("Above average · Men, 20-29") or a past-self change label.
class BenchmarkRow extends StatelessWidget {
  const BenchmarkRow({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(Icons.leaderboard_outlined, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))),
        ],
      ),
    );
  }
}
