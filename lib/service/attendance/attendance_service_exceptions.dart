part of 'attendance_service.dart';

/// Thrown when an expected attendance record is not found in Firestore.
class AttendanceDayNotFoundException implements Exception {
  const AttendanceDayNotFoundException();
}
