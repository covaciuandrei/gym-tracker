// Unit tests for PopulationNorms — sanity checks on the bundled reference
// tables (monotonic ordering, clamping, cohort labels), not a re-derivation
// of the underlying fitness literature.
//
// Run: flutter test test/service/health_insights/population_norms_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';

void main() {
  final norms = const PopulationNorms();

  test('vo2MaxBenchmark percentile increases with a higher VO2Max at the same age/sex', () {
    final low = norms.vo2MaxBenchmark(vo2Max: 30, age: 24, sex: Sex.male);
    final mid = norms.vo2MaxBenchmark(vo2Max: 48, age: 24, sex: Sex.male);
    final high = norms.vo2MaxBenchmark(vo2Max: 70, age: 24, sex: Sex.male);

    expect(low.percentile, lessThan(mid.percentile));
    expect(mid.percentile, lessThan(high.percentile));
    expect(mid.percentile, closeTo(50, 5)); // 48 is ~median for men 20-29
  });

  test('vo2MaxBenchmark clamps out-of-range values to 10/90 rather than extrapolating', () {
    final veryLow = norms.vo2MaxBenchmark(vo2Max: 1, age: 24, sex: Sex.male);
    final veryHigh = norms.vo2MaxBenchmark(vo2Max: 200, age: 24, sex: Sex.male);

    expect(veryLow.percentile, 10);
    expect(veryHigh.percentile, 90);
  });

  test('vo2MaxBenchmark cohort label reflects the age decade and sex', () {
    final benchmark = norms.vo2MaxBenchmark(vo2Max: 43, age: 24, sex: Sex.male);
    expect(benchmark.cohortLabel, 'Men, 20–29');
  });

  test('bodyFatBenchmark: lower body fat gives a higher percentile', () {
    final lean = norms.bodyFatBenchmark(bodyFatPercent: 10, sex: Sex.male);
    final average = norms.bodyFatBenchmark(bodyFatPercent: 20, sex: Sex.male);
    final high = norms.bodyFatBenchmark(bodyFatPercent: 35, sex: Sex.male);

    expect(lean.percentile, greaterThan(average.percentile));
    expect(average.percentile, greaterThan(high.percentile));
  });

  test('bodyFatBenchmark differs by sex for the same measured value', () {
    final menResult = norms.bodyFatBenchmark(bodyFatPercent: 20, sex: Sex.male);
    final womenResult = norms.bodyFatBenchmark(bodyFatPercent: 20, sex: Sex.female);

    // 20% is above-average leanness for men but below the "acceptable"
    // range's midpoint for women, so percentiles should diverge.
    expect(menResult.percentile, isNot(equals(womenResult.percentile)));
  });
}
