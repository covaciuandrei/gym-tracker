import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/mappers/attendance_day_mapper.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'attendance_day_dto.dart';

@injectable
class AttendanceDaySource {
  const AttendanceDaySource(this._db, this._mapper);

  final FirebaseFirestore _db;
  final AttendanceDayMapper _mapper;

  /// Path:  users/{userId}/attendances/{yearMonth}/days
  ///   yearMonth = "YYYY-MM"  (e.g. "2025-03")
  CollectionReference<AttendanceDayDto> _daysRef(
    String userId,
    String yearMonth,
  ) => _db
      .collection('users')
      .doc(userId)
      .collection('attendances')
      .doc(yearMonth)
      .collection('days')
      .withConverter<AttendanceDayDto>(
        fromFirestore: (snap, _) {
          final raw = snap.data() ?? const <String, dynamic>{};
          final durationRaw = raw['duration_minutes'] ?? raw['durationMinutes'];
          return AttendanceDayDto(
            date: (raw['date'] ?? '') as String,
            timestamp: raw['timestamp'] ?? Timestamp.now(),
            trainingTypeId:
                (raw['training_type_id'] ?? raw['trainingTypeId']) as String?,
            durationMinutes: durationRaw is num ? durationRaw.toInt() : null,
            notes: raw['notes'] as String?,
          );
        },
        toFirestore: (dto, _) => dto.toJson(),
      );

  /// Streams all attendance days for a given [userId] and [yearMonth].
  Stream<List<AttendanceDay>> watchMonth(String userId, String yearMonth) =>
      _daysRef(userId, yearMonth)
          .orderBy('date')
          .snapshots()
          .map(
            (snap) => snap.docs.map((d) => _mapper.mapDto(d.data())).toList(),
          );

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
  ///
  /// Also touches the month document so it exists as a real Firestore document
  /// and can be enumerated during account cleanup.
  Future<void> upsertDay(
    String userId,
    String yearMonth,
    AttendanceDay model,
  ) async {
    final monthRef = _db
        .collection('users')
        .doc(userId)
        .collection('attendances')
        .doc(yearMonth);
    final batch = _db.batch();
    batch.set(monthRef, <String, dynamic>{}, SetOptions(merge: true));
    batch.set(
      _daysRef(userId, yearMonth).doc(model.date),
      _mapper.mapModel(model),
    );
    await batch.commit();
  }

  /// Removes the attendance record for [date] from a given [yearMonth].
  Future<void> deleteDay(String userId, String yearMonth, String date) =>
      _daysRef(userId, yearMonth).doc(date).delete();
}
