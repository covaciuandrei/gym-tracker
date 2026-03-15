import 'dart:async';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/attendance_stats.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/health/health_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';
import 'package:injectable/injectable.dart';

part 'stats_states.dart';

class _WorkoutDurationSourceData {
  const _WorkoutDurationSourceData({required this.prevDecember, required this.yearData, required this.types});

  final List<AttendanceDay> prevDecember;
  final List<AttendanceDay> yearData;
  final List<TrainingType> types;
}

@injectable
class StatsCubit extends BaseCubit {
  StatsCubit(this._attendanceService, this._workoutService, this._healthService);

  final AttendanceService _attendanceService;
  final WorkoutService _workoutService;
  final HealthService _healthService;

  int _activeYearToken = 0;
  final Map<int, _WorkoutDurationSourceData> _workoutDurationSourceDataByYear = {};

  void initYear(int year) {
    _activeYearToken++;
    safeEmit(StatsLoadedState.initial(year));
  }

  Future<void> loadTab({
    required String userId,
    required int year,
    required StatsTabKind tab,
    bool force = false,
  }) async {
    final stateForYear = _stateForYear(year);
    final token = _activeYearToken;

    switch (tab) {
      case StatsTabKind.attendances:
        await _loadAttendances(userId: userId, year: year, state: stateForYear, token: token, force: force);
        return;
      case StatsTabKind.workouts:
        await _loadWorkouts(userId: userId, year: year, state: stateForYear, token: token, force: force);
        return;
      case StatsTabKind.duration:
        await _loadDuration(userId: userId, year: year, state: stateForYear, token: token, force: force);
        return;
      case StatsTabKind.health:
        await _loadHealth(userId: userId, year: year, state: stateForYear, token: token, force: force);
        return;
    }
  }

  StatsLoadedState _stateForYear(int year) {
    final current = state;
    if (current is StatsLoadedState && current.year == year) {
      return current;
    }
    final next = StatsLoadedState.initial(year);
    safeEmit(next);
    return next;
  }

  Future<void> _loadAttendances({
    required String userId,
    required int year,
    required StatsLoadedState state,
    required int token,
    required bool force,
  }) async {
    if (!force) {
      if (state.attendancesStatus == StatsLoadStatus.loading || state.attendancesStatus == StatsLoadStatus.loaded) {
        return;
      }
    }

    safeEmit(state.copyWith(attendancesStatus: StatsLoadStatus.loading, clearAttendancesStats: true));
    try {
      final monthResults = await Future.wait<List<AttendanceDay>>(_attendanceMonthFutures(userId: userId, year: year));
      if (!_isRequestActive(year: year, token: token)) return;

      final prevDecember = monthResults[0];
      final yearData = monthResults.sublist(1).expand((list) => list).toList(growable: false);
      final stats = _computeStats(
        yearData: yearData,
        prevDecember: prevDecember,
        healthYearData: const <SupplementLog>[],
        monthlyHealthLogs: _emptyHealthMonths(),
        products: const <SupplementProduct>[],
        year: year,
      );

      final latest = _stateForYear(year);
      safeEmit(latest.copyWith(attendancesStatus: StatsLoadStatus.loaded, attendancesStats: stats));
    } catch (_) {
      if (!_isRequestActive(year: year, token: token)) return;
      final latest = _stateForYear(year);
      safeEmit(latest.copyWith(attendancesStatus: StatsLoadStatus.error, clearAttendancesStats: true));
    }
  }

  Future<void> _loadWorkouts({
    required String userId,
    required int year,
    required StatsLoadedState state,
    required int token,
    required bool force,
  }) async {
    if (!force) {
      if (state.workoutsStatus == StatsLoadStatus.loading || state.workoutsStatus == StatsLoadStatus.loaded) {
        return;
      }
    }

    safeEmit(state.copyWith(workoutsStatus: StatsLoadStatus.loading, clearWorkoutsStats: true));
    try {
      final sourceData = await _getWorkoutDurationSourceData(userId: userId, year: year, forceRefresh: force);
      if (!_isRequestActive(year: year, token: token)) return;

      final stats = _computeStats(
        yearData: sourceData.yearData,
        prevDecember: sourceData.prevDecember,
        healthYearData: const <SupplementLog>[],
        monthlyHealthLogs: _emptyHealthMonths(),
        products: const <SupplementProduct>[],
        year: year,
      );

      final latest = _stateForYear(year);
      safeEmit(latest.copyWith(workoutsStatus: StatsLoadStatus.loaded, workoutsStats: stats, types: sourceData.types));
    } catch (_) {
      if (!_isRequestActive(year: year, token: token)) return;
      final latest = _stateForYear(year);
      safeEmit(
        latest.copyWith(workoutsStatus: StatsLoadStatus.error, clearWorkoutsStats: true, types: const <TrainingType>[]),
      );
    }
  }

  Future<void> _loadDuration({
    required String userId,
    required int year,
    required StatsLoadedState state,
    required int token,
    required bool force,
  }) async {
    if (!force) {
      if (state.durationStatus == StatsLoadStatus.loading || state.durationStatus == StatsLoadStatus.loaded) {
        return;
      }
    }

    safeEmit(state.copyWith(durationStatus: StatsLoadStatus.loading, clearDurationStats: true));
    try {
      final sourceData = await _getWorkoutDurationSourceData(userId: userId, year: year, forceRefresh: force);
      if (!_isRequestActive(year: year, token: token)) return;

      final stats = _computeStats(
        yearData: sourceData.yearData,
        prevDecember: sourceData.prevDecember,
        healthYearData: const <SupplementLog>[],
        monthlyHealthLogs: _emptyHealthMonths(),
        products: const <SupplementProduct>[],
        year: year,
      );

      final latest = _stateForYear(year);
      safeEmit(latest.copyWith(durationStatus: StatsLoadStatus.loaded, durationStats: stats, types: sourceData.types));
    } catch (_) {
      if (!_isRequestActive(year: year, token: token)) return;
      final latest = _stateForYear(year);
      safeEmit(
        latest.copyWith(durationStatus: StatsLoadStatus.error, clearDurationStats: true, types: const <TrainingType>[]),
      );
    }
  }

  Future<_WorkoutDurationSourceData> _getWorkoutDurationSourceData({
    required String userId,
    required int year,
    required bool forceRefresh,
  }) async {
    final cached = _workoutDurationSourceDataByYear[year];
    if (!forceRefresh && cached != null) {
      return cached;
    }

    final futureResults = await Future.wait<dynamic>([
      Future.wait(_attendanceMonthFutures(userId: userId, year: year)),
      _workoutService.watchAll(userId).first.catchError((_) => <TrainingType>[]),
    ]);

    final monthResults = futureResults[0] as List<List<AttendanceDay>>;
    final types = futureResults[1] as List<TrainingType>;
    final next = _WorkoutDurationSourceData(
      prevDecember: monthResults[0],
      yearData: monthResults.sublist(1).expand((list) => list).toList(growable: false),
      types: types,
    );
    _workoutDurationSourceDataByYear[year] = next;
    return next;
  }

  Future<void> _loadHealth({
    required String userId,
    required int year,
    required StatsLoadedState state,
    required int token,
    required bool force,
  }) async {
    if (!force) {
      if (state.healthStatus == StatsLoadStatus.loading || state.healthStatus == StatsLoadStatus.loaded) {
        return;
      }
    }

    safeEmit(state.copyWith(healthStatus: StatsLoadStatus.loading, clearHealthStats: true));
    try {
      final healthMonthFutures = <Future<List<SupplementLog>>>[
        for (int m = 1; m <= 12; m++)
          _healthService
              .watchMonthEntries(userId: userId, year: year, month: m)
              .first
              .catchError((_) => <SupplementLog>[]),
      ];

      final futureResults = await Future.wait<dynamic>([
        Future.wait(healthMonthFutures),
        _healthService.watchAllProducts().first.catchError((_) => <SupplementProduct>[]),
      ]);
      if (!_isRequestActive(year: year, token: token)) return;

      final monthlyHealthLogs = futureResults[0] as List<List<SupplementLog>>;
      final products = futureResults[1] as List<SupplementProduct>;
      final healthYearData = monthlyHealthLogs.expand((list) => list).toList(growable: false);

      final stats = _computeStats(
        yearData: const <AttendanceDay>[],
        prevDecember: const <AttendanceDay>[],
        healthYearData: healthYearData,
        monthlyHealthLogs: monthlyHealthLogs,
        products: products,
        year: year,
      );

      final latest = _stateForYear(year);
      safeEmit(latest.copyWith(healthStatus: StatsLoadStatus.loaded, healthStats: stats));
    } catch (_) {
      if (!_isRequestActive(year: year, token: token)) return;
      final latest = _stateForYear(year);
      safeEmit(latest.copyWith(healthStatus: StatsLoadStatus.error, clearHealthStats: true));
    }
  }

  bool _isRequestActive({required int year, required int token}) {
    final current = state;
    return token == _activeYearToken && current is StatsLoadedState && current.year == year;
  }

  List<Future<List<AttendanceDay>>> _attendanceMonthFutures({required String userId, required int year}) {
    return <Future<List<AttendanceDay>>>[
      _attendanceService
          .watchMonth(userId: userId, year: year - 1, month: 12)
          .first
          .catchError((_) => <AttendanceDay>[]),
      for (int m = 1; m <= 12; m++)
        _attendanceService.watchMonth(userId: userId, year: year, month: m).first.catchError((_) => <AttendanceDay>[]),
    ];
  }

  List<List<SupplementLog>> _emptyHealthMonths() =>
      List<List<SupplementLog>>.generate(12, (_) => const <SupplementLog>[], growable: false);

  AttendanceStats _computeStats({
    required List<AttendanceDay> yearData,
    required List<AttendanceDay> prevDecember,
    required List<SupplementLog> healthYearData,
    required List<List<SupplementLog>> monthlyHealthLogs,
    required List<SupplementProduct> products,
    required int year,
  }) {
    final sortedYear = [...yearData]..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Monthly count: current calendar month if showing the current year,
    // otherwise December (month 12 is the natural "latest" for past years).
    final now = DateTime.now();
    final currentMonth = year == now.year ? now.month : 12;
    final monthlyCount = sortedYear.where((d) {
      final workoutDate = _tryParseDate(d.date);
      return workoutDate != null && workoutDate.year == year && workoutDate.month == currentMonth;
    }).length;

    // Monthly attendance counts.
    final monthlyAttendanceCounts = List<int>.filled(12, 0);
    for (final day in sortedYear) {
      final workoutDate = _tryParseDate(day.date);
      if (workoutDate != null && workoutDate.year == year) {
        final month = workoutDate.month;
        monthlyAttendanceCounts[month - 1]++;
      }
    }

    // Weekday distribution (DateTime.weekday: 1 = Mon … 7 = Sun).
    final weekdayCounts = List<int>.filled(8, 0);
    for (final day in sortedYear) {
      final workoutDate = _tryParseDate(day.date);
      if (workoutDate != null) {
        weekdayCounts[workoutDate.weekday]++;
      }
    }
    final maxCount = weekdayCounts.fold(0, (m, c) => c > m ? c : m);
    final favoriteDays = maxCount == 0
        ? <int>[]
        : [
            for (int i = 1; i <= 7; i++)
              if (weekdayCounts[i] == maxCount) i,
          ];

    final weekdayAttendanceCounts = [for (int i = 1; i <= 7; i++) weekdayCounts[i]];

    // Type distribution.
    final typeDistribution = <String, int>{};
    final monthlyTypeDistribution = <int, Map<String, int>>{};
    for (final day in sortedYear) {
      if (day.trainingTypeId != null) {
        final workoutDate = _tryParseDate(day.date);
        if (workoutDate == null || workoutDate.year != year) continue;

        final typeId = day.trainingTypeId!;
        final month = workoutDate.month;

        typeDistribution[typeId] = (typeDistribution[typeId] ?? 0) + 1;

        final monthMap = monthlyTypeDistribution[month] ?? <String, int>{};
        monthMap[typeId] = (monthMap[typeId] ?? 0) + 1;
        monthlyTypeDistribution[month] = monthMap;
      }
    }

    // Monthly duration averages.
    final monthDurTotals = <int, int>{};
    final monthDurCounts = <int, int>{};
    final monthlyUntrackedDurationCounts = List<int>.filled(12, 0);

    final monthTypeDurTotals = <int, Map<String, int>>{};
    final monthTypeDurCounts = <int, Map<String, int>>{};

    int yearlyDurationTotal = 0;
    int yearlyDurationCount = 0;

    for (final day in sortedYear) {
      final workoutDate = _tryParseDate(day.date);
      if (workoutDate == null || workoutDate.year != year) continue;

      final month = workoutDate.month;
      final duration = day.durationMinutes;

      if (duration != null && duration > 0) {
        monthDurTotals[month] = (monthDurTotals[month] ?? 0) + duration;
        monthDurCounts[month] = (monthDurCounts[month] ?? 0) + 1;

        yearlyDurationTotal += duration;
        yearlyDurationCount++;

        final typeId = day.trainingTypeId;
        if (typeId != null) {
          final typeDurTotals = monthTypeDurTotals[month] ?? <String, int>{};
          typeDurTotals[typeId] = (typeDurTotals[typeId] ?? 0) + duration;
          monthTypeDurTotals[month] = typeDurTotals;

          final typeDurCounts = monthTypeDurCounts[month] ?? <String, int>{};
          typeDurCounts[typeId] = (typeDurCounts[typeId] ?? 0) + 1;
          monthTypeDurCounts[month] = typeDurCounts;
        }
      } else {
        monthlyUntrackedDurationCounts[month - 1]++;
      }
    }
    final monthlyDurationAverages = {for (final m in monthDurTotals.keys) m: monthDurTotals[m]! / monthDurCounts[m]!};

    final monthlyTypeDurationAverages = <int, Map<String, double>>{};
    for (final month in monthTypeDurTotals.keys) {
      final totals = monthTypeDurTotals[month] ?? const <String, int>{};
      final counts = monthTypeDurCounts[month] ?? const <String, int>{};
      monthlyTypeDurationAverages[month] = {
        for (final typeId in totals.keys)
          if ((counts[typeId] ?? 0) > 0) typeId: totals[typeId]! / counts[typeId]!,
      };
    }

    final yearlyAverageDurationMinutes = yearlyDurationCount == 0 ? 0.0 : yearlyDurationTotal / yearlyDurationCount;

    final yearlyUntrackedDurationCount = monthlyUntrackedDurationCounts.fold(0, (sum, value) => sum + value);

    // Per-type duration averages.
    final typeDurTotals = <String, int>{};
    final typeDurCounts = <String, int>{};
    for (final day in sortedYear) {
      if (day.trainingTypeId != null && day.durationMinutes != null && day.durationMinutes! > 0) {
        final tid = day.trainingTypeId!;
        typeDurTotals[tid] = (typeDurTotals[tid] ?? 0) + day.durationMinutes!;
        typeDurCounts[tid] = (typeDurCounts[tid] ?? 0) + 1;
      }
    }
    final perTypeDurationAverages = {
      for (final tid in typeDurTotals.keys) tid: typeDurTotals[tid]! / typeDurCounts[tid]!,
    };

    // Health aggregates.
    final monthlyHealthServings = List<double>.filled(12, 0);
    final monthlySupplementServings = <int, Map<String, double>>{};
    final productServings = <String, double>{};

    final productsById = {for (final product in products) product.id: product};
    final productNames = {for (final product in products) product.id: product.name};
    final productBrands = {for (final product in products) product.id: product.brand};

    final daysWithSupplements = <String>{};
    final nutrientTotals = <String, NutrientTotal>{};

    for (int month = 1; month <= monthlyHealthLogs.length; month++) {
      final monthMap = <String, double>{};
      for (final log in monthlyHealthLogs[month - 1]) {
        monthlyHealthServings[month - 1] += log.servingsTaken;
        monthMap[log.productId] = (monthMap[log.productId] ?? 0) + log.servingsTaken;

        productServings[log.productId] = (productServings[log.productId] ?? 0) + log.servingsTaken;

        final parsedDate = _tryParseDate(log.date);
        if (parsedDate != null) {
          daysWithSupplements.add(
            '${parsedDate.year}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.day.toString().padLeft(2, '0')}',
          );
        }

        final product = productsById[log.productId];
        if (product == null) continue;
        for (final ingredient in product.ingredients) {
          final key = '${ingredient.stdId}|${ingredient.unit}';
          final existing = nutrientTotals[key];
          final amount = ingredient.amount * log.servingsTaken;
          nutrientTotals[key] = NutrientTotal(
            name: ingredient.name,
            amount: (existing?.amount ?? 0) + amount,
            unit: ingredient.unit,
          );
        }
      }
      monthlySupplementServings[month] = monthMap;
    }

    final currentYear = DateTime.now().year;
    final nowDate = DateTime.now();
    final endDate = year == currentYear ? nowDate : DateTime(year, 12, 31);
    final totalDaysElapsed = endDate.difference(DateTime(year, 1, 1)).inDays + 1;
    final healthConsistencyPct = totalDaysElapsed <= 0 ? 0.0 : (daysWithSupplements.length / totalDaysElapsed) * 100;

    String? mostTakenSupplementName;
    String? mostTakenSupplementBrand;
    double mostTakenSupplementCount = 0;
    if (productServings.isNotEmpty) {
      final top = productServings.entries.reduce((a, b) => a.value >= b.value ? a : b);
      mostTakenSupplementCount = top.value;
      mostTakenSupplementName = productNames[top.key] ?? top.key;
      mostTakenSupplementBrand = productBrands[top.key] ?? '';
    }

    final topNutrients = nutrientTotals.values.toList(growable: false)..sort((a, b) => b.amount.compareTo(a.amount));

    // Weekly streaks (include previous December for cross-year continuity).
    final (currentStreak, bestStreak) = _computeStreaks([...prevDecember, ...sortedYear]);
    final (currentStreakInfo, bestStreakInfo) = _computeStreaksWithDates([...prevDecember, ...sortedYear]);

    // Calculate favorite day count
    final maxFavoriteCount = weekdayCounts.fold(0, (m, c) => c > m ? c : m);
    final favoriteDayCount = maxFavoriteCount;

    return AttendanceStats(
      totalCount: sortedYear.length,
      yearlyCount: sortedYear.length,
      monthlyCount: monthlyCount,
      currentWeekStreak: currentStreak,
      bestWeekStreak: bestStreak,
      currentStreakInfo: currentStreakInfo,
      bestStreakInfo: bestStreakInfo,
      favoriteDaysOfWeek: favoriteDays,
      favoriteDayCount: favoriteDayCount,
      weekdayAttendanceCounts: weekdayAttendanceCounts,
      monthlyAttendanceCounts: monthlyAttendanceCounts,
      typeDistribution: typeDistribution,
      monthlyTypeDistribution: monthlyTypeDistribution,
      monthlyDurationAverages: monthlyDurationAverages,
      monthlyTypeDurationAverages: monthlyTypeDurationAverages,
      perTypeDurationAverages: perTypeDurationAverages,
      yearlyAverageDurationMinutes: yearlyAverageDurationMinutes,
      yearlyUntrackedDurationCount: yearlyUntrackedDurationCount,
      monthlyUntrackedDurationCounts: monthlyUntrackedDurationCounts,
      healthTotalLogs: healthYearData.length,
      healthConsistencyPct: healthConsistencyPct,
      monthlyHealthServings: monthlyHealthServings,
      mostTakenSupplementName: mostTakenSupplementName,
      mostTakenSupplementBrand: mostTakenSupplementBrand,
      mostTakenSupplementCount: mostTakenSupplementCount,
      monthlySupplementServings: monthlySupplementServings,
      productNames: productNames,
      productBrands: productBrands,
      topNutrients: topNutrients.take(5).toList(growable: false),
    );
  }

  /// Returns the "YYYY-MM-DD" string of the Monday that starts the ISO week
  /// containing [date].
  String _isoWeekMonday(DateTime date) {
    // Using T12:00:00 noon time avoids DST-boundary edge cases when
    // subtracting whole days.
    final d = DateTime(date.year, date.month, date.day, 12);
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
    final (currentStreak, bestStreak) = _computeStreaksWithDates(data);
    return (currentStreak.count, bestStreak.count);
  }

  /// Calculates detailed streak information with start and end dates.
  (StreakInfo current, StreakInfo best) _computeStreaksWithDates(List<AttendanceDay> data) {
    if (data.isEmpty) {
      return (
        const StreakInfo(count: 0, startDate: '', endDate: ''),
        const StreakInfo(count: 0, startDate: '', endDate: ''),
      );
    }

    // Collect the unique ISO-week Monday strings present in the data.
    final weekSet = <String>{};
    final weekFirstDates = <String, String>{};
    final weekLastDates = <String, String>{};

    for (final day in data) {
      final weekMonday = _isoWeekMonday(day.timestamp);
      weekSet.add(weekMonday);

      // Track first and last attendance dates for each week
      if (!weekFirstDates.containsKey(weekMonday) ||
          day.timestamp.isBefore(DateTime.parse(weekFirstDates[weekMonday]!))) {
        weekFirstDates[weekMonday] = day.timestamp.toIso8601String().substring(0, 10);
      }
      if (!weekLastDates.containsKey(weekMonday) || day.timestamp.isAfter(DateTime.parse(weekLastDates[weekMonday]!))) {
        weekLastDates[weekMonday] = day.timestamp.toIso8601String().substring(0, 10);
      }
    }

    final weeks = weekSet.toList()..sort();
    if (weeks.isEmpty) {
      return (
        const StreakInfo(count: 0, startDate: '', endDate: ''),
        const StreakInfo(count: 0, startDate: '', endDate: ''),
      );
    }

    // Walk through sorted weeks and build a list of streak info
    int runLen = 1;
    final allStreaks = <(int length, String startWeek, String endWeek)>[];
    String currentRunStart = weeks.first;

    for (int i = 1; i < weeks.length; i++) {
      final prev = DateTime.parse('${weeks[i - 1]}T12:00:00');
      final curr = DateTime.parse('${weeks[i]}T12:00:00');
      if (curr.difference(prev).inDays == 7) {
        runLen++;
      } else {
        allStreaks.add((runLen, currentRunStart, weeks[i - 1]));
        runLen = 1;
        currentRunStart = weeks[i];
      }
    }
    allStreaks.add((runLen, currentRunStart, weeks.last));

    // Find best streak
    final bestStreakData = allStreaks.fold<(int length, String startWeek, String endWeek)>((
      0,
      '',
      '',
    ), (best, streak) => streak.$1 > best.$1 ? streak : best);

    final bestStreak = StreakInfo(
      count: bestStreakData.$1,
      startDate: weekFirstDates[bestStreakData.$2] ?? '',
      endDate: weekLastDates[bestStreakData.$3] ?? '',
    );

    // Current streak: the last run is still active only when its ending week
    // equals the current ISO week or the immediately preceding one.
    final todayMonday = _isoWeekMonday(DateTime.now());
    final prevMonday = DateTime.parse(
      '${todayMonday}T12:00:00',
    ).subtract(const Duration(days: 7)).toIso8601String().substring(0, 10);

    final (lastLen, lastStartWeek, lastEndWeek) = allStreaks.last;
    final isCurrentStreakActive = lastEndWeek == todayMonday || lastEndWeek == prevMonday;

    final currentStreak = isCurrentStreakActive
        ? StreakInfo(
            count: lastLen,
            startDate: weekFirstDates[lastStartWeek] ?? '',
            endDate: weekLastDates[lastEndWeek] ?? '',
          )
        : const StreakInfo(count: 0, startDate: '', endDate: '');

    return (currentStreak, bestStreak);
  }

  DateTime? _tryParseDate(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
