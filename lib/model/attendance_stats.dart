import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Aggregated attendance statistics computed from one calendar year of data.
@immutable
class AttendanceStats extends Equatable {
  const AttendanceStats({
    required this.totalCount,
    required this.yearlyCount,
    required this.monthlyCount,
    required this.currentWeekStreak,
    required this.bestWeekStreak,
    required this.favoriteDaysOfWeek,
    required this.typeDistribution,
    required this.monthlyDurationAverages,
    required this.perTypeDurationAverages,
  });

  /// Total number of attendance records in the year.
  final int totalCount;

  /// Attendance count for the full selected year.
  final int yearlyCount;

  /// Attendance count for the current calendar month within the selected year.
  final int monthlyCount;

  /// Number of consecutive ISO weeks (Mon–Sun) with ≥ 1 attendance,
  /// ending at the current or previous ISO week.
  final int currentWeekStreak;

  /// Longest run of consecutive ISO weeks with ≥ 1 attendance.
  final int bestWeekStreak;

  /// [DateTime.weekday] values (1 = Mon … 7 = Sun) that share the highest
  /// attendance count. Empty when there is no data.
  final List<int> favoriteDaysOfWeek;

  /// Training-type id → attendance count.
  /// Only entries with a non-null [AttendanceDay.trainingTypeId] are included.
  final Map<String, int> typeDistribution;

  /// Month (1–12) → average [AttendanceDay.durationMinutes] for attended days
  /// where duration was tracked.
  final Map<int, double> monthlyDurationAverages;

  /// Training-type id → average [AttendanceDay.durationMinutes] for attended
  /// days with that type and a tracked duration.
  final Map<String, double> perTypeDurationAverages;

  @override
  List<Object?> get props => [
        totalCount,
        yearlyCount,
        monthlyCount,
        currentWeekStreak,
        bestWeekStreak,
        favoriteDaysOfWeek,
        typeDistribution,
        monthlyDurationAverages,
        perTypeDurationAverages,
      ];
}
