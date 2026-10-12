import 'package:json_annotation/json_annotation.dart';

part 'user_dto.g.dart';

@JsonSerializable()
class UserDto {
  UserDto({
    required this.email,
    required this.displayName,
    required this.theme,
    required this.language,
    required this.currency,
    required this.lastLoginAt,
    required this.createdAt,
    required this.totalAttendances,
    this.id = '',
    this.lastVerificationEmailSentAt,
    this.consent,
    this.sex,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.bodyType,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);

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

  @JsonKey(name: 'currency', defaultValue: 'EUR')
  final String currency;

  @JsonKey(name: 'lastLoginAt')
  final Object? lastLoginAt;

  @JsonKey(name: 'createdAt')
  final Object? createdAt;

  @JsonKey(name: 'totalAttendances', defaultValue: 0)
  final int totalAttendances;

  /// GDPR consent map stored verbatim at sign-up.
  /// Typed as `Map<String, dynamic>?` to survive round-trip through
  /// json_serializable; production values contain [Timestamp] objects for
  /// `acceptedAt` which are preserved as-is in the DTO.
  @JsonKey(name: 'consent')
  final Map<String, dynamic>? consent;

  /// Optional self-reported personal details — see [UserDto] class doc on
  /// the domain-model side (`User.sex` etc.) for intent. `birthDate` is a
  /// canonical `YYYY-MM-DD` string per the app's date-format convention.
  @JsonKey(name: 'sex')
  final String? sex;

  @JsonKey(name: 'birthDate')
  final String? birthDate;

  @JsonKey(name: 'heightCm')
  final double? heightCm;

  @JsonKey(name: 'weightKg')
  final double? weightKg;

  @JsonKey(name: 'bodyType')
  final String? bodyType;
}
