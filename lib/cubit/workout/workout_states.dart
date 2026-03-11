part of 'workout_cubit.dart';

class WorkoutTypesLoadedState extends BaseState {
  const WorkoutTypesLoadedState({required this.types});

  final List<TrainingType> types;

  @override
  List<Object?> get props => [types];
}

class WorkoutTypeCreatedState extends BaseState {
  const WorkoutTypeCreatedState({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class WorkoutTypeDeletedState extends BaseState {
  const WorkoutTypeDeletedState();
}
