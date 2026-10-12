// Unit tests for StressIndexAnalyzer — a self-baselined 0-100 stress
// estimate derived from how far today's HRV sits below the user's own
// trailing 60-day baseline (lower HRV -> higher stress).
//
// Run: flutter test test/service/health_insights/stress_index_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/stress_index.dart';
import 'package:gym_tracker/service/health_insights/stress_index_analyzer.dart';

HealthSample _sample(DateTime date, double value) =>
    HealthSample(metric: HealthMetric.heartRateVariabilitySdnn, value: value, unit: 'ms', dateFrom: date, dateTo: date, sourceName: 'test');

/// 60 days alternating 48/52ms (mean 50, non-zero variance so the z-score
/// actually responds to [latestValue]) followed by one "latest" day.
List<HealthSample> _baselineThenLatest(double latestValue, {int baselineDays = 60}) {
  final start = DateTime(2026, 1, 1);
  final samples = <HealthSample>[
    for (var i = 0; i < baselineDays; i++) _sample(start.add(Duration(days: i)), i.isEven ? 48 : 52),
  ];
  samples.add(_sample(start.add(Duration(days: baselineDays)), latestValue));
  return samples;
}

void main() {
  const analyzer = StressIndexAnalyzer();

  test('a well-below-baseline HRV reading maxes out the stress score at 100 / high', () {
    final result = analyzer.analyze(hrvSamples: _baselineThenLatest(30));

    expect(result, isNotNull);
    expect(result!.value, 100);
    expect(result.band, StressBand.high);
  });

  test('a well-above-baseline HRV reading floors the stress score at 0 / low', () {
    final result = analyzer.analyze(hrvSamples: _baselineThenLatest(70));

    expect(result, isNotNull);
    expect(result!.value, 0);
    expect(result.band, StressBand.low);
  });

  test('an HRV reading matching the baseline mean scores exactly 50 / typical', () {
    final result = analyzer.analyze(hrvSamples: _baselineThenLatest(50));

    expect(result, isNotNull);
    expect(result!.value, 50);
    expect(result.band, StressBand.typical);
    expect(result.hrvMs, 50);
    expect(result.baselineHrvMs, 50);
  });

  test('returns null when there is no HRV data at all', () {
    expect(analyzer.analyze(hrvSamples: const []), isNull);
  });

  test('returns null when the baseline window has fewer than 5 other days', () {
    final start = DateTime(2026, 1, 1);
    final samples = [
      _sample(start, 50),
      _sample(start.add(const Duration(days: 1)), 48),
      _sample(start.add(const Duration(days: 2)), 52),
      _sample(start.add(const Duration(days: 3)), 40), // "latest" day
    ];
    expect(analyzer.analyze(hrvSamples: samples), isNull);
  });
}
