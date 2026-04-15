import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/mappers/training_type_mapper.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'training_type_dto.dart';

@injectable
class TrainingTypeSource {
  const TrainingTypeSource(this._db, this._mapper);

  final FirebaseFirestore _db;
  final TrainingTypeMapper _mapper;

  CollectionReference<TrainingTypeDto> _typesRef(String userId) => _db
      .collection('users')
      .doc(userId)
      .collection('trainingTypes')
      .withConverter<TrainingTypeDto>(
        fromFirestore: (snap, _) {
          final dto = TrainingTypeDto.fromJson(snap.data()!);
          // Populate id from document id — it is excluded from Firestore fields.
          return TrainingTypeDto(
            id: snap.id,
            name: dto.name,
            color: dto.color,
            icon: dto.icon,
            createdAt: dto.createdAt,
          );
        },
        toFirestore: (dto, _) => dto.toJson(),
      );

  /// Streams all training types for [userId], ordered by name.
  Stream<List<TrainingType>> watchAll(String userId) => _typesRef(userId)
      .orderBy('name')
      .snapshots()
      .map((snap) => snap.docs.map((d) => _mapper.mapDto(d.data())).toList());

  /// Returns a single training type by [typeId].
  Future<TrainingType?> getById(String userId, String typeId) async {
    final snap = await _typesRef(userId).doc(typeId).get();
    if (!snap.exists) return null;
    return _mapper.mapDto(snap.data()!);
  }

  /// Creates a new training type and returns its generated document id.
  Future<String> create(String userId, TrainingType model) async {
    final dto = _mapper.mapModel(model, createdAt: Timestamp.now());
    final ref = await _typesRef(userId).add(dto);
    return ref.id;
  }

  /// Overwrites the training type document identified by [model.id].
  Future<void> update(String userId, TrainingType model) =>
      _typesRef(userId).doc(model.id).set(_mapper.mapModel(model));

  /// Deletes the training type document identified by [typeId].
  Future<void> delete(String userId, String typeId) =>
      _typesRef(userId).doc(typeId).delete();
}
