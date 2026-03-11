import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.uid,
    required this.email,
    required this.emailVerified,
    this.displayName,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;

  @override
  List<Object?> get props => [uid, email, displayName, emailVerified];
}
