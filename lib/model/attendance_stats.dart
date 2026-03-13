import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class NutrientTotal extends Equatable {
  const NutrientTotal({
    required this.name,
    required this.amount,
    required this.unit,
  });

  final String name;
  final double amount;
  final String unit;

  @override
  List<Object?> get props => [name, amount, unit];
}

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
    required this.weekdayAttendanceCounts,
    required this.monthlyAttendanceCounts,
    required this.typeDistribution,
    required this.monthlyTypeDistribution,
    required this.monthlyDurationAverages,
    required this.monthlyTypeDurationAverages,
    required this.perTypeDurationAverages,
    required this.yearlyAverageDurationMinutes,
    required this.yearlyUntrackedDurationCount,
    required this.monthlyUntrackedDurationCounts,
    required this.healthTotalLogs,
    required this.healthConsistencyPct,
    required this.monthlyHealthServings,
    required this.mostTakenSupplementName,
    required this.mostTakenSupplementBrand,
    required this.mostTakenSupplementCount,
    required this.monthlySupplementServings,
    required this.productNames,
    required this.productBrands,
    required this.topNutrients,
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

  /// Monday-first weekday counts for the selected year. Index 0 = Monday,
  /// index 6 = Sunday.
  final List<int> weekdayAttendanceCounts;

  /// Attendance count per month. Index 0 = January, index 11 = December.
  final List<int> monthlyAttendanceCounts;

  /// Training-type id → attendance count.
  /// Only entries with a non-null [AttendanceDay.trainingTypeId] are included.
  final Map<String, int> typeDistribution;

  /// Month (1..12) → (training-type id → attendance count)
  final Map<int, Map<String, int>> monthlyTypeDistribution;

  /// Month (1–12) → average [AttendanceDay.durationMinutes] for attended days
  /// where duration was tracked.
  final Map<int, double> monthlyDurationAverages;

  /// Month (1..12) → (training-type id → average duration in minutes)
  final Map<int, Map<String, double>> monthlyTypeDurationAverages;

  /// Training-type id → average [AttendanceDay.durationMinutes] for attended
  /// days with that type and a tracked duration.
  final Map<String, double> perTypeDurationAverages;

  /// Average duration in minutes across all attended days in the selected year
  /// that have a tracked duration.
  final double yearlyAverageDurationMinutes;

  /// Number of attended days where duration was not tracked.
  final int yearlyUntrackedDurationCount;

  /// Untracked duration counts per month. Index 0 = January, 11 = December.
  final List<int> monthlyUntrackedDurationCounts;

  /// Total number of supplement log entries in the selected year.
  final int healthTotalLogs;

  /// Percentage of elapsed days in the selected year that had at least one
  /// supplement log.
  final double healthConsistencyPct;

  /// Total servings logged per month. Index 0 = January, 11 = December.
  final List<double> monthlyHealthServings;

  final String? mostTakenSupplementName;
  final String? mostTakenSupplementBrand;
  final double mostTakenSupplementCount;

  /// Month (1..12) → (product id → servings count)
  final Map<int, Map<String, double>> monthlySupplementServings;

  /// Product id → product name.
  final Map<String, String> productNames;

  /// Product id → product brand.
  final Map<String, String> productBrands;

  final List<NutrientTotal> topNutrients;

  @override
  List<Object?> get props => [
    totalCount,
    yearlyCount,
    monthlyCount,
    currentWeekStreak,
    bestWeekStreak,
    favoriteDaysOfWeek,
    weekdayAttendanceCounts,
    monthlyAttendanceCounts,
    typeDistribution,
    monthlyTypeDistribution,
    monthlyDurationAverages,
    monthlyTypeDurationAverages,
    perTypeDurationAverages,
    yearlyAverageDurationMinutes,
    yearlyUntrackedDurationCount,
    monthlyUntrackedDurationCounts,
    healthTotalLogs,
    healthConsistencyPct,
    monthlyHealthServings,
    mostTakenSupplementName,
    mostTakenSupplementBrand,
    mostTakenSupplementCount,
    monthlySupplementServings,
    productNames,
    productBrands,
    topNutrients,
  ];
}
