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
  ];
}
