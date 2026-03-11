import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/attendance_stats.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';

part 'stats_states.dart';

@injectable
class StatsCubit extends BaseCubit {
  StatsCubit(this._attendanceService, this._workoutService);

  final AttendanceService _attendanceService;
  final WorkoutService _workoutService;

  /// Loads all attendance data for [year] (+ previous December for cross-year
  /// streak accuracy) and the user's training types, then aggregates into an
  /// [AttendanceStats] and emits [StatsLoadedState].
  Future<void> load({required String userId, required int year}) async {
    safeEmit(const PendingState());
    try {
      // Previous December is included so that a streak spanning the year
      // boundary (e.g. Dec + Jan) counts correctly.
      final monthFutures = <Future<List<AttendanceDay>>>[
        _attendanceService
            .watchMonth(userId: userId, year: year - 1, month: 12)
            .first,
        for (int m = 1; m <= 12; m++)
          _attendanceService
              .watchMonth(userId: userId, year: year, month: m)
              .first,
      ];

      final monthResults = await Future.wait(monthFutures);
      final types = await _workoutService.watchAll(userId).first;

      final prevDecember = monthResults[0];
      final yearData =
          monthResults.sublist(1).expand((list) => list).toList();

      final stats = _computeStats(
        yearData: yearData,
        prevDecember: prevDecember,
        year: year,
      );

      safeEmit(StatsLoadedState(stats: stats, year: year, types: types));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Aggregation ──────────────────────────────────────────────────────────

  AttendanceStats _computeStats({
    required List<AttendanceDay> yearData,
    required List<AttendanceDay> prevDecember,
    required int year,
  }) {
    final sortedYear = [...yearData]
      ..sort((a, b) => a.date.compareTo(b.date));

    // Monthly count: current calendar month if showing the current year,
    // otherwise December (month 12 is the natural "latest" for past years).
    final now = DateTime.now();
    final currentMonth = year == now.year ? now.month : 12;
    final monthPrefix = '$year-${currentMonth.toString().padLeft(2, '0')}';
    final monthlyCount =
        sortedYear.where((d) => d.date.startsWith(monthPrefix)).length;

    // Weekday distribution (DateTime.weekday: 1 = Mon … 7 = Sun).
    final weekdayCounts = List<int>.filled(8, 0);
    for (final day in sortedYear) {
      weekdayCounts[DateTime.parse(day.date).weekday]++;
    }
    final maxCount = weekdayCounts.fold(0, (m, c) => c > m ? c : m);
    final favoriteDays = maxCount == 0
        ? <int>[]
        : [for (int i = 1; i <= 7; i++) if (weekdayCounts[i] == maxCount) i];

    // Type distribution.
    final typeDistribution = <String, int>{};
    for (final day in sortedYear) {
      if (day.trainingTypeId != null) {
        typeDistribution[day.trainingTypeId!] =
            (typeDistribution[day.trainingTypeId!] ?? 0) + 1;
      }
    }

    // Monthly duration averages.
    final monthDurTotals = <int, int>{};
    final monthDurCounts = <int, int>{};
    for (final day in sortedYear) {
      if (day.durationMinutes != null && day.durationMinutes! > 0) {
        final m = int.parse(day.date.substring(5, 7));
        monthDurTotals[m] = (monthDurTotals[m] ?? 0) + day.durationMinutes!;
        monthDurCounts[m] = (monthDurCounts[m] ?? 0) + 1;
      }
    }
    final monthlyDurationAverages = {
      for (final m in monthDurTotals.keys)
        m: monthDurTotals[m]! / monthDurCounts[m]!,
    };

    // Per-type duration averages.
    final typeDurTotals = <String, int>{};
    final typeDurCounts = <String, int>{};
    for (final day in sortedYear) {
      if (day.trainingTypeId != null &&
          day.durationMinutes != null &&
          day.durationMinutes! > 0) {
        final tid = day.trainingTypeId!;
        typeDurTotals[tid] = (typeDurTotals[tid] ?? 0) + day.durationMinutes!;
        typeDurCounts[tid] = (typeDurCounts[tid] ?? 0) + 1;
      }
    }
    final perTypeDurationAverages = {
      for (final tid in typeDurTotals.keys)
        tid: typeDurTotals[tid]! / typeDurCounts[tid]!,
    };

    // Weekly streaks (include previous December for cross-year continuity).
    final (currentStreak, bestStreak) =
        _computeStreaks([...prevDecember, ...sortedYear]);

    return AttendanceStats(
      totalCount: sortedYear.length,
      yearlyCount: sortedYear.length,
      monthlyCount: monthlyCount,
      currentWeekStreak: currentStreak,
      bestWeekStreak: bestStreak,
      favoriteDaysOfWeek: favoriteDays,
      typeDistribution: typeDistribution,
      monthlyDurationAverages: monthlyDurationAverages,
      perTypeDurationAverages: perTypeDurationAverages,
    );
  }

  // ─── ISO-week streak helpers ──────────────────────────────────────────────

  /// Returns the "YYYY-MM-DD" string of the Monday that starts the ISO week
  /// containing [dateStr].
  String _isoWeekMonday(String dateStr) {
    // Using T12:00:00 noon time avoids DST-boundary edge cases when
    // subtracting whole days.
    final d = DateTime.parse('${dateStr}T12:00:00');
    final monday = d.subtract(Duration(days: d.weekday - 1));
    final mm = monday.month.toString().padLeft(2, '0');
    final dd = monday.day.toString().padLeft(2, '0');
    return '${monday.year}-$mm-$dd';
  }

  /// Calculates the (currentStreak, bestStreak) pair from [data].
  ///
  /// A "streak" is a run of consecutive ISO weeks each containing at least one
  /// attendance record. The current streak is the length of the most-recent
  /// consecutive run, provided its last week is either the current ISO week or
  /// the immediately preceding one (i.e. the streak is still active or was
  /// active last week).
  (int current, int best) _computeStreaks(List<AttendanceDay> data) {
    if (data.isEmpty) return (0, 0);

    // Collect the unique ISO-week Monday strings present in the data.
    final weekSet = <String>{};
    for (final day in data) {
      weekSet.add(_isoWeekMonday(day.date));
    }
    final weeks = weekSet.toList()..sort();
    if (weeks.isEmpty) return (0, 0);

    // Walk through sorted weeks and build a list of (runLength, endWeekMonday).
    int runLen = 1;
    final allStreaks = <(int length, String endWeek)>[];
    for (int i = 1; i < weeks.length; i++) {
      final prev = DateTime.parse('${weeks[i - 1]}T12:00:00');
      final curr = DateTime.parse('${weeks[i]}T12:00:00');
      if (curr.difference(prev).inDays == 7) {
        runLen++;
      } else {
        allStreaks.add((runLen, weeks[i - 1]));
        runLen = 1;
      }
    }
    allStreaks.add((runLen, weeks.last));

    final best = allStreaks.fold(0, (m, s) => s.$1 > m ? s.$1 : m);

    // Current streak: the last run is still active only when its ending week
    // equals the current ISO week or the immediately preceding one.
    final todayMonday =
        _isoWeekMonday(DateTime.now().toIso8601String().substring(0, 10));
    final prevMonday = DateTime.parse('${todayMonday}T12:00:00')
        .subtract(const Duration(days: 7))
        .toIso8601String()
        .substring(0, 10);

    final (lastLen, lastEndWeek) = allStreaks.last;
    final current =
        (lastEndWeek == todayMonday || lastEndWeek == prevMonday)
            ? lastLen
            : 0;

    return (current, best);
  }
}
