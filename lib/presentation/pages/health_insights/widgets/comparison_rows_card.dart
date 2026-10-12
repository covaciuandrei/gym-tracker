import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/model/health_insights/comparison_row_data.dart';

/// A "you vs. a reference value" comparison card: one or more rows, each
/// with two columns (your value, emphasized; the reference value, with a
/// caption describing what it represents \u2014 a true population average, or
/// something else, e.g. a clinical reference point).
class ComparisonRowsCard extends StatelessWidget {
  const ComparisonRowsCard({super.key, required this.rows, this.headerText});

  final List<ComparisonRowData> rows;
  final String? headerText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerText != null) ...[
            Text(headerText!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
          ],
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 24),
            _ComparisonRow(row: rows[i]),
          ],
        ],
      ),
    );
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({required this.row});

  final ComparisonRowData row;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ValueTile(caption: l10n.healthInsightsPopulationCompareYou, value: row.yourValue, unit: row.unit, emphasize: true),
            ),
            Expanded(child: _ValueTile(caption: row.averageCaption, value: row.averageValue, unit: row.unit, emphasize: false)),
          ],
        ),
      ],
    );
  }
}

class _ValueTile extends StatelessWidget {
  const _ValueTile({required this.caption, required this.value, required this.unit, required this.emphasize});

  final String caption;
  final double value;
  final String unit;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(
          _formatValue(value, unit),
          style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: emphasize ? cs.primary : null),
        ),
      ],
    );
  }

  String _formatValue(double value, String unit) {
    final text = value.toStringAsFixed(1);
    if (unit.isEmpty || unit == '%') return '$text$unit';
    return '$text $unit';
  }
}
