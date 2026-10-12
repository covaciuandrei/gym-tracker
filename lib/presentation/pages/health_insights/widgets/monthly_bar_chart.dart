import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline.dart';
import 'package:gym_tracker/presentation/helpers/month_names.dart';

/// A monthly bar chart in the same visual style as the Stats page's bar
/// charts ("Days You Hit the Gym" / "Monthly Breakdown"): one bar per
/// month, the value labeled above the bar (OY) and the short month name
/// below it (OX). The year/period is shown in the enclosing card's header.
///
/// Horizontally scrollable with a fixed bar width (rather than stretching
/// like the Stats page's fixed 7/12-bar charts do) since a Health Insights
/// series can have anywhere from a couple of months up to ~19 months of
/// history \u2014 a fixed width keeps bars readable at any count.
class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.points, this.height = 140, this.color, this.barWidth = 28});

  final List<MonthlyPoint> points;
  final double height;
  final Color? color;
  final double barWidth;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return SizedBox(height: height);

    final maxValue = points.map((p) => p.value).reduce(math.max);
    final minValue = points.map((p) => p.value).reduce(math.min);
    // Zooms in on small relative changes (e.g. 70–73 kg) so the trend is visible; never below zero.
    final baseline = math.max(0.0, minValue - (maxValue - minValue));

    return SizedBox(
      height: height,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        reverse: true,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final point in points)
              SizedBox(
                width: barWidth,
                child: _MonthBar(value: point.value, baseline: baseline, max: maxValue, month: point.month, color: color),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({required this.value, required this.baseline, required this.max, required this.month, this.color});

  final double value;
  final double baseline;
  final double max;
  final DateTime month;
  final Color? color;

  static const _minBarHeight = 6.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final span = max - baseline;
    final ratio = span <= 0 ? (max > 0 ? 1.0 : 0.0) : ((value - baseline) / span).clamp(0.0, 1.0);

    return Column(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _formatValue(value),
                  style: tt.labelSmall?.copyWith(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) => Container(
                    width: 16,
                    height: _minBarHeight + ratio * (constraints.maxHeight - _minBarHeight),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: color ?? cs.primary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            AppLocalizations.of(context).monthShort(month.month),
            style: tt.labelSmall?.copyWith(fontSize: 9, color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  String _formatValue(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}
