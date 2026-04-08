import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/user/user_dto.dart';
import 'package:gym_tracker/model/user.dart';

@injectable
class UserMapper {
  /// Maps a [UserDto] (from Firestore) to a domain [User].
  User mapDto(UserDto dto) => User(
    id: dto.id,
    email: dto.email,
    displayName: dto.displayName,
    lastVerificationEmailSentAt: _toNullableDateTime(
      dto.lastVerificationEmailSentAt,
    ),
    theme: dto.theme,
    language: dto.language,
    lastLoginAt: _toDateTime(dto.lastLoginAt),
    createdAt: _toDateTime(dto.createdAt),
    totalAttendances: dto.totalAttendances,
  );

  DateTime _toDateTime(Object? raw) =>
      _toNullableDateTime(raw) ?? DateTime.now();

  DateTime? _toNullableDateTime(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is Map) {
      final seconds = raw['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
      }
    }
    return null;
  }
}
