import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/attendance/attendance_day_dto.dart';
import 'package:gym_tracker/model/attendance_day.dart';

@injectable
class AttendanceDayMapper {
  /// Maps an [AttendanceDayDto] (from Firestore) to a domain [AttendanceDay].
  AttendanceDay mapDto(AttendanceDayDto dto) => AttendanceDay(
    date: dto.date,
    timestamp: _toDateTime(dto.timestamp),
    trainingTypeId: dto.trainingTypeId,
    durationMinutes: dto.durationMinutes,
    notes: dto.notes,
  );

  /// Maps a domain [AttendanceDay] to an [AttendanceDayDto] for Firestore.
  AttendanceDayDto mapModel(AttendanceDay model) => AttendanceDayDto(
    date: model.date,
    timestamp: Timestamp.fromDate(model.timestamp),
    trainingTypeId: model.trainingTypeId,
    durationMinutes: model.durationMinutes,
    notes: model.notes,
  );

  DateTime _toDateTime(Object raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    if (raw is Map) {
      final seconds = raw['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
      }
    }
    return DateTime.now();
  }
}
