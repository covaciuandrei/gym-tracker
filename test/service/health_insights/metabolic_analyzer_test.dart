// Unit tests for MetabolicAnalyzer, using the real profile numbers
// (24yo male, 178cm, ~70.7kg, ~57.9kg lean mass) as deterministic formula
// oracles for Mifflin-St Jeor and Cunningham.
//
// Run: flutter test test/service/health_insights/metabolic_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/metabolic_analyzer.dart';

HealthSample _sample(HealthMetric metric, DateTime date, double value) =>
    HealthSample(metric: metric, value: value, unit: 'Cal', dateFrom: date, dateTo: date, sourceName: 'test');

void main() {
  final analyzer = const MetabolicAnalyzer();

  test('Mifflin-St Jeor (male) matches the hand-computed formula', () {
    // 10*70.7 + 6.25*178 - 5*24 + 5 = 707 + 1112.5 - 120 + 5 = 1704.5
    final result = analyzer.analyze(
      weightKg: 70.7,
      heightCm: 178,
      ageYears: 24,
      sex: Sex.male,
      leanBodyMassKg: null,
      basalEnergySamples: const [],
      activeEnergySamples: const [],
    );

    expect(result, isNotNull);
    expect(result!.mifflinStJeorKcal, closeTo(1704.5, 0.01));
    expect(result.cunninghamKcal, isNull);
  });

  test('Cunningham (lean-mass based) is included whenever lean mass is available', () {
    // 500 + 22*57.9 = 500 + 1273.8 = 1773.8
    final result = analyzer.analyze(
      weightKg: 70.7,
      heightCm: 178,
      ageYears: 24,
      sex: Sex.male,
      leanBodyMassKg: 57.9,
      basalEnergySamples: const [],
      activeEnergySamples: const [],
    );

    expect(result, isNotNull);
    expect(result!.cunninghamKcal, closeTo(1773.8, 0.01));
  });

  test('female formula subtracts 161 instead of adding 5', () {
    // 10*60 + 6.25*165 - 5*30 - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
    final result = analyzer.analyze(
      weightKg: 60,
      heightCm: 165,
      ageYears: 30,
      sex: Sex.female,
      leanBodyMassKg: null,
      basalEnergySamples: const [],
      activeEnergySamples: const [],
    );

    expect(result!.mifflinStJeorKcal, closeTo(1320.25, 0.01));
  });

  test('total daily energy combines the resting estimate with average active burn', () {
    final now = DateTime(2026, 7, 24);
    final activeSamples = [
      _sample(HealthMetric.activeEnergyBurned, now.subtract(const Duration(days: 1)), 400),
      _sample(HealthMetric.activeEnergyBurned, now, 600),
    ];

    final result = analyzer.analyze(
      weightKg: 70.7,
      heightCm: 178,
      ageYears: 24,
      sex: Sex.male,
      leanBodyMassKg: 57.9,
      basalEnergySamples: const [],
      activeEnergySamples: activeSamples,
      window: ComparisonWindow.threeMonths,
      now: now,
    );

    expect(result!.watchActiveAvgKcal, closeTo(500, 0.01)); // avg(400, 600)
    // Prefers Cunningham (1773.8) + avg active (500) = 2273.8
    expect(result.totalDailyEnergyKcal, closeTo(2273.8, 0.01));
  });

  test('returns null without weight, height, age, or sex', () {
    final result = analyzer.analyze(
      weightKg: null,
      heightCm: 178,
      ageYears: 24,
      sex: Sex.male,
      leanBodyMassKg: null,
      basalEnergySamples: const [],
      activeEnergySamples: const [],
    );

    expect(result, isNull);
  });
}
