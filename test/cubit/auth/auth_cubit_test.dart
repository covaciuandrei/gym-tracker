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
import 'package:gym_tracker/service/account/account_cleanup_service.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/user/user_service.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

class MockAccountCleanupService extends Mock implements AccountCleanupService {}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _email = 'user@test.com';
const _password = 'Pass1234!';
const _displayName = 'Test User';

const _fakeUser = AuthUser(uid: 'uid_001', email: _email, emailVerified: true);

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  late MockAuthService mockService;
  late MockUserService mockUserService;
  late MockAccountCleanupService mockCleanupService;
  late AuthCubit sut;

  setUp(() {
    mockService = MockAuthService();
    mockUserService = MockUserService();
    mockCleanupService = MockAccountCleanupService();
    sut = AuthCubit(mockService, mockUserService, mockCleanupService);

    // Default stubs for profile sync — best-effort, always succeed.
    when(
      () => mockUserService.recordLogin(userId: any(named: 'userId')),
    ).thenAnswer((_) async {});
    when(
      () => mockUserService.createUser(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
        displayName: any(named: 'displayName'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() => sut.close());

  // ─── watchAuthState ───────────────────────────────────────────────────

  group('watchAuthState', () {
    test('emits AuthAuthenticatedState when user is logged in', () async {
      when(
        () => mockService.currentUser$,
      ).thenAnswer((_) => Stream.value(_fakeUser));

      final future = expectLater(
        sut.stream,
        emitsInOrder([isA<AuthAuthenticatedState>()]),
      );
      sut.watchAuthState();
      await future;
    });

    test('emits AuthUnauthenticatedState when stream emits null', () async {
      when(
        () => mockService.currentUser$,
      ).thenAnswer((_) => Stream.value(null));

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
      when(
        () => mockService.signIn(email: _email, password: _password),
      ).thenAnswer((_) async => _fakeUser);

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<AuthSignInSuccessState>().having(
            (s) => s.user,
            'user',
            _fakeUser,
          ),
        ]),
      );
      await sut.signIn(email: _email, password: _password);
      await future;
    });

    test('emits pending then invalidCredentials', () async {
      when(
        () => mockService.signIn(email: _email, password: _password),
      ).thenThrow(const InvalidCredentialsException());

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
      when(
        () => mockService.signIn(email: _email, password: _password),
      ).thenThrow(const EmailNotVerifiedException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthEmailNotVerifiedState()]),
      );
      await sut.signIn(email: _email, password: _password);
      await future;
    });

    test('emits pending then somethingWentWrong on unknown error', () async {
      when(
        () => mockService.signIn(email: _email, password: _password),
      ).thenThrow(Exception('unknown'));

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
      when(
        () => mockService.signUp(email: _email, password: _password),
      ).thenAnswer((_) async => _fakeUser);
      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthSignUpSuccessState()]),
      );
      await sut.signUp(
        email: _email,
        password: _password,
        displayName: _displayName,
      );
      await future;
    });

    test('emits emailAlreadyInUse', () async {
      when(
        () => mockService.signUp(email: _email, password: _password),
      ).thenThrow(const EmailAlreadyInUseException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthEmailAlreadyInUseState(),
        ]),
      );
      await sut.signUp(
        email: _email,
        password: _password,
        displayName: _displayName,
      );
      await future;
    });

    test('emits weakPassword', () async {
      when(
        () => mockService.signUp(email: _email, password: _password),
      ).thenThrow(const WeakPasswordException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthWeakPasswordState()]),
      );
      await sut.signUp(
        email: _email,
        password: _password,
        displayName: _displayName,
      );
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
      await sut.resetPassword(email: _email);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(
        () => mockService.resetPassword(_email),
      ).thenThrow(Exception('network'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.resetPassword(email: _email);
      await future;
    });
  });

  // ─── changePassword ───────────────────────────────────────────────────

  group('changePassword', () {
    const newPass = 'NewPass1!';

    test('emits pending then passwordChanged', () async {
      when(
        () => mockService.changePassword(
          currentPassword: _password,
          newPassword: newPass,
        ),
      ).thenAnswer((_) async {});

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
      when(
        () => mockService.changePassword(
          currentPassword: 'wrong',
          newPassword: newPass,
        ),
      ).thenThrow(const InvalidCredentialsException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthInvalidCredentialsState(),
        ]),
      );
      await sut.changePassword(currentPassword: 'wrong', newPassword: newPass);
      await future;
    });
  });

  // ─── deleteAccount ────────────────────────────────────────────────────

  group('deleteAccount', () {
    test('emits pending then accountDeleted on success', () async {
      when(
        () => mockService.reauthenticate(currentPassword: _password),
      ).thenAnswer((_) async {});
      when(() => mockService.currentUserId).thenReturn('uid_001');
      when(
        () => mockCleanupService.deleteAllUserData(userId: 'uid_001'),
      ).thenAnswer((_) async {});
      when(() => mockService.deleteAccount()).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const AuthAccountDeletedState()]),
      );
      await sut.deleteAccount(currentPassword: _password);
      await future;

      verify(
        () => mockCleanupService.deleteAllUserData(userId: 'uid_001'),
      ).called(1);
      verify(() => mockService.deleteAccount()).called(1);
    });

    test('calls reauthenticate → cleanup → deleteAccount in order', () async {
      when(
        () => mockService.reauthenticate(currentPassword: _password),
      ).thenAnswer((_) async {});
      when(() => mockService.currentUserId).thenReturn('uid_001');
      when(
        () => mockCleanupService.deleteAllUserData(userId: 'uid_001'),
      ).thenAnswer((_) async {});
      when(() => mockService.deleteAccount()).thenAnswer((_) async {});

      await sut.deleteAccount(currentPassword: _password);

      verifyInOrder([
        () => mockService.reauthenticate(currentPassword: _password),
        () => mockCleanupService.deleteAllUserData(userId: 'uid_001'),
        () => mockService.deleteAccount(),
      ]);
    });

    test('emits invalidCredentials when password is wrong', () async {
      when(
        () => mockService.reauthenticate(currentPassword: 'wrong'),
      ).thenThrow(const InvalidCredentialsException());

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const AuthInvalidCredentialsState(),
        ]),
      );
      await sut.deleteAccount(currentPassword: 'wrong');
      await future;

      verifyNever(
        () =>
            mockCleanupService.deleteAllUserData(userId: any(named: 'userId')),
      );
      verifyNever(() => mockService.deleteAccount());
    });

    test('emits somethingWentWrong when cleanup fails', () async {
      when(
        () => mockService.reauthenticate(currentPassword: _password),
      ).thenAnswer((_) async {});
      when(() => mockService.currentUserId).thenReturn('uid_001');
      when(
        () => mockCleanupService.deleteAllUserData(userId: 'uid_001'),
      ).thenThrow(Exception('firestore error'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.deleteAccount(currentPassword: _password);
      await future;

      verifyNever(() => mockService.deleteAccount());
    });

    test('emits somethingWentWrong when currentUserId is null', () async {
      when(
        () => mockService.reauthenticate(currentPassword: _password),
      ).thenAnswer((_) async {});
      when(() => mockService.currentUserId).thenReturn(null);

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.deleteAccount(currentPassword: _password);
      await future;
    });
  });
}
