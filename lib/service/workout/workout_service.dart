import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/training_type/training_type_source.dart';
import 'package:gym_tracker/model/training_type.dart';

part 'workout_service_exceptions.dart';

@injectable
class WorkoutService {
  const WorkoutService(this._source);

  final TrainingTypeSource _source;

  /// Streams all [TrainingType] documents for [userId], ordered by name.
  Stream<List<TrainingType>> watchAll(String userId) =>
      _source.watchAll(userId);

  /// Returns a single [TrainingType] by [typeId], or null if it does not exist.
  Future<TrainingType?> getById(String userId, String typeId) =>
      _source.getById(userId, typeId);

  /// Creates a new [TrainingType]. Returns the Firestore document id.
  Future<String> create(String userId, TrainingType model) =>
      _source.create(userId, model);

  /// Updates the [TrainingType] identified by [model.id].
  /// Throws [TrainingTypeNotFoundException] if it no longer exists.
  Future<void> update(String userId, TrainingType model) async {
    final existing = await _source.getById(userId, model.id);
    if (existing == null) throw const TrainingTypeNotFoundException();
    return _source.update(userId, model);
  }

  /// Deletes the [TrainingType] identified by [typeId].
  Future<void> delete(String userId, String typeId) =>
      _source.delete(userId, typeId);
}
