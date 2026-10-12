import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/model/health_insights/metabolic_estimate.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_card_frame.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_stat_row.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Personalized resting-metabolic-rate and total-daily-energy estimate,
/// shown alongside Apple's own Watch-measured averages for reference.
class MetabolicCard extends StatelessWidget {
  const MetabolicCard({super.key, required this.estimate});

  final MetabolicEstimate? estimate;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final estimate = this.estimate;

    return InsightCardFrame(
      emoji: Emojis.fire,
      title: l10n.healthInsightsMetabolicTitle,
      infoTitle: l10n.healthInsightsMetabolicTitle,
      infoMessage: l10n.healthInsightsMetabolicInfo,
      child: estimate == null
          ? Text(l10n.healthInsightsNoData, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (estimate.totalDailyEnergyKcal != null) ...[
                  Text(
                    '${estimate.totalDailyEnergyKcal!.round()} kcal/day',
                    style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(l10n.healthInsightsMetabolicTdee, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  const SizedBox(height: 8),
                ],
                InsightStatRow(
                  label: estimate.cunninghamKcal != null ? l10n.healthInsightsMetabolicCunningham : l10n.healthInsightsMetabolicMifflin,
                  value: '${(estimate.cunninghamKcal ?? estimate.mifflinStJeorKcal).round()} kcal',
                ),
                if (estimate.watchBasalAvgKcal != null)
                  InsightStatRow(label: l10n.healthInsightsMetabolicWatch, value: '${estimate.watchBasalAvgKcal!.round()} kcal'),
                if (estimate.watchActiveAvgKcal != null)
                  InsightStatRow(label: l10n.healthInsightsMetabolicActive, value: '${estimate.watchActiveAvgKcal!.round()} kcal'),
              ],
            ),
    );
  }
}
