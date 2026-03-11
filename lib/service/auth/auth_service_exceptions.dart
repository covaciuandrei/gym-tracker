part of 'auth_service.dart';

/// Thrown when sign-in credentials (email/password) are wrong.
class InvalidCredentialsException implements Exception {
  const InvalidCredentialsException();
}

/// Thrown when attempting to sign in before email is verified.
class EmailNotVerifiedException implements Exception {
  const EmailNotVerifiedException();
}

/// Thrown when sign-up is attempted with an email that already has an account.
class EmailAlreadyInUseException implements Exception {
  const EmailAlreadyInUseException();
}

/// Thrown when the chosen password does not meet Firebase's minimum length.
class WeakPasswordException implements Exception {
  const WeakPasswordException();
}

/// Thrown when an OOB action code (from a deep-link) is expired or invalid.
class InvalidActionCodeException implements Exception {
  const InvalidActionCodeException();
}

/// Thrown when there is no authenticated user where one is expected, or when
/// the Firebase account has been disabled.
class AuthUserNotFoundException implements Exception {
  const AuthUserNotFoundException();
}
