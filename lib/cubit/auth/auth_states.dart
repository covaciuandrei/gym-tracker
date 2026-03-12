part of 'auth_cubit.dart';

/// Firebase confirmed a signed-in user.
class AuthAuthenticatedState extends BaseState {
  const AuthAuthenticatedState({required this.user});

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// Firebase confirmed no signed-in user (or the user signed out).
class AuthUnauthenticatedState extends BaseState {
  const AuthUnauthenticatedState();
}

/// Sign-in completed successfully.
class AuthSignInSuccessState extends BaseState {
  const AuthSignInSuccessState({required this.user});

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// Sign-up completed; the user must verify their email before signing in.
class AuthSignUpSuccessState extends BaseState {
  const AuthSignUpSuccessState();
}

/// Sign-out completed successfully.
class AuthSignOutSuccessState extends BaseState {
  const AuthSignOutSuccessState();
}

/// Sign-in was attempted but the email address has not been verified.
class AuthEmailNotVerifiedState extends BaseState {
  const AuthEmailNotVerifiedState();
}

/// Sign-up failed because the email is already associated with an account.
class AuthEmailAlreadyInUseState extends BaseState {
  const AuthEmailAlreadyInUseState();
}

/// Sign-up failed because the password does not meet strength requirements.
class AuthWeakPasswordState extends BaseState {
  const AuthWeakPasswordState();
}

/// Sign-in or password change failed due to wrong credentials.
class AuthInvalidCredentialsState extends BaseState {
  const AuthInvalidCredentialsState();
}

/// A password-reset email was sent successfully.
class AuthPasswordResetSentState extends BaseState {
  const AuthPasswordResetSentState();
}

/// The password-reset OOB code was verified; [email] is the account address
/// the link was sent to.
class AuthPasswordResetCodeVerifiedState extends BaseState {
  const AuthPasswordResetCodeVerifiedState({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// The authenticated user's password was changed successfully.
class AuthPasswordChangedState extends BaseState {
  const AuthPasswordChangedState();
}

/// The email-verification action code was applied successfully.
class AuthEmailVerifiedState extends BaseState {
  const AuthEmailVerifiedState();
}

/// An OOB action code (email verification or password reset) was expired or
/// otherwise invalid.
class AuthInvalidActionCodeState extends BaseState {
  const AuthInvalidActionCodeState();
}

/// A password reset via OOB code was confirmed successfully.
class AuthPasswordResetConfirmedState extends BaseState {
  const AuthPasswordResetConfirmedState();
}
