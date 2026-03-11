import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/auth_user.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';

part 'auth_states.dart';

@injectable
class AuthCubit extends BaseCubit {
  AuthCubit(this._authService);

  final AuthService _authService;

  StreamSubscription<AuthUser?>? _authSubscription;

  // ─── Auth state watcher ───────────────────────────────────────────────────

  /// Subscribes to [AuthService.currentUser$] and emits
  /// [AuthAuthenticatedState] or [AuthUnauthenticatedState] on every change.
  void watchAuthState() {
    _authSubscription?.cancel();
    _authSubscription = _authService.currentUser$.listen(
      (user) => safeEmit(
        user == null
            ? const AuthUnauthenticatedState()
            : AuthAuthenticatedState(user: user),
      ),
      onError: (_) => safeEmit(const SomethingWentWrongState()),
    );
  }

  // ─── Sign-in ──────────────────────────────────────────────────────────────

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    safeEmit(const PendingState());
    try {
      final user = await _authService.signIn(email: email, password: password);
      safeEmit(AuthSignInSuccessState(user: user));
    } on InvalidCredentialsException {
      safeEmit(const AuthInvalidCredentialsState());
    } on EmailNotVerifiedException {
      safeEmit(const AuthEmailNotVerifiedState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Sign-up ──────────────────────────────────────────────────────────────

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    safeEmit(const PendingState());
    try {
      await _authService.signUp(email: email, password: password);
      safeEmit(const AuthSignUpSuccessState());
    } on EmailAlreadyInUseException {
      safeEmit(const AuthEmailAlreadyInUseState());
    } on WeakPasswordException {
      safeEmit(const AuthWeakPasswordState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Sign-out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    safeEmit(const PendingState());
    try {
      await _authService.signOut();
      safeEmit(const AuthSignOutSuccessState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Reset password ───────────────────────────────────────────────────────

  Future<void> resetPassword(String email) async {
    safeEmit(const PendingState());
    try {
      await _authService.resetPassword(email);
      safeEmit(const AuthPasswordResetSentState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Change password ──────────────────────────────────────────────────────

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    safeEmit(const PendingState());
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      safeEmit(const AuthPasswordChangedState());
    } on InvalidCredentialsException {
      safeEmit(const AuthInvalidCredentialsState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Verify email ─────────────────────────────────────────────────────────

  Future<void> verifyEmail(String oobCode) async {
    safeEmit(const PendingState());
    try {
      await _authService.verifyEmail(oobCode);
      safeEmit(const AuthEmailVerifiedState());
    } on InvalidActionCodeException {
      safeEmit(const AuthInvalidActionCodeState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Confirm password reset ───────────────────────────────────────────────

  Future<void> confirmPasswordReset({
    required String oobCode,
    required String newPassword,
  }) async {
    safeEmit(const PendingState());
    try {
      await _authService.confirmPasswordReset(
        oobCode: oobCode,
        newPassword: newPassword,
      );
      safeEmit(const AuthPasswordResetConfirmedState());
    } on InvalidActionCodeException {
      safeEmit(const AuthInvalidActionCodeState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
