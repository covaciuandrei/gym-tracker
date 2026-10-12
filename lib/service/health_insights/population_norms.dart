import 'package:gym_tracker/model/health_insights/population_benchmark.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:injectable/injectable.dart';

/// Bundled, static population reference tables used to benchmark a measured
/// value against other people of the same sex (and, for VO2Max and weight,
/// age band).
///
/// These are APPROXIMATE, illustrative bands inspired by commonly published
/// fitness literature (Cooper Institute / ACSM-style cardiorespiratory
/// fitness norms; ACE body-composition categories) and, for the average-BMI
/// table, anchored to real US adult averages (CDC/NHANES "Anthropometric
/// Reference Data", Aug 2021–Aug 2023: men 20+ average ~90.3kg at ~175cm
/// (BMI ≈29.5); women 20+ average ~77.9kg at ~161cm (BMI ≈29.9)) with
/// illustrative decade-by-decade variation \u2014 not fitted to a single
/// verified per-decade source, and never a medical or diagnostic
/// percentile. Always presented in the UI as a wellness/fitness estimate.
/// No network calls — everything here is a compile-time constant table.
@injectable
class PopulationNorms {
  const PopulationNorms();

  /// VO2Max (mL/(min·kg)) reference points per age-decade floor and sex, at
  /// the 10th/30th/50th/70th/90th percentile (ascending).
  static const Map<Sex, Map<int, List<double>>> _vo2MaxByAgeDecade = {
    Sex.male: {
      20: [38, 44, 48, 53, 59],
      30: [34, 40, 44, 49, 55],
      40: [31, 37, 41, 45, 51],
      50: [28, 33, 37, 41, 47],
      60: [24, 29, 33, 37, 42],
      70: [21, 25, 29, 33, 38],
    },
    Sex.female: {
      20: [32, 37, 41, 45, 50],
      30: [29, 34, 37, 41, 46],
      40: [27, 31, 34, 38, 43],
      50: [24, 28, 31, 34, 39],
      60: [21, 24, 27, 30, 35],
      70: [18, 21, 24, 27, 31],
    },
  };
  static const List<int> _vo2MaxPercentileAnchors = [10, 30, 50, 70, 90];

  /// ACE-style body-fat-% breakpoints mapped to an approximate percentile
  /// among adults of the same sex (higher body fat → lower percentile).
  /// Index 3 (percentile 50) is also this table's "average" reference value
  /// — reused by [PopulationComparisonAnalyzer] so the app never shows two
  /// disagreeing "average body fat" numbers.
  static const Map<Sex, List<double>> _bodyFatBreakpoints = {
    Sex.male: [3, 9, 14, 18, 21, 25, 30],
    Sex.female: [12, 17, 21, 25, 28, 32, 37],
  };
  static const List<int> _bodyFatPercentiles = [95, 85, 70, 50, 35, 20, 8];
  static const _bodyFatMedianIndex = 3;

  /// Average adult BMI per age-decade floor and sex — illustrative
  /// decade-by-decade shape (rises from young adulthood into middle age,
  /// eases slightly in the oldest bracket) anchored to the real overall
  /// adult averages cited above.
  static const Map<Sex, Map<int, double>> _averageBmiByAgeDecade = {
    Sex.male: {20: 26.5, 30: 28.5, 40: 29.5, 50: 30.0, 60: 29.5, 70: 28.0},
    Sex.female: {20: 27.0, 30: 29.0, 40: 30.0, 50: 30.5, 60: 30.0, 70: 28.5},
  };

  int _decadeFloor(int age) => ((age ~/ 10) * 10).clamp(20, 70);

  List<double> _vo2MaxAnchorsForAge({required int age, required Sex sex}) {
    final table = _vo2MaxByAgeDecade[sex] ?? _vo2MaxByAgeDecade[Sex.male]!;
    return table[_decadeFloor(age)]!;
  }

  /// The average adult weight (kg) for a person of [heightCm] in the given
  /// [age]/[sex] decade band, derived from [_averageBmiByAgeDecade].
  double averageWeightKg({required double heightCm, required int age, required Sex sex}) {
    final table = _averageBmiByAgeDecade[sex] ?? _averageBmiByAgeDecade[Sex.male]!;
    final bmi = table[_decadeFloor(age)]!;
    final heightM = heightCm / 100;
    return bmi * heightM * heightM;
  }

  /// The average adult body-fat % for [sex] (not age-adjusted — ACE's own
  /// categories aren't age-banded either; see [bodyFatBenchmark]).
  double averageBodyFatPercent({required Sex sex}) {
    final breakpoints = _bodyFatBreakpoints[sex] ?? _bodyFatBreakpoints[Sex.male]!;
    return breakpoints[_bodyFatMedianIndex];
  }

  /// Approximate percentile standing for a measured [vo2Max].
  PopulationBenchmark vo2MaxBenchmark({required double vo2Max, required int age, required Sex sex}) {
    final anchors = _vo2MaxAnchorsForAge(age: age, sex: sex);
    final percentile = _interpolate(value: vo2Max, xs: anchors, ys: _vo2MaxPercentileAnchors);
    final decade = _decadeFloor(age);
    final sexLabel = sex == Sex.male ? 'Men' : 'Women';
    return PopulationBenchmark(
      percentile: percentile,
      band: _bandForPercentile(percentile),
      cohortLabel: '$sexLabel, $decade–${decade + 9}',
      averageValue: anchors[2],
    );
  }

  /// Approximate percentile standing for a measured [bodyFatPercent] among
  /// adults of the same sex (not age-adjusted — ACE's own categories aren't
  /// age-banded either).
  PopulationBenchmark bodyFatBenchmark({required double bodyFatPercent, required Sex sex}) {
    final breakpoints = _bodyFatBreakpoints[sex] ?? _bodyFatBreakpoints[Sex.male]!;
    final percentile = _interpolate(value: bodyFatPercent, xs: breakpoints, ys: _bodyFatPercentiles);
    return PopulationBenchmark(
      percentile: percentile,
      band: _bandForPercentile(percentile),
      cohortLabel: sex == Sex.male ? 'Men, all adults' : 'Women, all adults',
      averageValue: breakpoints[_bodyFatMedianIndex],
    );
  }

  /// Piecewise-linear interpolation of `value` within the ascending `xs` →
  /// `ys` control points (which may themselves be ascending or descending),
  /// clamped to the first/last `ys` outside the table's range.
  int _interpolate({required double value, required List<double> xs, required List<int> ys}) {
    if (value <= xs.first) return ys.first;
    if (value >= xs.last) return ys.last;
    for (var i = 0; i < xs.length - 1; i++) {
      final lo = xs[i];
      final hi = xs[i + 1];
      if (value >= lo && value <= hi) {
        final t = hi == lo ? 0.0 : (value - lo) / (hi - lo);
        return (ys[i] + t * (ys[i + 1] - ys[i])).round();
      }
    }
    return ys[ys.length ~/ 2];
  }

  String _bandForPercentile(int percentile) {
    if (percentile >= 90) return 'Excellent';
    if (percentile >= 70) return 'Above average';
    if (percentile >= 40) return 'Average';
    if (percentile >= 20) return 'Below average';
    return 'Low';
  }
}

