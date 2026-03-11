part of 'stats_cubit.dart';

class StatsLoadedState extends BaseState {
  const StatsLoadedState({
    required this.stats,
    required this.year,
    required this.types,
  });

  final AttendanceStats stats;
  final int year;
  final List<TrainingType> types;

  @override
  List<Object?> get props => [stats, year, types];
}
