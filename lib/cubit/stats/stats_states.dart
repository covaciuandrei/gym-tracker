part of 'stats_cubit.dart';

enum StatsLoadStatus { idle, loading, loaded, error }

enum StatsTabKind { attendances, workouts, duration, health }

class StatsLoadedState extends BaseState {
  const StatsLoadedState({
    required this.year,
    required this.attendancesStatus,
    required this.workoutsStatus,
    required this.durationStatus,
    required this.healthStatus,
    this.attendancesStats,
    this.workoutsStats,
    this.durationStats,
    this.healthStats,
    this.types = const [],
  });

  factory StatsLoadedState.initial(int year) {
    return StatsLoadedState(
      year: year,
      attendancesStatus: StatsLoadStatus.idle,
      workoutsStatus: StatsLoadStatus.idle,
      durationStatus: StatsLoadStatus.idle,
      healthStatus: StatsLoadStatus.idle,
    );
  }

  final int year;
  final StatsLoadStatus attendancesStatus;
  final StatsLoadStatus workoutsStatus;
  final StatsLoadStatus durationStatus;
  final StatsLoadStatus healthStatus;
  final AttendanceStats? attendancesStats;
  final AttendanceStats? workoutsStats;
  final AttendanceStats? durationStats;
  final AttendanceStats? healthStats;
  final List<TrainingType> types;

  StatsLoadedState copyWith({
    int? year,
    StatsLoadStatus? attendancesStatus,
    StatsLoadStatus? workoutsStatus,
    StatsLoadStatus? durationStatus,
    StatsLoadStatus? healthStatus,
    AttendanceStats? attendancesStats,
    AttendanceStats? workoutsStats,
    AttendanceStats? durationStats,
    AttendanceStats? healthStats,
    List<TrainingType>? types,
    bool clearAttendancesStats = false,
    bool clearWorkoutsStats = false,
    bool clearDurationStats = false,
    bool clearHealthStats = false,
  }) {
    return StatsLoadedState(
      year: year ?? this.year,
      attendancesStatus: attendancesStatus ?? this.attendancesStatus,
      workoutsStatus: workoutsStatus ?? this.workoutsStatus,
      durationStatus: durationStatus ?? this.durationStatus,
      healthStatus: healthStatus ?? this.healthStatus,
      attendancesStats: clearAttendancesStats ? null : (attendancesStats ?? this.attendancesStats),
      workoutsStats: clearWorkoutsStats ? null : (workoutsStats ?? this.workoutsStats),
      durationStats: clearDurationStats ? null : (durationStats ?? this.durationStats),
      healthStats: clearHealthStats ? null : (healthStats ?? this.healthStats),
      types: types ?? this.types,
    );
  }

  @override
  List<Object?> get props => [
    year,
    attendancesStatus,
    workoutsStatus,
    durationStatus,
    healthStatus,
    attendancesStats,
    workoutsStats,
    durationStats,
    healthStats,
    types,
  ];
}
