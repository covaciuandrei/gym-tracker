import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/attendance/attendance_day_source.dart';
import 'package:gym_tracker/model/attendance_day.dart';

part 'attendance_service_exceptions.dart';

@injectable
class AttendanceService {
  const AttendanceService(this._source);

  final AttendanceDaySource _source;

  /// Returns the "YYYY-MM" key for a given [year] and [month].
  static String yearMonthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  /// Streams all [AttendanceDay] records for [userId] in the given month.
  Stream<List<AttendanceDay>> watchMonth({
    required String userId,
    required int year,
    required int month,
  }) =>
      _source.watchMonth(userId, yearMonthKey(year, month));

  /// Returns the [AttendanceDay] for [date] ("YYYY-MM-DD"), or null.
  Future<AttendanceDay?> getDay({
    required String userId,
    required String date,
  }) {
    final yearMonth = date.substring(0, 7); // "YYYY-MM"
    return _source.getDay(userId, yearMonth, date);
  }

  /// Creates or overwrites the attendance record for [model.date].
  Future<void> upsertDay({
    required String userId,
    required AttendanceDay model,
  }) {
    final yearMonth = model.date.substring(0, 7);
    return _source.upsertDay(userId, yearMonth, model);
  }

  /// Removes the attendance record for [date] ("YYYY-MM-DD").
  Future<void> deleteDay({
    required String userId,
    required String date,
  }) {
    final yearMonth = date.substring(0, 7);
    return _source.deleteDay(userId, yearMonth, date);
  }
}
