import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/model/health_insights/comparison_row_data.dart';
import 'package:gym_tracker/model/health_insights/heart_rate_recovery.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_card_frame.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_stat_row.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/trend_sparkline.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Heart Rate Recovery (HRR): how many bpm your heart rate drops in the
/// first minute after exercise \u2014 a well-established marker of
/// cardiovascular fitness and autonomic recovery. Tap to compare against
/// the Cole et al. (1999) healthy-recovery reference.
class HeartRateRecoveryCard extends StatelessWidget {
  const HeartRateRecoveryCard({super.key, required this.recovery});

  /// Below this, Cole et al. (NEJM, 1999) found an association with
  /// increased all-cause mortality risk \u2014 the one well-cited HRR reference
  /// point; shown as "healthy reference", never as a population average.
  static const _healthyReferenceBpm = 12.0;

  final HeartRateRecovery? recovery;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final recovery = this.recovery;

    return InsightCardFrame(
      emoji: Emojis.beatingHeart,
      title: l10n.healthInsightsHrrTitle,
      infoTitle: l10n.healthInsightsHrrTitle,
      infoMessage: l10n.healthInsightsHrrInfo,
      onTap: recovery == null
          ? null
          : () => context.router.push(
              TwoColumnComparisonRoute(
                title: l10n.healthInsightsHrrTitle,
                emoji: Emojis.beatingHeart,
                rows: [
                  ComparisonRowData(
                    label: l10n.healthInsightsHrrTitle,
                    yourValue: recovery.currentBpm,
                    averageValue: _healthyReferenceBpm,
                    averageCaption: l10n.healthInsightsHrrReferenceCaption,
                    unit: 'bpm',
                  ),
                ],
              ),
            ),
      child: recovery == null
          ? Text(l10n.healthInsightsNoData, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      recovery.currentBpm.toStringAsFixed(0),
                      style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: cs.primary),
                    ),
                    const SizedBox(width: 4),
                    Text('bpm', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 4),
                InsightStatRow(label: l10n.healthInsightsHrrBandLabel, value: _bandLabel(l10n, recovery.band)),
                if (recovery.history.length > 1) ...[
                  const SizedBox(height: 12),
                  TrendSparkline(points: recovery.history),
                ],
              ],
            ),
    );
  }

  String _bandLabel(AppLocalizations l10n, HeartRateRecoveryBand band) => switch (band) {
    HeartRateRecoveryBand.low => l10n.healthInsightsHrrBandLow,
    HeartRateRecoveryBand.fair => l10n.healthInsightsHrrBandFair,
    HeartRateRecoveryBand.good => l10n.healthInsightsHrrBandGood,
    HeartRateRecoveryBand.excellent => l10n.healthInsightsHrrBandExcellent,
  };
}

