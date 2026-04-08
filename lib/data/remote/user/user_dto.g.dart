// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserDto _$UserDtoFromJson(Map<String, dynamic> json) => UserDto(
  email: json['email'] as String? ?? '',
  displayName: json['displayName'] as String? ?? '',
  theme: json['theme'] as String? ?? 'dark',
  language: json['language'] as String? ?? 'en',
  lastLoginAt: json['lastLoginAt'],
  createdAt: json['createdAt'],
  totalAttendances: (json['totalAttendances'] as num?)?.toInt() ?? 0,
  lastVerificationEmailSentAt: json['lastVerificationEmailSentAt'],
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'email': instance.email,
  'displayName': instance.displayName,
  'lastVerificationEmailSentAt': instance.lastVerificationEmailSentAt,
  'theme': instance.theme,
  'language': instance.language,
  'lastLoginAt': instance.lastLoginAt,
  'createdAt': instance.createdAt,
  'totalAttendances': instance.totalAttendances,
};
