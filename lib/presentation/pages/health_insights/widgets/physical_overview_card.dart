import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/model/health_insights/physical_overview.dart';
import 'package:gym_tracker/model/health_insights/stress_index.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/insight_card_frame.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Snapshot of the user's latest weight / age / height, plus \u2014 only when
/// there's a recent (last 3 months) scale reading \u2014 body fat % and a
/// stress index. Tap the card to open the dedicated Physical Overview
/// detail page (population/past-you comparison).
class PhysicalOverviewCard extends StatelessWidget {
  const PhysicalOverviewCard({super.key, required this.overview});

  final PhysicalOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return InsightCardFrame(
      emoji: Emojis.bodySilhouette,
      title: l10n.healthInsightsOverviewTitle,
      infoTitle: l10n.healthInsightsOverviewTitle,
      infoMessage: l10n.healthInsightsOverviewInfo,
      onTap: () => context.router.push(const PhysicalOverviewDetailRoute()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: l10n.healthInsightsOverviewWeight,
                  valueText: overview.weightKg != null ? '${overview.weightKg!.toStringAsFixed(1)}kg' : '\u2014',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: l10n.healthInsightsOverviewAge,
                  valueText: overview.age != null ? '${overview.age}' : '\u2014',
                ),
              ),
              Expanded(
                child: _MetricTile(
                  label: l10n.healthInsightsOverviewHeight,
                  valueText: overview.heightCm > 0 ? '${overview.heightCm.toStringAsFixed(0)}cm' : '\u2014',
                ),
              ),
            ],
          ),
          if (overview.row2Visible) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    label: l10n.healthInsightsOverviewBodyFat,
                    valueText: overview.bodyFatPercent != null ? '${overview.bodyFatPercent!.toStringAsFixed(1)}%' : '\u2014',
                  ),
                ),
                Expanded(
                  child: _MetricTile(
                    label: l10n.healthInsightsOverviewStress,
                    valueText: overview.stressIndex != null ? '${overview.stressIndex!.value}' : '\u2014',
                    caption: overview.stressIndex != null ? _stressBandLabel(l10n, overview.stressIndex!.band) : null,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _stressBandLabel(AppLocalizations l10n, StressBand band) => switch (band) {
    StressBand.low => l10n.healthInsightsStressBandLow,
    StressBand.typical => l10n.healthInsightsStressBandTypical,
    StressBand.elevated => l10n.healthInsightsStressBandElevated,
    StressBand.high => l10n.healthInsightsStressBandHigh,
  };
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.valueText, this.caption});

  final String label;
  final String valueText;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(valueText, style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        if (caption != null) Text(caption!, style: tt.labelSmall?.copyWith(color: cs.primary)),
        const SizedBox(height: 2),
        Text(label, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant), textAlign: TextAlign.center),
      ],
    );
  }
}
