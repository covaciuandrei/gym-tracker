import 'package:equatable/equatable.dart';

/// A single gym attendance record for a specific day.
///
/// Stored in Firestore at:
///   users/{userId}/attendances/{yearMonth}/days/{date}
/// where yearMonth = "YYYY-MM" and date = "YYYY-MM-DD".
class AttendanceDay extends Equatable {
  const AttendanceDay({
    required this.date,
    required this.timestamp,
    this.trainingTypeId,
    this.durationMinutes,
    this.notes,
  });

  /// Date string in format "YYYY-MM-DD".
  final String date;

  final DateTime timestamp;

  /// References a [TrainingType] id, or null if no type was selected.
  final String? trainingTypeId;

  /// Workout duration in minutes, or null if not tracked.
  final int? durationMinutes;

  final String? notes;

  @override
  List<Object?> get props => [
        date,
        timestamp,
        trainingTypeId,
        durationMinutes,
        notes,
      ];
}
