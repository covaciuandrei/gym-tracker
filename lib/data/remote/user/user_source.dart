import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/mappers/user_mapper.dart';
import 'package:gym_tracker/model/user.dart';
import 'user_dto.dart';

@injectable
class UserSource {
  const UserSource(this._db, this._mapper);

  final FirebaseFirestore _db;
  final UserMapper _mapper;

  DocumentReference<UserDto> _userDocRef({required String userId}) => _db
      .collection('users')
      .doc(userId)
      .withConverter<UserDto>(
        fromFirestore: (snap, _) {
          final dto = UserDto.fromJson(snap.data()!);
          return UserDto(
            id: snap.id,
            email: dto.email,
            displayName: dto.displayName,
            lastVerificationEmailSentAt: dto.lastVerificationEmailSentAt,
            theme: dto.theme,
            language: dto.language,
            lastLoginAt: dto.lastLoginAt,
            createdAt: dto.createdAt,
            totalAttendances: dto.totalAttendances,
          );
        },
        toFirestore: (dto, _) => dto.toJson(),
      );

  /// Returns the user profile for [userId], or null if it does not exist.
  Future<User?> getById({required String userId}) async {
    final snap = await _userDocRef(userId: userId).get();
    if (!snap.exists) return null;
    return _mapper.mapDto(snap.data()!);
  }

  /// Creates a new user profile document on sign-up.
  ///
  /// [consent] is a free-form map describing the user's acceptance of the
  /// legal documents (terms / privacy / age confirmation) at sign-up time.
  /// Written verbatim under `users/{uid}.consent` so we can prove which
  /// text was accepted and when (GDPR Art. 7(1)).
  ///
  /// Uses `SetOptions(merge: true)` — safe for concurrent updates,
  /// preserves subcollections and existing fields.
  Future<void> create({
    required String userId,
    required String email,
    required String displayName,
    required Map<String, Object?> consent,
  }) => _db.collection('users').doc(userId).set({
    'email': email,
    'displayName': displayName,
    'theme': 'dark',
    'language': 'en',
    'createdAt': FieldValue.serverTimestamp(),
    'lastLoginAt': FieldValue.serverTimestamp(),
    'lastVerificationEmailSentAt': Timestamp.now(),
    'consent': {...consent, 'acceptedAt': FieldValue.serverTimestamp()},
  }, SetOptions(merge: true));

  /// Records a returning login timestamp and clears the verification email cooldown.
  ///
  /// Uses `SetOptions(merge: true)` — does not touch any other fields.
  Future<void> recordLogin({required String userId}) => _db.collection('users').doc(userId).set({
    'lastLoginAt': FieldValue.serverTimestamp(),
    'lastVerificationEmailSentAt': FieldValue.delete(),
  }, SetOptions(merge: true));
}
