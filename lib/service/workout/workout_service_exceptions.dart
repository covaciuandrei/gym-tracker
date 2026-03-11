part of 'workout_service.dart';

/// Thrown when a training type update targets a document that no longer exists.
class TrainingTypeNotFoundException implements Exception {
  const TrainingTypeNotFoundException();
}
