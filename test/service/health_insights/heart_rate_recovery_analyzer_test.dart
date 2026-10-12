// Unit tests for HeartRateRecoveryAnalyzer — reads the latest HRR (bpm
// drop in the first minute after exercise) sample directly and bands it.
//
// Run: flutter test test/service/health_insights/heart_rate_recovery_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/heart_rate_recovery.dart';
import 'package:gym_tracker/service/health_insights/heart_rate_recovery_analyzer.dart';

HealthSample _sample(DateTime date, double value) =>
    HealthSample(metric: HealthMetric.heartRateRecovery, value: value, unit: 'bpm', dateFrom: date, dateTo: date, sourceName: 'test');

void main() {
  const analyzer = HeartRateRecoveryAnalyzer();

  test('returns null when there are no samples', () {
    expect(analyzer.analyze(hrrSamples: const []), isNull);
  });

  test('bands low at 12 bpm or less (Cole et al. 1999 mortality-risk cutoff)', () {
    final result = analyzer.analyze(hrrSamples: [_sample(DateTime(2026, 1, 1), 12)]);
    expect(result!.currentBpm, 12);
    expect(result.band, HeartRateRecoveryBand.low);
  });

  test('bands fair between 13 and 20 bpm', () {
    final result = analyzer.analyze(hrrSamples: [_sample(DateTime(2026, 1, 1), 18)]);
    expect(result!.band, HeartRateRecoveryBand.fair);
  });

  test('bands good between 21 and 30 bpm', () {
    final result = analyzer.analyze(hrrSamples: [_sample(DateTime(2026, 1, 1), 25)]);
    expect(result!.band, HeartRateRecoveryBand.good);
  });

  test('bands excellent above 30 bpm', () {
    final result = analyzer.analyze(hrrSamples: [_sample(DateTime(2026, 1, 1), 35)]);
    expect(result!.band, HeartRateRecoveryBand.excellent);
  });

  test('uses the last (most recent) sample, not the first, and keeps full history', () {
    final result = analyzer.analyze(hrrSamples: [_sample(DateTime(2026, 1, 1), 10), _sample(DateTime(2026, 6, 1), 35)]);

    expect(result!.currentBpm, 35);
    expect(result.band, HeartRateRecoveryBand.excellent);
    expect(result.history, hasLength(2));
  });
}
