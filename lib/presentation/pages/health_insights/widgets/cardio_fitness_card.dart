import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/model/health_insights/cardio_fitness.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline_spec.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/benchmark_row.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_card_frame.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_stat_row.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/trend_sparkline.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Weight-adjusted VO2Max: Apple's reading plus what it would be at a past
/// weight (fitness held constant), so a bodyweight change isn't mistaken
/// for a fitness change. Tap to see the full monthly VO2Max history.
class CardioFitnessCard extends StatelessWidget {
  const CardioFitnessCard({super.key, required this.cardioFitness});

  final CardioFitness? cardioFitness;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fitness = cardioFitness;

    return InsightCardFrame(
      emoji: Emojis.heart,
      title: l10n.healthInsightsVo2Title,
      infoTitle: l10n.healthInsightsVo2Title,
      infoMessage: l10n.healthInsightsVo2Info,
      onTap: () => context.router.push(
        MetricTimelineRoute(
          title: l10n.healthInsightsVo2Title,
          emoji: Emojis.heart,
          specs: [MetricTimelineSeriesSpec(metric: HealthMetric.vo2Max, label: l10n.healthInsightsVo2Title, unit: '')],
        ),
      ),
      child: fitness == null
          ? Text(l10n.healthInsightsNoData, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InsightStatRow(label: l10n.healthInsightsVo2Current, value: fitness.currentVo2Max.toStringAsFixed(1)),
                if (fitness.compareVo2Max != null)
                  InsightStatRow(label: fitness.compareLabel ?? '', value: fitness.compareVo2Max!.toStringAsFixed(1)),
                if (fitness.vo2MaxAtCompareWeight != null)
                  InsightStatRow(
                    label: l10n.healthInsightsVo2AtPastWeight,
                    value: fitness.vo2MaxAtCompareWeight!.toStringAsFixed(1),
                  ),
                if (fitness.history.length > 1) ...[
                  const SizedBox(height: 12),
                  TrendSparkline(points: fitness.history),
                ],
                if (fitness.benchmark != null)
                  BenchmarkRow(
                    label: '${fitness.benchmark!.band} (avg ${fitness.benchmark!.averageValue.toStringAsFixed(1)}) '
                        '\u2022 ${fitness.benchmark!.cohortLabel}',
                  ),
              ],
            ),
    );
  }
}
