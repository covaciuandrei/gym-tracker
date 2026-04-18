import 'dart:async';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/auth_user.dart';
import 'package:gym_tracker/service/account/account_cleanup_service.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:injectable/injectable.dart';

part 'auth_states.dart';

@injectable
class AuthCubit extends BaseCubit {
  AuthCubit(this._authService, this._userService, this._cleanupService);

  final AuthService _authService;
  final UserService _userService;
  final AccountCleanupService _cleanupService;

  StreamSubscription<AuthUser?>? _authSubscription;

  /// Subscribes to [AuthService.currentUser$] and emits
  /// [AuthAuthenticatedState] or [AuthUnauthenticatedState] on every change.
  void watchAuthState() {
    _authSubscription?.cancel();
    _authSubscription = _authService.currentUser$.listen(
      (user) => safeEmit(user == null ? const AuthUnauthenticatedState() : AuthAuthenticatedState(user: user)),
      onError: (_) => safeEmit(const SomethingWentWrongState()),
    );
  }

  Future<void> signIn({required String email, required String password}) async {
    safeEmit(const PendingState());
    try {
      final user = await _authService.signIn(email: email, password: password);
      await _recordLogin(user: user);
      safeEmit(AuthSignInSuccessState(user: user));
    } on InvalidCredentialsException {
      safeEmit(const AuthInvalidCredentialsState());
    } on EmailNotVerifiedException {
      safeEmit(const AuthEmailNotVerifiedState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
    required Map<String, Object?> consent,
  }) async {
    safeEmit(const PendingState());
    try {
      final user = await _authService.signUp(email: email, password: password);
      await _createUser(user: user, displayName: displayName, consent: consent);
      safeEmit(const AuthSignUpSuccessState());
    } on EmailAlreadyInUseException {
      safeEmit(const AuthEmailAlreadyInUseState());
    } on WeakPasswordException {
      safeEmit(const AuthWeakPasswordState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> signOut() async {
    safeEmit(const PendingState());
    try {
      await _authService.signOut();
      safeEmit(const AuthSignOutSuccessState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> resetPassword({required String email}) async {
    safeEmit(const PendingState());
    try {
      await _authService.resetPassword(email);
      safeEmit(const AuthPasswordResetSentState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    safeEmit(const PendingState());
    try {
      await _authService.changePassword(currentPassword: currentPassword, newPassword: newPassword);
      safeEmit(const AuthPasswordChangedState());
    } on InvalidCredentialsException {
      safeEmit(const AuthInvalidCredentialsState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Deletes all user data from Firestore, then deletes the Firebase Auth
  /// account.
  ///
  /// Flow: reauthenticate → cleanup Firestore → delete Auth account.
  Future<void> deleteAccount({required String currentPassword}) async {
    if (state is PendingState) return;
    safeEmit(const PendingState());
    try {
      await _authService.reauthenticate(currentPassword: currentPassword);

      final uid = _authService.currentUserId;
      if (uid == null) throw const AuthUserNotFoundException();

      await _cleanupService.deleteAllUserData(userId: uid);
      await _authService.deleteAccount();

      safeEmit(const AuthAccountDeletedState());
    } on InvalidCredentialsException {
      safeEmit(const AuthInvalidCredentialsState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Best-effort profile creation after sign-up.
  Future<void> _createUser({
    required AuthUser user,
    required String displayName,
    required Map<String, Object?> consent,
  }) async {
    try {
      await _userService.createUser(
        userId: user.uid,
        email: user.email ?? '',
        displayName: displayName,
        consent: consent,
      );
    } catch (_) {
      // Best-effort — do not block auth flow on profile sync failure.
    }
  }

  /// Best-effort login timestamp update after sign-in.
  Future<void> _recordLogin({required AuthUser user}) async {
    try {
      await _userService.recordLogin(userId: user.uid);
    } catch (_) {
      // Best-effort — do not block auth flow on profile sync failure.
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
