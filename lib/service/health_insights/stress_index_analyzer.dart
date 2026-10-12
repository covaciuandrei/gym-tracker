import 'dart:math' show sqrt;

import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/health_insights/stress_index.dart';
import 'package:injectable/injectable.dart';

/// Derives a 0-100 "stress index" from how far today's heart-rate
/// variability sits below the user's own rolling 60-day baseline \u2014 lower
/// HRV relative to personal baseline is a commonly-cited proxy for higher
/// physiological stress load. 50 = typical for you; higher = more stressed
/// than usual, lower = more relaxed than usual.
///
/// Intentionally self-baselined only (like heart-rate recovery) \u2014 there is
/// no population norm for "stress" that would be meaningful to compare
/// against.
@injectable
class StressIndexAnalyzer {
  const StressIndexAnalyzer();

  static const _baselineWindowDays = 60;

  /// [hrvSamples] must be ascending by date. Returns `null` when there's no
  /// HRV reading for the most recent day, or fewer than 5 other days in the
  /// trailing 60-day baseline window.
  StressIndex? analyze({required List<HealthSample> hrvSamples}) {
    if (hrvSamples.isEmpty) return null;
    final latestDate = _dateOnly(hrvSamples.last.dateFrom);

    final today = _dailyAverage(hrvSamples, latestDate);
    if (today == null) return null;

    final baselineCutoff = latestDate.subtract(const Duration(days: _baselineWindowDays));
    final baselineValues = hrvSamples
        .where((s) => !_dateOnly(s.dateFrom).isAtSameMomentAs(latestDate))
        .where((s) => !s.dateFrom.isBefore(baselineCutoff) && !s.dateFrom.isAfter(latestDate))
        .map((s) => s.value)
        .toList();
    if (baselineValues.length < 5) return null;

    final mean = baselineValues.reduce((a, b) => a + b) / baselineValues.length;
    final variance =
        baselineValues.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / (baselineValues.length - 1);
    final stdDev = variance > 0 ? sqrt(variance) : 0.0;

    // z > 0 means today's HRV is ABOVE baseline (less stressed); invert so a
    // LOWER HRV maps to a HIGHER stress value.
    final z = stdDev > 0 ? (today - mean) / stdDev : 0.0;
    final score = (50 - z * 20).clamp(0, 100).round();

    return StressIndex(value: score, band: _bandFor(score), hrvMs: today, baselineHrvMs: mean);
  }

  StressBand _bandFor(int score) {
    if (score < 35) return StressBand.low;
    if (score < 60) return StressBand.typical;
    if (score < 80) return StressBand.elevated;
    return StressBand.high;
  }

  double? _dailyAverage(List<HealthSample> samples, DateTime date) {
    final values = samples.where((s) => _dateOnly(s.dateFrom).isAtSameMomentAs(date)).map((s) => s.value).toList();
    if (values.isEmpty) return null;
    return values.reduce((a, b) => a + b) / values.length;
  }

  DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
}
