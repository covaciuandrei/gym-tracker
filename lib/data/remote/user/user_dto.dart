import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  UserDto({
    required this.email,
    required this.displayName,
    required this.theme,
    required this.language,
    required this.lastLoginAt,
    required this.createdAt,
    required this.totalAttendances,
    this.id = '',
    this.lastVerificationEmailSentAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UserDtoToJson(this);

  /// Document id — excluded from Firestore fields (comes from doc.id).
  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: '')
  final String id;

  @JsonKey(name: 'email', defaultValue: '')
  final String email;

  @JsonKey(name: 'displayName', defaultValue: '')
  final String displayName;

  @JsonKey(name: 'lastVerificationEmailSentAt')
  final Object? lastVerificationEmailSentAt;

  @JsonKey(name: 'theme', defaultValue: 'dark')
  final String theme;

  @JsonKey(name: 'language', defaultValue: 'en')
  final String language;

  @JsonKey(name: 'lastLoginAt')
  final Object? lastLoginAt;

  @JsonKey(name: 'createdAt')
  final Object? createdAt;

  @JsonKey(name: 'totalAttendances', defaultValue: 0)
  final int totalAttendances;
}
