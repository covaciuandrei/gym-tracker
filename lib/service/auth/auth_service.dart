import 'package:firebase_auth/firebase_auth.dart';
import 'package:gym_tracker/model/auth_user.dart';
import 'package:injectable/injectable.dart';

part 'auth_service_exceptions.dart';

@injectable
class AuthService {
  AuthService(this._auth);

  final FirebaseAuth _auth;

  /// Emits the current [AuthUser] whenever auth state changes, or `null` when
  /// signed out.
  Stream<AuthUser?> get currentUser$ => _auth.authStateChanges().map(
    (user) => user == null ? null : _mapUser(user),
  );

  /// Creates a new account and sends an email-verification message.
  /// Throws [EmailAlreadyInUseException] if the email is taken.
  /// Throws [WeakPasswordException] if the password is too short.
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.sendEmailVerification();
      return _mapUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  /// Signs in with [email] and [password].
  /// Throws [EmailNotVerifiedException] if the account is not yet verified.
  /// Throws [InvalidCredentialsException] for wrong email/password.
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      if (!user.emailVerified) {
        // Sign the user back out so they cannot use authenticated endpoints.
        await _auth.signOut();
        throw const EmailNotVerifiedException();
      }
      return _mapUser(user);
    } on EmailNotVerifiedException {
      rethrow;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Sends a password-reset email to [email].
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  /// Re-authenticates with [currentPassword] then updates to [newPassword].
  /// Throws [InvalidCredentialsException] if the current password is wrong.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw const AuthUserNotFoundException();
    }
    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  AuthUser _mapUser(User user) => AuthUser(
    uid: user.uid,
    email: user.email,
    displayName: user.displayName,
    emailVerified: user.emailVerified,
  );

  /// Converts a [FirebaseAuthException] into a typed domain exception.
  Exception _mapFirebaseException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return const InvalidCredentialsException();
      case 'user-disabled':
        return const AuthUserNotFoundException();
      default:
        return e;
    }
  }
}
