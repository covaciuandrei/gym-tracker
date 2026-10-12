import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/model/health_insights/body_composition_trend.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline_spec.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/benchmark_row.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_card_frame.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_stat_row.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/trend_sparkline.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Whether a recent weight change was mostly fat loss, mostly muscle gain,
/// both, or neither — derived from weight + lean-body-mass trends. Tap to
/// see the monthly weight / body-fat % history.
class BodyRecompositionCard extends StatelessWidget {
  const BodyRecompositionCard({super.key, required this.trend});

  final BodyCompositionTrend? trend;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final trend = this.trend;

    return InsightCardFrame(
      emoji: Emojis.scale,
      title: l10n.healthInsightsBodyCompTitle,
      infoTitle: l10n.healthInsightsBodyCompTitle,
      infoMessage: l10n.healthInsightsBodyCompInfo,
      onTap: () => context.router.push(
        MetricTimelineRoute(
          title: l10n.healthInsightsBodyCompTitle,
          emoji: Emojis.scale,
          specs: [MetricTimelineSeriesSpec(metric: HealthMetric.bodyMass, label: l10n.healthInsightsOverviewWeight, unit: 'kg')],
          derivedBodyFatLabel: l10n.healthInsightsOverviewBodyFat,
        ),
      ),
      child: trend == null
          ? Text(l10n.healthInsightsNoData, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_directionLabel(l10n, trend.direction), style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                InsightStatRow(label: l10n.healthInsightsBodyCompWeightLabel, value: '${trend.currentWeightKg.toStringAsFixed(1)} kg'),
                if (trend.currentBodyFatPercent != null)
                  InsightStatRow(
                    label: l10n.healthInsightsBodyCompFatLabel,
                    value: '${trend.currentBodyFatPercent!.toStringAsFixed(1)}%',
                  ),
                if (trend.weightChangeKg != null)
                  InsightStatRow(
                    label: trend.compareLabel ?? '',
                    value: '${trend.weightChangeKg! > 0 ? '+' : ''}${trend.weightChangeKg!.toStringAsFixed(1)} kg',
                  ),
                if (trend.history.length > 1) ...[
                  const SizedBox(height: 12),
                  TrendSparkline(points: [for (final p in trend.history) MapEntry(p.date, p.weightKg)]),
                ],
                if (trend.benchmark != null)
                  BenchmarkRow(
                    label: '${trend.benchmark!.band} (avg ${trend.benchmark!.averageValue.toStringAsFixed(1)}%) '
                        '\u2022 ${trend.benchmark!.cohortLabel}',
                  ),
              ],
            ),
    );
  }

  String _directionLabel(AppLocalizations l10n, BodyCompositionDirection direction) => switch (direction) {
    BodyCompositionDirection.cutting => l10n.healthInsightsBodyCompCutting,
    BodyCompositionDirection.bulking => l10n.healthInsightsBodyCompBulking,
    BodyCompositionDirection.recomposition => l10n.healthInsightsBodyCompRecomposition,
    BodyCompositionDirection.stable => l10n.healthInsightsBodyCompStable,
    BodyCompositionDirection.insufficientData => l10n.healthInsightsNoData,
  };
}
