// Unit tests for AuthService
//
// MOCKING PRIMER (mocktail):
//   mocktail lets you create fake objects without implementing every method.
//
//   1. Declare a Mock class:
//        class MockFirebaseAuth extends Mock implements FirebaseAuth {}
//   2. Stub a method (arrange):
//        when(() => mockAuth.signOut()).thenAnswer((_) async {});
//   3. Assert a call was made (verify):
//        verify(() => mockAuth.signOut()).called(1);
//
//   For streams: thenAnswer((_) => Stream.value(someValue))
//   For Futures: thenAnswer((_) async => someValue)
//   For throws:  thenThrow(SomeException())
//   For conditional matching: use `any()` or a custom matcher.
//
// Run all tests:
//   flutter test test/service/auth/auth_service_test.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/model/auth_user.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';

// ─── Mock classes ──────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

// mocktail requires a registered fallback for every custom type used with any()
class _FakeAuthCredential extends Fake implements AuthCredential {}

// ─── Helpers ───────────────────────────────────────────────────────────────

/// Creates a [MockUser] whose common properties are stubbed.
MockUser _mockUser({
  String uid = 'uid_001',
  String email = 'user@example.com',
  String? displayName,
  bool emailVerified = true,
}) {
  final user = MockUser();
  when(() => user.uid).thenReturn(uid);
  when(() => user.email).thenReturn(email);
  when(() => user.displayName).thenReturn(displayName);
  when(() => user.emailVerified).thenReturn(emailVerified);
  return user;
}

/// Creates a [MockUserCredential] wrapping [user].
MockUserCredential _mockCredential(MockUser user) {
  final cred = MockUserCredential();
  when(() => cred.user).thenReturn(user);
  return cred;
}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAuthCredential());
  });

  late MockFirebaseAuth mockAuth;
  late AuthService sut; // system under test

  setUp(() {
    mockAuth = MockFirebaseAuth();
    sut = AuthService(mockAuth);
  });

  // ─── currentUser$ ──────────────────────────────────────────────────────

  group('currentUser\$', () {
    test('emits null when Firebase user is null', () {
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(null));

      expect(sut.currentUser$, emits(null));
    });

    test('emits mapped AuthUser when Firebase user is present', () {
      final user = _mockUser(uid: 'u1', email: 'a@b.com', emailVerified: true);
      when(
        () => mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(user));

      expect(
        sut.currentUser$,
        emits(
          isA<AuthUser>()
              .having((u) => u.uid, 'uid', 'u1')
              .having((u) => u.email, 'email', 'a@b.com')
              .having((u) => u.emailVerified, 'emailVerified', true),
        ),
      );
    });
  });

  // ─── signUp ────────────────────────────────────────────────────────────

  group('signUp', () {
    test(
      'creates account, sends verification email, returns AuthUser',
      () async {
        final user = _mockUser(emailVerified: false);
        final cred = _mockCredential(user);

        when(
          () => mockAuth.createUserWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => cred);
        when(() => user.sendEmailVerification()).thenAnswer((_) async {});

        final result = await sut.signUp(
          email: 'new@test.com',
          password: 'Pass1234',
        );

        expect(result.uid, user.uid);
        verify(() => user.sendEmailVerification()).called(1);
      },
    );

    test('throws EmailAlreadyInUseException on email-already-in-use', () async {
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));

      expect(
        () => sut.signUp(email: 'dup@test.com', password: 'Pass1234'),
        throwsA(isA<EmailAlreadyInUseException>()),
      );
    });

    test('throws WeakPasswordException on weak-password', () async {
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'weak-password'));

      expect(
        () => sut.signUp(email: 'x@test.com', password: '123'),
        throwsA(isA<WeakPasswordException>()),
      );
    });
  });

  // ─── signIn ────────────────────────────────────────────────────────────

  group('signIn', () {
    test(
      'returns AuthUser when credentials valid and email verified',
      () async {
        final user = _mockUser(emailVerified: true);
        final cred = _mockCredential(user);

        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => cred);

        final result = await sut.signIn(
          email: 'user@test.com',
          password: 'Pass1234',
        );

        expect(result.uid, user.uid);
        expect(result.emailVerified, isTrue);
      },
    );

    test(
      'throws EmailNotVerifiedException and signs out when not verified',
      () async {
        final user = _mockUser(emailVerified: false);
        final cred = _mockCredential(user);

        when(
          () => mockAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => cred);
        when(() => mockAuth.signOut()).thenAnswer((_) async {});

        await expectLater(
          sut.signIn(email: 'user@test.com', password: 'Pass1234'),
          throwsA(isA<EmailNotVerifiedException>()),
        );
        verify(() => mockAuth.signOut()).called(1);
      },
    );

    test('throws InvalidCredentialsException on wrong-password', () async {
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      expect(
        () => sut.signIn(email: 'user@test.com', password: 'wrong'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('throws InvalidCredentialsException on invalid-credential', () async {
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      expect(
        () => sut.signIn(email: 'user@test.com', password: 'bad'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  // ─── signOut ───────────────────────────────────────────────────────────

  group('signOut', () {
    test('delegates to FirebaseAuth.signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await sut.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });
  });

  // ─── resetPassword ─────────────────────────────────────────────────────

  group('resetPassword', () {
    test('calls sendPasswordResetEmail with given email', () async {
      when(
        () => mockAuth.sendPasswordResetEmail(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      await sut.resetPassword('user@test.com');

      verify(
        () => mockAuth.sendPasswordResetEmail(email: 'user@test.com'),
      ).called(1);
    });
  });

  // ─── changePassword ────────────────────────────────────────────────────

  group('changePassword', () {
    test('reauthenticates then updates password', () async {
      final user = _mockUser(email: 'user@test.com');
      when(() => mockAuth.currentUser).thenReturn(user);
      when(
        () => user.reauthenticateWithCredential(any()),
      ).thenAnswer((_) async => _mockCredential(user));
      when(() => user.updatePassword(any())).thenAnswer((_) async {});

      await sut.changePassword(
        currentPassword: 'OldPass!1',
        newPassword: 'NewPass!1',
      );

      verify(() => user.reauthenticateWithCredential(any())).called(1);
      verify(() => user.updatePassword('NewPass!1')).called(1);
    });

    test(
      'throws AuthUserNotFoundException when there is no current user',
      () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        expect(
          () => sut.changePassword(currentPassword: 'Old', newPassword: 'New'),
          throwsA(isA<AuthUserNotFoundException>()),
        );
      },
    );

    test(
      'throws InvalidCredentialsException on wrong current password',
      () async {
        final user = _mockUser(email: 'user@test.com');
        when(() => mockAuth.currentUser).thenReturn(user);
        when(
          () => user.reauthenticateWithCredential(any()),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        expect(
          () => sut.changePassword(
            currentPassword: 'wrong',
            newPassword: 'NewPass!1',
          ),
          throwsA(isA<InvalidCredentialsException>()),
        );
      },
    );
  });
}
