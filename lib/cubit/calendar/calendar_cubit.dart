import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';

part 'calendar_states.dart';

@injectable
class CalendarCubit extends BaseCubit {
  CalendarCubit(this._attendanceService);

  final AttendanceService _attendanceService;

  StreamSubscription<List<AttendanceDay>>? _monthSubscription;

  /// Subscribes to attendance data for the given [year]/[month] and emits
  /// [CalendarMonthLoadedState] on every update. Cancels any previous
  /// subscription when called again (e.g. when the user pages to a new month).
  void loadMonth({
    required String userId,
    required int year,
    required int month,
  }) {
    _monthSubscription?.cancel();
    safeEmit(const PendingState());
    _monthSubscription = _attendanceService
        .watchMonth(userId: userId, year: year, month: month)
        .listen(
          (days) => safeEmit(
            CalendarMonthLoadedState(days: days, year: year, month: month),
          ),
          onError: (_) => safeEmit(const SomethingWentWrongState()),
        );
  }

  /// Creates or updates the attendance record for [day.date].
  Future<void> markDay({
    required String userId,
    required AttendanceDay day,
  }) async {
    safeEmit(const PendingState());
    try {
      await _attendanceService.upsertDay(userId: userId, model: day);
      safeEmit(CalendarDayMarkedState(day: day));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Deletes the attendance record for [date] ("YYYY-MM-DD").
  Future<void> clearDay({
    required String userId,
    required String date,
  }) async {
    safeEmit(const PendingState());
    try {
      await _attendanceService.deleteDay(userId: userId, date: date);
      safeEmit(CalendarDayClearedState(date: date));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  @override
  Future<void> close() async {
    await _monthSubscription?.cancel();
    return super.close();
  }
}
