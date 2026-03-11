// Unit tests for AuthCubit
//
// HOW TO TEST CUBITS WITHOUT bloc_test
// ─────────────────────────────────────
// BLoC cubits expose a `stream` broadcast stream of every state they emit.
// To capture emissions without the bloc_test package:
//
//   1.  Set up the expectation BEFORE calling the method:
//         final future = expectLater(sut.stream, emitsInOrder([...]));
//   2.  Trigger the method under test (sync or async):
//         await sut.someMethod();
//   3.  Await the expectation so the test fails if states never arrive:
//         await future;
//
// `PendingState` is emitted synchronously inside the cubit via `safeEmit`,
// which means it is received by any subscriber that was listening before the
// call.  Success / error states are emitted after the awaited service call
// resolves (next microtask), so the `emitsInOrder` matcher waits for both.
//
// Run:  flutter test test/cubit/auth/auth_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/auth_user.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockAuthService extends Mock implements AuthService {}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _email = 'user@test.com';
const _password = 'Pass1234!';
const _oobCode = 'oob_code_123';

const _fakeUser = AuthUser(
  uid: 'uid_001',
  email: _email,
  emailVerified: true,
);

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  late MockAuthService mockService;
  late AuthCubit sut;

  setUp(() {
    mockService = MockAuthService();
    sut = AuthCubit(mockService);
  });

  tearDown(() => sut.close());

  // ─── watchAuthState ───────────────────────────────────────────────────

  group('watchAuthState', () {
    test('emits AuthAuthenticatedState when user is logged in', () async {
      when(() => mockService.currentUser$)
          .thenAnswer((_) => Stream.value(_fakeUser));

      final future = expectLater(
        sut.stream,
        emitsInOrder([isA<AuthAuthenticatedState>()]),
      );
      sut.watchAuthState();
      await future;
    });

    test('emits AuthUnauthenticatedState when stream emits null', () async {
      when(() => mockService.currentUser$)
          .thenAnswer((_) => Stream.value(null));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const AuthUnauthenticatedState()]),
      );
      sut.watchAuthState();
      await future;
    });
  });

  // ─── signIn ───────────────────────────────────────────────────────────

  group('signIn', () {
    test('emits pending then success with user', () async {
      when(() => mockService.signIn(email: _email, password: _password))
          .thenAnswer((_) async => _fakeUser);

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AuthSignInSuccessState>()
              .having((s) => s.user, 'user', _fakeUser),
        ]),
      );
      await sut.signIn(email: _email, password: _password);
      await future;
    });

    test('emits pending then invalidCredentials', () async {
      when(() => mockService.signIn(email: _email, password: _password))
          .thenThrow(const InvalidCredentialsException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthInvalidCredentialsState(),
        ]),
      );
      await sut.signIn(email: _email, password: _password);
      await future;
    });

    test('emits pending then emailNotVerified', () async {
      when(() => mockService.signIn(email: _email, password: _password))
          .thenThrow(const EmailNotVerifiedException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthEmailNotVerifiedState(),
        ]),
      );
      await sut.signIn(email: _email, password: _password);
      await future;
    });

    test('emits pending then somethingWentWrong on unknown error', () async {
      when(() => mockService.signIn(email: _email, password: _password))
          .thenThrow(Exception('unknown'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.signIn(email: _email, password: _password);
      await future;
    });
  });

  // ─── signUp ───────────────────────────────────────────────────────────

  group('signUp', () {
    test('emits pending then signUpSuccess', () async {
      when(() => mockService.signUp(email: _email, password: _password))
          .thenAnswer((_) async => _fakeUser);

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthSignUpSuccessState()]),
      );
      await sut.signUp(email: _email, password: _password);
      await future;
    });

    test('emits emailAlreadyInUse', () async {
      when(() => mockService.signUp(email: _email, password: _password))
          .thenThrow(const EmailAlreadyInUseException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthEmailAlreadyInUseState(),
        ]),
      );
      await sut.signUp(email: _email, password: _password);
      await future;
    });

    test('emits weakPassword', () async {
      when(() => mockService.signUp(email: _email, password: _password))
          .thenThrow(const WeakPasswordException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthWeakPasswordState()]),
      );
      await sut.signUp(email: _email, password: _password);
      await future;
    });
  });

  // ─── signOut ──────────────────────────────────────────────────────────

  group('signOut', () {
    test('emits pending then signOutSuccess', () async {
      when(() => mockService.signOut()).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthSignOutSuccessState()]),
      );
      await sut.signOut();
      await future;
    });
  });

  // ─── resetPassword ────────────────────────────────────────────────────

  group('resetPassword', () {
    test('emits pending then passwordResetSent', () async {
      when(() => mockService.resetPassword(_email)).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthPasswordResetSentState(),
        ]),
      );
      await sut.resetPassword(_email);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.resetPassword(_email))
          .thenThrow(Exception('network'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.resetPassword(_email);
      await future;
    });
  });

  // ─── changePassword ───────────────────────────────────────────────────

  group('changePassword', () {
    const newPass = 'NewPass1!';

    test('emits pending then passwordChanged', () async {
      when(() => mockService.changePassword(
            currentPassword: _password,
            newPassword: newPass,
          )).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthPasswordChangedState()]),
      );
      await sut.changePassword(
        currentPassword: _password,
        newPassword: newPass,
      );
      await future;
    });

    test('emits invalidCredentials when current password is wrong', () async {
      when(() => mockService.changePassword(
            currentPassword: 'wrong',
            newPassword: newPass,
          )).thenThrow(const InvalidCredentialsException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthInvalidCredentialsState(),
        ]),
      );
      await sut.changePassword(
        currentPassword: 'wrong',
        newPassword: newPass,
      );
      await future;
    });
  });

  // ─── verifyEmail ──────────────────────────────────────────────────────

  group('verifyEmail', () {
    test('emits pending then emailVerified', () async {
      when(() => mockService.verifyEmail(_oobCode)).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthEmailVerifiedState()]),
      );
      await sut.verifyEmail(_oobCode);
      await future;
    });

    test('emits invalidActionCode when code is expired', () async {
      when(() => mockService.verifyEmail(_oobCode))
          .thenThrow(const InvalidActionCodeException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthInvalidActionCodeState(),
        ]),
      );
      await sut.verifyEmail(_oobCode);
      await future;
    });
  });

  // ─── confirmPasswordReset ─────────────────────────────────────────────

  group('confirmPasswordReset', () {
    const newPass = 'NewPass1!';

    test('emits pending then passwordResetConfirmed', () async {
      when(() => mockService.confirmPasswordReset(
            oobCode: _oobCode,
            newPassword: newPass,
          )).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthPasswordResetConfirmedState(),
        ]),
      );
      await sut.confirmPasswordReset(oobCode: _oobCode, newPassword: newPass);
      await future;
    });

    test('emits invalidActionCode when code is expired', () async {
      when(() => mockService.confirmPasswordReset(
            oobCode: _oobCode,
            newPassword: newPass,
          )).thenThrow(const InvalidActionCodeException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthInvalidActionCodeState(),
        ]),
      );
      await sut.confirmPasswordReset(oobCode: _oobCode, newPassword: newPass);
      await future;
    });
  });
}
