part of 'stats_cubit.dart';

/// Stats tab kinds. Used by `loadTab()` to select which slice to fetch.
enum StatsTabKind { attendances, workouts, duration, health }

/// Emitted once when the active year changes, before any slice begins loading.
/// Tab builders use this to reset to a loading skeleton when the year flips.
class StatsYearInitializedState extends BaseState {
  const StatsYearInitializedState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

// ───────────────────────────────────────────────────────────────────────────
// Attendances slice
// ───────────────────────────────────────────────────────────────────────────

class StatsAttendancesLoadingState extends BaseState {
  const StatsAttendancesLoadingState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

class StatsAttendancesLoadedState extends BaseState {
  const StatsAttendancesLoadedState({required this.year, required this.stats});

  final int year;
  final AttendanceStats stats;

  @override
  List<Object?> get props => [year, stats];
}

class StatsAttendancesErrorState extends BaseState {
  const StatsAttendancesErrorState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

// ───────────────────────────────────────────────────────────────────────────
// Workouts slice
// ───────────────────────────────────────────────────────────────────────────

class StatsWorkoutsLoadingState extends BaseState {
  const StatsWorkoutsLoadingState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

class StatsWorkoutsLoadedState extends BaseState {
  const StatsWorkoutsLoadedState({required this.year, required this.stats, required this.types});

  final int year;
  final AttendanceStats stats;
  final List<TrainingType> types;

  @override
  List<Object?> get props => [year, stats, types];
}

class StatsWorkoutsErrorState extends BaseState {
  const StatsWorkoutsErrorState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

// ───────────────────────────────────────────────────────────────────────────
// Duration slice
// ───────────────────────────────────────────────────────────────────────────

class StatsDurationLoadingState extends BaseState {
  const StatsDurationLoadingState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

class StatsDurationLoadedState extends BaseState {
  const StatsDurationLoadedState({required this.year, required this.stats, required this.types});

  final int year;
  final AttendanceStats stats;
  final List<TrainingType> types;

  @override
  List<Object?> get props => [year, stats, types];
}

class StatsDurationErrorState extends BaseState {
  const StatsDurationErrorState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

// ───────────────────────────────────────────────────────────────────────────
// Health slice
// ───────────────────────────────────────────────────────────────────────────

class StatsHealthLoadingState extends BaseState {
  const StatsHealthLoadingState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}

class StatsHealthLoadedState extends BaseState {
  const StatsHealthLoadedState({required this.year, required this.stats});

  final int year;
  final AttendanceStats stats;

  @override
  List<Object?> get props => [year, stats];
}

class StatsHealthErrorState extends BaseState {
  const StatsHealthErrorState({required this.year});

  final int year;

  @override
  List<Object?> get props => [year];
}
