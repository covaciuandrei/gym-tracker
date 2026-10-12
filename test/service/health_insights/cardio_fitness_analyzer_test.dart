// Unit tests for CardioFitnessAnalyzer. Uses the sample VO2Max/weight history
// (via MockHealthRepository) plus targeted synthetic cases to verify the
// weight-adjustment formula and fitness-age inversion deterministically.
//
// Run: flutter test test/service/health_insights/cardio_fitness_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/cardio_fitness_analyzer.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';

import '../../data/health_insights/fixture_loader.dart';
import '../../data/health_insights/mock_health_repository.dart';

HealthSample _sample(HealthMetric metric, DateTime date, double value) =>
    HealthSample(metric: metric, value: value, unit: '', dateFrom: date, dateTo: date, sourceName: 'test');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthRepository repository;
  late CardioFitnessAnalyzer analyzer;

  setUp(() {
    repository = MockHealthRepository(HealthInsightsFixtureLoader());
    analyzer = CardioFitnessAnalyzer(const PopulationNorms());
  });

  test('current VO2Max matches the fixture baseline (~43 in mid-2026)', () async {
    final vo2 = await repository.samples(HealthMetric.vo2Max);
    final weight = await repository.samples(HealthMetric.bodyMass);

    final result = analyzer.analyze(
      vo2MaxSamples: vo2,
      weightSamples: weight,
      sex: Sex.male,
      ageYears: 24,
      comparisonMode: ComparisonMode.population,
      comparisonWindow: ComparisonWindow.oneYear,
    );

    expect(result, isNotNull);
    expect(result!.currentVo2Max, closeTo(43, 2));
  });

  test('weight-adjusted VO2Max separates a real fitness change from a weight-driven one', () {
    // Same aerobic engine (VO2 x weight constant), different bodyweight:
    // 46 mL/kg/min at 70kg vs 41.8 mL/kg/min at 77kg represent IDENTICAL
    // absolute capacity (46*70 == 41.8*77 == 3220).
    final vo2Samples = [
      _sample(HealthMetric.vo2Max, DateTime(2021, 10, 1), 46.0),
      _sample(HealthMetric.vo2Max, DateTime(2025, 4, 1), 41.8),
    ];
    final weightSamples = [
      _sample(HealthMetric.bodyMass, DateTime(2021, 10, 1), 70.0),
      _sample(HealthMetric.bodyMass, DateTime(2025, 4, 1), 77.0),
    ];

    final result = analyzer.analyze(
      vo2MaxSamples: vo2Samples,
      weightSamples: weightSamples,
      sex: Sex.male,
      ageYears: 24,
      comparisonMode: ComparisonMode.pastSelf,
      comparisonWindow: ComparisonWindow.oneYear,
      now: DateTime(2025, 4, 1),
    );

    expect(result, isNotNull);
    // Rescaling the 2025 reading (41.8 @ 77kg) back to the 2021 weight
    // (70kg) should reproduce ~46 - i.e. "your engine didn't shrink".
    expect(result!.vo2MaxAtCompareWeight, closeTo(46.0, 0.1));
  });
}
