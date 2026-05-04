import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.theme,
    required this.language,
    required this.lastLoginAt,
    required this.createdAt,
    required this.totalAttendances,
    this.lastVerificationEmailSentAt,
    this.consent,
  });

  final String id;
  final String email;
  final String displayName;
  final DateTime? lastVerificationEmailSentAt;
  final String theme;
  final String language;
  final DateTime lastLoginAt;
  final DateTime createdAt;
  final int totalAttendances;

  /// GDPR consent record stored at sign-up.
  ///
  /// Contains `termsVersion`, `privacyVersion`, `termsUrl`, `privacyUrl`,
  /// `acceptedAt`, and optionally `ipCountry`. Written via [UserSource.create]
  /// and preserved by [UserSource.recordLogin] (merge: true).
  final Map<String, Object?>? consent;

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    lastVerificationEmailSentAt,
    theme,
    language,
    lastLoginAt,
    createdAt,
    totalAttendances,
    consent,
  ];
}
