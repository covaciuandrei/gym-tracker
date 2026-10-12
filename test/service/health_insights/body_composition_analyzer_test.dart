// Unit tests for BodyCompositionAnalyzer, using anonymized data extracted from
// a sample Apple Health export (via MockHealthRepository) as the
// test oracle: weight 77.1kg (2025-04 peak) -> 70.7kg (2026-05-02, latest),
// lean mass held ~59.5 -> ~57.9kg -> a clean cut (fat lost, muscle kept).
//
// Run: flutter test test/service/health_insights/body_composition_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/health_insights/body_composition_trend.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/body_composition_analyzer.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';

import '../../data/health_insights/fixture_loader.dart';
import '../../data/health_insights/mock_health_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockHealthRepository repository;
  late BodyCompositionAnalyzer analyzer;

  setUp(() {
    repository = MockHealthRepository(HealthInsightsFixtureLoader());
    analyzer = BodyCompositionAnalyzer(const PopulationNorms());
  });

  test('current weight and body fat % match the fixture baseline', () async {
    final weight = await repository.samples(HealthMetric.bodyMass);
    final lean = await repository.samples(HealthMetric.leanBodyMass);

    final result = analyzer.analyze(
      weightSamples: weight,
      leanMassSamples: lean,
      sex: Sex.male,
      comparisonMode: ComparisonMode.population,
      comparisonWindow: ComparisonWindow.oneYear,
    );

    expect(result, isNotNull);
    // Latest real reading: 2026-05-02, 70.7kg.
    expect(result!.currentWeightKg, closeTo(70.7, 0.5));
    // Lean mass held ~58kg while weight dropped -> body fat in the high-teens.
    expect(result.currentBodyFatPercent, isNotNull);
    expect(result.currentBodyFatPercent!, closeTo(18, 4));
  });

  test('12-month self-comparison shows a cut (weight down, lean mass held)', () async {
    final weight = await repository.samples(HealthMetric.bodyMass);
    final lean = await repository.samples(HealthMetric.leanBodyMass);

    final result = analyzer.analyze(
      weightSamples: weight,
      leanMassSamples: lean,
      sex: Sex.male,
      comparisonMode: ComparisonMode.pastSelf,
      comparisonWindow: ComparisonWindow.oneYear,
      now: DateTime(2026, 5, 2),
    );

    expect(result, isNotNull);
    expect(result!.weightChangeKg, isNotNull);
    expect(result.weightChangeKg!, lessThan(0)); // lost weight
    expect(result.direction, anyOf(BodyCompositionDirection.cutting, BodyCompositionDirection.recomposition));
  });

  test('population comparison mode attaches a benchmark with a cohort label', () async {
    final weight = await repository.samples(HealthMetric.bodyMass);
    final lean = await repository.samples(HealthMetric.leanBodyMass);

    final result = analyzer.analyze(
      weightSamples: weight,
      leanMassSamples: lean,
      sex: Sex.male,
      comparisonMode: ComparisonMode.population,
      comparisonWindow: ComparisonWindow.oneYear,
    );

    expect(result!.benchmark, isNotNull);
    expect(result.benchmark!.cohortLabel, contains('Men'));
    expect(result.benchmark!.percentile, inInclusiveRange(0, 100));
  });

  test('returns null when there is no weight data at all', () {
    final result = analyzer.analyze(
      weightSamples: const [],
      leanMassSamples: const [],
      sex: Sex.male,
      comparisonMode: ComparisonMode.population,
      comparisonWindow: ComparisonWindow.oneYear,
    );

    expect(result, isNull);
  });
}
