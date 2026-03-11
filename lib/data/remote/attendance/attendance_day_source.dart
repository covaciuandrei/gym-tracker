import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/mappers/attendance_day_mapper.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'attendance_day_dto.dart';

@injectable
class AttendanceDaySource {
  const AttendanceDaySource(this._mapper);

  final AttendanceDayMapper _mapper;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Path:  users/{userId}/attendances/{yearMonth}/days
  ///   yearMonth = "YYYY-MM"  (e.g. "2025-03")
  CollectionReference<AttendanceDayDto> _daysRef(
    String userId,
    String yearMonth,
  ) =>
      _db
          .collection('users')
          .doc(userId)
          .collection('attendances')
          .doc(yearMonth)
          .collection('days')
          .withConverter<AttendanceDayDto>(
            fromFirestore: (snap, _) =>
                AttendanceDayDto.fromJson(snap.data()!),
            toFirestore: (dto, _) => dto.toJson(),
          );

  /// Streams all attendance days for a given [userId] and [yearMonth].
  Stream<List<AttendanceDay>> watchMonth(
    String userId,
    String yearMonth,
  ) =>
      _daysRef(userId, yearMonth)
          .orderBy('date')
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => _mapper.mapDto(d.data())).toList());

  /// Returns the attendance record for [date] ("YYYY-MM-DD"), or null.
  Future<AttendanceDay?> getDay(
    String userId,
    String yearMonth,
    String date,
  ) async {
    final snap = await _daysRef(userId, yearMonth).doc(date).get();
    if (!snap.exists) return null;
    return _mapper.mapDto(snap.data()!);
  }

  /// Writes (creates or overwrites) the attendance record for [model.date].
  /// The document id IS the date string ("YYYY-MM-DD").
  Future<void> upsertDay(
    String userId,
    String yearMonth,
    AttendanceDay model,
  ) =>
      _daysRef(userId, yearMonth)
          .doc(model.date)
          .set(_mapper.mapModel(model));

  /// Removes the attendance record for [date] from a given [yearMonth].
  Future<void> deleteDay(
    String userId,
    String yearMonth,
    String date,
  ) =>
      _daysRef(userId, yearMonth).doc(date).delete();
}
