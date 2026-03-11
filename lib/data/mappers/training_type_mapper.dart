import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/training_type/training_type_dto.dart';
import 'package:gym_tracker/model/training_type.dart';

@injectable
class TrainingTypeMapper {
  /// Maps a [TrainingTypeDto] (from Firestore) to a domain [TrainingType].
  TrainingType mapDto(TrainingTypeDto dto) => TrainingType(
        id: dto.id,
        name: dto.name,
        color: dto.color,
        icon: dto.icon,
      );

  /// Maps a domain [TrainingType] to a [TrainingTypeDto] for Firestore writes.
  /// [createdAt] is supplied by the source at write time.
  TrainingTypeDto mapModel(
    TrainingType model, {
    Timestamp? createdAt,
  }) =>
      TrainingTypeDto(
        id: model.id,
        name: model.name,
        color: model.color,
        icon: model.icon,
        createdAt: createdAt,
      );
}
