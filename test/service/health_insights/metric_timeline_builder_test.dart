// Unit tests for MetricTimelineBuilder — monthly aggregation and
// available-range resolution for the "metric timeline" detail pages.
//
// Run: flutter test test/service/health_insights/metric_timeline_builder_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/timeline_range.dart';
import 'package:gym_tracker/service/health_insights/metric_timeline_builder.dart';

HealthSample _sample(DateTime date, double value) =>
    HealthSample(metric: HealthMetric.bodyMass, value: value, unit: 'kg', dateFrom: date, dateTo: date, sourceName: 'test');

void main() {
  const builder = MetricTimelineBuilder();

  group('buildMonthlyPoints', () {
    test('averages multiple samples within the same calendar month', () {
      final points = builder.buildMonthlyPoints([
        _sample(DateTime(2026, 3, 1), 70),
        _sample(DateTime(2026, 3, 15), 72),
        _sample(DateTime(2026, 3, 30), 74),
      ]);

      expect(points, hasLength(1));
      expect(points.single.month, DateTime(2026, 3));
      expect(points.single.value, 72);
    });

    test('returns one ascending point per month across multiple months, regardless of input order', () {
      final points = builder.buildMonthlyPoints([
        _sample(DateTime(2026, 1, 10), 70),
        _sample(DateTime(2026, 3, 10), 72),
        _sample(DateTime(2026, 2, 10), 71),
      ]);

      expect(points.map((p) => p.month), [DateTime(2026, 1), DateTime(2026, 2), DateTime(2026, 3)]);
    });

    test('returns an empty list for no samples', () {
      expect(builder.buildMonthlyPoints(const []), isEmpty);
    });
  });

  group('availableRanges', () {
    final now = DateTime(2026, 7, 24);

    test('only Max is offered when history is shorter than every fixed range', () {
      final ranges = builder.availableRanges(earliestDataDate: now.subtract(const Duration(days: 40)), now: now);

      expect(ranges.map((r) => r.kind), [TimelineRangeKind.max]);
      expect(ranges.single.label, 'Max');
    });

    test('offers every fixed range the history is long enough for, plus Max', () {
      final ranges = builder.availableRanges(earliestDataDate: now.subtract(const Duration(days: 800)), now: now);

      expect(
        ranges.map((r) => r.kind),
        containsAll(<TimelineRangeKind>[
          TimelineRangeKind.threeMonths,
          TimelineRangeKind.sixMonths,
          TimelineRangeKind.ytd,
          TimelineRangeKind.oneYear,
          TimelineRangeKind.twoYears,
          TimelineRangeKind.max,
        ]),
      );
      expect(ranges.map((r) => r.kind), isNot(contains(TimelineRangeKind.threeYears)));
    });

    test('Max falls back to a plain "Max" label instead of duplicating an already-offered fixed range', () {
      // 400 days: 1Y (365d) qualifies, and 400 days rounds to the same "1Y"
      // figure the fixed range already uses as its label.
      final ranges = builder.availableRanges(earliestDataDate: now.subtract(const Duration(days: 400)), now: now);
      final maxRange = ranges.firstWhere((r) => r.kind == TimelineRangeKind.max);

      expect(maxRange.label, 'Max');
    });

    test('Max shows a distinct dynamic year figure when it is meaningfully longer than every fixed range', () {
      // ~1300 days (~3.56 years): every fixed range up to 3Y (1095d)
      // qualifies, but the actual span rounds to a distinct "3.5Y".
      final ranges = builder.availableRanges(earliestDataDate: now.subtract(const Duration(days: 1300)), now: now);
      final maxRange = ranges.firstWhere((r) => r.kind == TimelineRangeKind.max);

      expect(maxRange.label, '3.5Y');
    });

    test('startDate resolves each fixed kind relative to now', () {
      const range = TimelineRange(kind: TimelineRangeKind.oneYear, label: '1Y');
      expect(range.startDate(now: now, earliestDataDate: now), DateTime(2025, 7, 24));
    });
  });

  test('reportingWindowStart covers the last 24 months, from local midnight', () {
    expect(MetricTimelineBuilder.reportingWindowStart(now: DateTime(2026, 10, 9, 15, 45)), DateTime(2024, 10, 9));
  });
}
