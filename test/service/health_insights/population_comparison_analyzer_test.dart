// Unit tests for PopulationComparisonAnalyzer — the "you vs. an average
// person of your sex/age/height" comparison used by the Physical Overview
// detail page's population mode. Delegates to PopulationNorms for both
// reference values, so expected numbers here mirror that table directly.
//
// Run: flutter test test/service/health_insights/population_comparison_analyzer_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/population_comparison_analyzer.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';

void main() {
  final analyzer = PopulationComparisonAnalyzer(const PopulationNorms());

  test('returns null when weight, height, or age is missing', () {
    expect(analyzer.build(weightKg: null, heightCm: 178, age: 24, sex: Sex.male), isNull);
    expect(analyzer.build(weightKg: 70, heightCm: null, age: 24, sex: Sex.male), isNull);
    expect(analyzer.build(weightKg: 70, heightCm: 178, age: null, sex: Sex.male), isNull);
  });

  test('computes an average weight from the age/sex-banded average BMI at the given height', () {
    final comparison = analyzer.build(weightKg: 70, heightCm: 178, age: 24, sex: Sex.male);

    expect(comparison, isNotNull);
    expect(comparison!.yourWeightKg, 70);
    // Men, 20s: average BMI 26.5 * 1.78^2 ≈ 84.0kg.
    expect(comparison.averageWeightKg, closeTo(84.0, 0.2));
  });

  test('labels the cohort by sex and age decade, defaulting to Men when sex is unknown', () {
    expect(analyzer.build(weightKg: 70, heightCm: 178, age: 24, sex: Sex.male)!.cohortLabel, 'Men, 20\u201329');
    expect(analyzer.build(weightKg: 60, heightCm: 165, age: 35, sex: Sex.female)!.cohortLabel, 'Women, 30\u201339');
    expect(analyzer.build(weightKg: 70, heightCm: 178, age: 24, sex: null)!.cohortLabel, 'Men, 20\u201329');
  });

  test('only fills in average body fat % when a body fat % was provided', () {
    final withoutBodyFat = analyzer.build(weightKg: 70, heightCm: 178, age: 24, sex: Sex.male);
    expect(withoutBodyFat!.yourBodyFatPercent, isNull);
    expect(withoutBodyFat.averageBodyFatPercent, isNull);

    final withBodyFat = analyzer.build(weightKg: 70, heightCm: 178, age: 24, sex: Sex.male, bodyFatPercent: 18);
    expect(withBodyFat!.yourBodyFatPercent, 18);
    // Matches PopulationNorms.averageBodyFatPercent(sex: Sex.male) exactly —
    // this analyzer never disagrees with the body-recomposition benchmark.
    expect(withBodyFat.averageBodyFatPercent, const PopulationNorms().averageBodyFatPercent(sex: Sex.male));
  });
}
