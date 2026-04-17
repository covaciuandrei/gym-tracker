import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_tracker/data/mappers/app_config_mapper.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:injectable/injectable.dart';

import 'app_config_dto.dart';

@injectable
class AppConfigSource {
  const AppConfigSource(this._db, this._mapper);

  final FirebaseFirestore _db;
  final AppConfigMapper _mapper;

  DocumentReference<AppConfigDto> _docRef() => _db
      .collection('appConfig')
      .doc('version')
      .withConverter<AppConfigDto>(
        fromFirestore: (snap, _) => AppConfigDto.fromJson(snap.data()!),
        toFirestore: (dto, _) => dto.toJson(),
      );

  /// Fetches the single `appConfig/version` document from Firestore.
  /// Returns `null` if the document does not exist.
  /// Throws on network / permission errors (caller handles).
  Future<AppConfig?> get() async {
    final snap = await _docRef().get();
    final data = snap.data();
    if (!snap.exists || data == null) return null;
    return _mapper.mapDto(data);
  }
}
