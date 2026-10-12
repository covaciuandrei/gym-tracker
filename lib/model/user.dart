import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/body_type.dart';
import 'package:gym_tracker/model/sex.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.theme,
    required this.language,
    required this.currency,
    required this.lastLoginAt,
    required this.createdAt,
    required this.totalAttendances,
    this.lastVerificationEmailSentAt,
    this.consent,
    this.sex,
    this.birthDate,
    this.heightCm,
    this.weightKg,
    this.bodyType,
  });

  final String id;
  final String email;
  final String displayName;
  final DateTime? lastVerificationEmailSentAt;
  final String theme;
  final String language;
  final String currency;
  final DateTime lastLoginAt;
  final DateTime createdAt;
  final int totalAttendances;

  /// GDPR consent record stored at sign-up.
  ///
  /// Contains `termsVersion`, `privacyVersion`, `termsUrl`, `privacyUrl`,
  /// `acceptedAt`, and optionally `ipCountry`. Written via [UserSource.create]
  /// and preserved by [UserSource.recordLogin] (merge: true).
  final Map<String, Object?>? consent;

  /// Optional self-reported personal details, captured at registration.
  ///
  /// All five fields are independently optional (the personal-details step
  /// is skippable) and are used only to seed the Health Insights feature
  /// (population-benchmark lookups + a body-composition starting point)
  /// before any Apple Health data is available. Never required to use the
  /// app.
  final Sex? sex;
  final DateTime? birthDate;
  final double? heightCm;
  final double? weightKg;
  final BodyType? bodyType;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    lastVerificationEmailSentAt,
    theme,
    language,
    currency,
    lastLoginAt,
    createdAt,
    totalAttendances,
    consent,
    sex,
    birthDate,
    heightCm,
    weightKg,
    bodyType,
  ];
}
