import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/health/health_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';

part 'calendar_states.dart';

@injectable
class CalendarCubit extends BaseCubit {
  CalendarCubit(
    this._attendanceService,
    this._healthService,
    this._workoutService,
  );

  final AttendanceService _attendanceService;
  final HealthService _healthService;
  final WorkoutService _workoutService;

  final List<StreamSubscription<List<AttendanceDay>>>
  _monthAttendanceSubscriptions = <StreamSubscription<List<AttendanceDay>>>[];
  final List<StreamSubscription<List<SupplementLog>>>
  _monthHealthSubscriptions = <StreamSubscription<List<SupplementLog>>>[];
  StreamSubscription<List<SupplementProduct>>? _productsSubscription;
  StreamSubscription<List<TrainingType>>? _typesSubscription;

  List<AttendanceDay> _monthDays = const <AttendanceDay>[];
  List<SupplementLog> _monthLogs = const <SupplementLog>[];
  List<SupplementProduct> _products = const <SupplementProduct>[];
  List<TrainingType> _types = const <TrainingType>[];

  int _activeMonthYear = 0;
  int _activeMonth = 0;

  final Map<int, List<AttendanceDay>> _attendanceByMonthKey =
      <int, List<AttendanceDay>>{};
  final Map<int, List<SupplementLog>> _healthByMonthKey =
      <int, List<SupplementLog>>{};

  int _monthKey(int year, int month) => year * 100 + month;

  Iterable<DateTime> _surroundingMonths(int year, int month) sync* {
    yield DateTime(year, month - 1, 1);
    yield DateTime(year, month, 1);
    yield DateTime(year, month + 1, 1);
  }

  List<AttendanceDay> _mergedAttendance() {
    return _attendanceByMonthKey.values
        .expand((list) => list)
        .toList(growable: false);
  }

  List<SupplementLog> _mergedHealthLogs() {
    return _healthByMonthKey.values
        .expand((list) => list)
        .where((log) => log.servingsTaken > 0)
        .toList(growable: false);
  }

  void _emitMonthLoaded() {
    if (_activeMonthYear == 0 || _activeMonth == 0) {
      return;
    }
    safeEmit(
      CalendarMonthLoadedState(
        days: _monthDays,
        healthLogs: _monthLogs,
        products: _products,
        workoutTypes: _types,
        year: _activeMonthYear,
        month: _activeMonth,
      ),
    );
  }

  /// Subscribes to attendance data for the given [year]/[month] and emits
  /// [CalendarMonthLoadedState] on every update. Cancels any previous
  /// subscription when called again (e.g. when the user pages to a new month).
  void loadMonth({
    required String userId,
    required int year,
    required int month,
  }) {
    for (final sub in _monthAttendanceSubscriptions) {
      sub.cancel();
    }
    _monthAttendanceSubscriptions.clear();
    for (final sub in _monthHealthSubscriptions) {
      sub.cancel();
    }
    _monthHealthSubscriptions.clear();
    _productsSubscription?.cancel();
    _typesSubscription?.cancel();

    _activeMonthYear = year;
    _activeMonth = month;

    _monthDays = const <AttendanceDay>[];
    _monthLogs = const <SupplementLog>[];
    _products = const <SupplementProduct>[];
    _types = const <TrainingType>[];
    _attendanceByMonthKey.clear();
    _healthByMonthKey.clear();

    safeEmit(const PendingState());

    for (final monthDate in _surroundingMonths(year, month)) {
      final y = monthDate.year;
      final m = monthDate.month;
      final key = _monthKey(y, m);

      final attendanceSub = _attendanceService
          .watchMonth(userId: userId, year: y, month: m)
          .listen(
            (days) {
              _attendanceByMonthKey[key] = days;
              _monthDays = _mergedAttendance();
              _emitMonthLoaded();
            },
            onError: (_) {
              _attendanceByMonthKey[key] = const <AttendanceDay>[];
              _monthDays = _mergedAttendance();
              _emitMonthLoaded();
            },
          );
      _monthAttendanceSubscriptions.add(attendanceSub);

      final healthSub = _healthService
          .watchMonthEntries(userId: userId, year: y, month: m)
          .listen(
            (logs) {
              _healthByMonthKey[key] = logs;
              _monthLogs = _mergedHealthLogs();
              _emitMonthLoaded();
            },
            onError: (_) {
              _healthByMonthKey[key] = const <SupplementLog>[];
              _monthLogs = _mergedHealthLogs();
              _emitMonthLoaded();
            },
          );
      _monthHealthSubscriptions.add(healthSub);
    }

    _productsSubscription = _healthService.watchAllProducts().listen(
      (products) {
        _products = products;
        _emitMonthLoaded();
      },
      onError: (_) {
        _products = const <SupplementProduct>[];
        _emitMonthLoaded();
      },
    );

    _typesSubscription = _workoutService
        .watchAll(userId)
        .listen(
          (types) {
            _types = types;
            _emitMonthLoaded();
          },
          onError: (_) {
            _types = const <TrainingType>[];
            _emitMonthLoaded();
          },
        );
  }

  Future<void> loadYear({required String userId, required int year}) async {
    safeEmit(const PendingState());
    try {
      final attendanceFutures = <Future<List<AttendanceDay>>>[
        for (int month = 1; month <= 12; month++)
          _attendanceService
              .watchMonth(userId: userId, year: year, month: month)
              .first
              .catchError((_) => <AttendanceDay>[]),
      ];

      final healthFutures = <Future<List<SupplementLog>>>[
        for (int month = 1; month <= 12; month++)
          _healthService
              .watchMonthEntries(userId: userId, year: year, month: month)
              .first
              .catchError((_) => <SupplementLog>[]),
      ];

      final results = await Future.wait<dynamic>([
        Future.wait(attendanceFutures),
        Future.wait(healthFutures),
        _workoutService
            .watchAll(userId)
            .first
            .catchError((_) => <TrainingType>[]),
      ]);

      final attendance = results[0] as List<List<AttendanceDay>>;
      final health = results[1] as List<List<SupplementLog>>;
      final types = results[2] as List<TrainingType>;

      final attendanceByMonth = <int, List<AttendanceDay>>{
        for (int month = 1; month <= 12; month++) month: attendance[month - 1],
      };
      final healthByMonth = <int, List<SupplementLog>>{
        for (int month = 1; month <= 12; month++)
          month: health[month - 1]
              .where((log) => log.servingsTaken > 0)
              .toList(growable: false),
      };

      safeEmit(
        CalendarYearLoadedState(
          attendanceByMonth: attendanceByMonth,
          supplementsByMonth: healthByMonth,
          workoutTypes: types,
          year: year,
        ),
      );
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> logSupplement({
    required String userId,
    required SupplementLog model,
  }) async {
    await guardedAction(() async {
      try {
        final id = await _healthService.logSupplement(
          userId: userId,
          model: model,
        );
        safeEmit(CalendarSupplementLoggedState(id: id));
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  Future<void> deleteSupplementEntry({
    required String userId,
    required String date,
    required String entryId,
  }) async {
    await guardedAction(() async {
      try {
        await _healthService.deleteEntry(
          userId: userId,
          date: date,
          entryId: entryId,
        );
        safeEmit(const CalendarSupplementDeletedState());
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  Future<void> updateDay({
    required String userId,
    required String date,
    required String? workoutTypeId,
    required int? durationMinutes,
  }) async {
    await guardedAction(() async {
      try {
        final existing = await _attendanceService.getDay(
          userId: userId,
          date: date,
        );
        final timestamp = existing?.timestamp ?? DateTime.now();
        final day = AttendanceDay(
          date: date,
          timestamp: timestamp,
          trainingTypeId: workoutTypeId,
          durationMinutes: durationMinutes,
          notes: existing?.notes,
        );
        await _attendanceService.upsertDay(userId: userId, model: day);
        safeEmit(CalendarDayMarkedState(day: day));
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  Future<void> markAttended({
    required String userId,
    required String date,
    String? workoutTypeId,
    int? durationMinutes,
  }) {
    final now = DateTime.now();
    final day = AttendanceDay(
      date: date,
      timestamp: now,
      trainingTypeId: workoutTypeId,
      durationMinutes: durationMinutes,
    );
    return markDay(userId: userId, day: day);
  }

  Future<void> refreshActiveMonth(String userId) async {
    final year = _activeMonthYear;
    final month = _activeMonth;
    if (year == 0 || month == 0) {
      return;
    }
    loadMonth(userId: userId, year: year, month: month);
  }

  int get activeYear => _activeMonthYear;
  int get activeMonth => _activeMonth;

  @override
  Future<void> close() async {
    for (final sub in _monthAttendanceSubscriptions) {
      await sub.cancel();
    }
    for (final sub in _monthHealthSubscriptions) {
      await sub.cancel();
    }
    await _productsSubscription?.cancel();
    await _typesSubscription?.cancel();
    return super.close();
  }

  /// Creates or updates the attendance record for [day.date].
  Future<void> markDay({
    required String userId,
    required AttendanceDay day,
  }) async {
    await guardedAction(() async {
      try {
        await _attendanceService.upsertDay(userId: userId, model: day);
        safeEmit(CalendarDayMarkedState(day: day));
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }

  /// Deletes the attendance record for [date] ("YYYY-MM-DD").
  Future<void> clearDay({required String userId, required String date}) async {
    await guardedAction(() async {
      try {
        await _attendanceService.deleteDay(userId: userId, date: date);
        safeEmit(CalendarDayClearedState(date: date));
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }
}
