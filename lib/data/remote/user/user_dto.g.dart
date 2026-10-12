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
  currency: json['currency'] as String? ?? 'EUR',
  lastLoginAt: json['lastLoginAt'],
  createdAt: json['createdAt'],
  totalAttendances: (json['totalAttendances'] as num?)?.toInt() ?? 0,
  lastVerificationEmailSentAt: json['lastVerificationEmailSentAt'],
  consent: json['consent'] as Map<String, dynamic>?,
  sex: json['sex'] as String?,
  birthDate: json['birthDate'] as String?,
  heightCm: (json['heightCm'] as num?)?.toDouble(),
  weightKg: (json['weightKg'] as num?)?.toDouble(),
  bodyType: json['bodyType'] as String?,
);

Map<String, dynamic> _$UserDtoToJson(UserDto instance) => <String, dynamic>{
  'email': instance.email,
  'displayName': instance.displayName,
  'lastVerificationEmailSentAt': instance.lastVerificationEmailSentAt,
  'theme': instance.theme,
  'language': instance.language,
  'currency': instance.currency,
  'lastLoginAt': instance.lastLoginAt,
  'createdAt': instance.createdAt,
  'totalAttendances': instance.totalAttendances,
  'consent': instance.consent,
  'sex': instance.sex,
  'birthDate': instance.birthDate,
  'heightCm': instance.heightCm,
  'weightKg': instance.weightKg,
  'bodyType': instance.bodyType,
};
