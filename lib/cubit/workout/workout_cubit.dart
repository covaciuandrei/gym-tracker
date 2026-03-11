import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';

part 'workout_states.dart';

@injectable
class WorkoutCubit extends BaseCubit {
  WorkoutCubit(this._workoutService);

  final WorkoutService _workoutService;

  StreamSubscription<List<TrainingType>>? _typesSubscription;

  /// Subscribes to the [WorkoutService] stream and emits
  /// [WorkoutTypesLoadedState] on every update.
  void loadTypes(String userId) {
    _typesSubscription?.cancel();
    safeEmit(const PendingState());
    _typesSubscription = _workoutService.watchAll(userId).listen(
      (types) => safeEmit(WorkoutTypesLoadedState(types: types)),
      onError: (_) => safeEmit(const SomethingWentWrongState()),
    );
  }

  /// Creates a new [TrainingType] and emits [WorkoutTypeCreatedState] with the
  /// generated document id.
  Future<void> createType(String userId, TrainingType type) async {
    safeEmit(const PendingState());
    try {
      final id = await _workoutService.create(userId, type);
      safeEmit(WorkoutTypeCreatedState(id: id));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Deletes the [TrainingType] identified by [typeId].
  Future<void> deleteType(String userId, String typeId) async {
    safeEmit(const PendingState());
    try {
      await _workoutService.delete(userId, typeId);
      safeEmit(const WorkoutTypeDeletedState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Updates an existing [TrainingType] identified by [type.id].
  Future<void> updateType(String userId, TrainingType type) async {
    safeEmit(const PendingState());
    try {
      await _workoutService.update(userId, type);
      safeEmit(const WorkoutTypeUpdatedState());
    } on TrainingTypeNotFoundException {
      safeEmit(const SomethingWentWrongState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  @override
  Future<void> close() async {
    await _typesSubscription?.cancel();
    return super.close();
  }
}
