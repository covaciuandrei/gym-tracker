import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline.dart';
import 'package:gym_tracker/presentation/helpers/month_names.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/monthly_bar_chart.dart';

/// An always-visible chart card for one series: title + period + latest value +
/// change-over-range text, then a [MonthlyBarChart] beneath \u2014 used by
/// every Health Insights detail page that shows monthly history (Body
/// Recomposition, Cardio Fitness, and the Physical Overview detail page's
/// past-you mode).
class SeriesChartCard extends StatelessWidget {
  const SeriesChartCard({super.key, required this.label, required this.unit, required this.points});

  final String label;
  final String unit;

  /// Already filtered to the selected range, ascending by month.
  final List<MonthlyPoint> points;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final changeText = _changeText(unit);
    final periodText = _periodText(l10n);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(label, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                        if (periodText != null) Text(periodText, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(changeText ?? l10n.healthInsightsNoData, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              if (points.isNotEmpty)
                Text('${points.last.value.toStringAsFixed(1)} $unit', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          MonthlyBarChart(points: points),
        ],
      ),
    );
  }

  String? _periodText(AppLocalizations l10n) {
    if (points.isEmpty) return null;
    final first = points.first.month;
    final last = points.last.month;
    if (first.year == last.year) return '${first.year}';
    return l10n.healthInsightsChartPeriod('${l10n.monthShort(first.month)} ${first.year}', '${l10n.monthShort(last.month)} ${last.year}');
  }

  String? _changeText(String unit) {
    if (points.length < 2) return null;
    final diff = points.last.value - points.first.value;
    final sign = diff > 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)} $unit';
  }
}
