import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline.dart';
import 'package:gym_tracker/model/health_insights/timeline_range.dart';
import 'package:injectable/injectable.dart';

/// Aggregates raw samples into one-point-per-calendar-month series for the
/// "metric timeline" detail pages (body composition / VO2Max / heart-rate-
/// recovery history charts), and resolves which [TimelineRange]s the
/// available data can actually support.
///
/// Range switching in those pages is a pure client-side filter over the
/// full monthly history this builder produces \u2014 there is no need to
/// re-fetch or re-aggregate per range tap at this data volume.
@injectable
class MetricTimelineBuilder {
  const MetricTimelineBuilder();

  /// Every Health Insights data fetch is bounded to this window — the last
  /// 24 months, from local midnight two years ago — so charts load fast and
  /// stay readable. Longer history is intentionally not requested.
  static DateTime reportingWindowStart({DateTime? now}) {
    final today = now ?? DateTime.now();
    return DateTime(today.year - 2, today.month, today.day);
  }

  /// Ascending list of one point per calendar month (mean of that month's
  /// samples) across ALL of [samples].
  List<MonthlyPoint> buildMonthlyPoints(List<HealthSample> samples) {
    final sums = <DateTime, double>{};
    final counts = <DateTime, int>{};
    for (final s in samples) {
      final key = DateTime(s.dateFrom.year, s.dateFrom.month);
      sums[key] = (sums[key] ?? 0) + s.value;
      counts[key] = (counts[key] ?? 0) + 1;
    }
    final months = sums.keys.toList()..sort();
    return [for (final m in months) MonthlyPoint(month: m, value: sums[m]! / counts[m]!)];
  }

  /// Which [TimelineRange]s are meaningful given [earliestDataDate] \u2014 a
  /// range longer than the available history is omitted. "Max" is always
  /// included, labeled with the actual span (e.g. "1.5Y") when it doesn't
  /// land close to one of the fixed options.
  List<TimelineRange> availableRanges({required DateTime earliestDataDate, DateTime? now}) {
    final today = now ?? DateTime.now();
    final totalDays = today.difference(earliestDataDate).inDays;

    final candidates = <TimelineRangeKind, int>{
      TimelineRangeKind.threeMonths: 90,
      TimelineRangeKind.sixMonths: 182,
      TimelineRangeKind.ytd: today.difference(DateTime(today.year, 1, 1)).inDays,
      TimelineRangeKind.oneYear: 365,
      TimelineRangeKind.twoYears: 730,
      TimelineRangeKind.threeYears: 1095,
    };

    final ranges = <TimelineRange>[];
    final includedDays = <int>[];
    final includedLabels = <String>[];
    for (final entry in candidates.entries) {
      if (totalDays < entry.value) continue;
      final label = _fixedLabel(entry.key);
      ranges.add(TimelineRange(kind: entry.key, label: label));
      includedDays.add(entry.value);
      includedLabels.add(label);
    }

    ranges.add(TimelineRange(kind: TimelineRangeKind.max, label: _maxLabel(totalDays, includedDays, includedLabels)));
    return ranges;
  }

  String _fixedLabel(TimelineRangeKind kind) => switch (kind) {
    TimelineRangeKind.threeMonths => '3M',
    TimelineRangeKind.sixMonths => '6M',
    TimelineRangeKind.ytd => 'YTD',
    TimelineRangeKind.oneYear => '1Y',
    TimelineRangeKind.twoYears => '2Y',
    TimelineRangeKind.threeYears => '3Y',
    TimelineRangeKind.max => 'Max',
  };

  /// "Max" gets a plain "Max" label when its span is within ~15 days of a
  /// fixed option already offered, or when the computed year-figure would
  /// render identically to one of them (avoids a near-duplicate chip
  /// either way); otherwise a dynamic year figure rounded to the nearest
  /// half-year.
  String _maxLabel(int totalDays, List<int> includedFixedDays, List<String> includedFixedLabels) {
    for (final fixedDays in includedFixedDays) {
      if ((totalDays - fixedDays).abs() <= 15) return 'Max';
    }
    if (totalDays < 100) return 'Max';
    final years = totalDays / 365.0;
    final rounded = (years * 2).round() / 2; // nearest 0.5
    final isWhole = rounded == rounded.roundToDouble();
    final computed = '${isWhole ? rounded.round() : rounded}Y';
    return includedFixedLabels.contains(computed) ? 'Max' : computed;
  }
}
