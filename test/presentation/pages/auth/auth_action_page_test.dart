// Widget tests for AuthActionPage.
//
// Tests inject a MockAuthCubit via BlocProvider.value to avoid getIt setup.
// The page is instantiated with explicit mode/oobCode constructor params
// (provided by @QueryParam in production; passed directly in tests).
//
// Run: flutter test test/presentation/pages/auth/auth_action_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/pages/auth/auth_action_page.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockAuthCubit extends Mock implements AuthCubit {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildApp(
  AuthCubit cubit, {
  String mode = '',
  String oobCode = 'test-oob-code',
}) =>
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: AuthActionPage(mode: mode, oobCode: oobCode),
      ),
    );

/// Creates a mock cubit that starts at [initialState] and stubs all methods
/// the page may call during [didChangeDependencies].
MockAuthCubit _stubCubit(BaseState initialState) {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(initialState);
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => cubit.verifyEmail(any())).thenAnswer((_) async {});
  when(() => cubit.verifyPasswordResetCode(any())).thenAnswer((_) async {});
  when(
    () => cubit.confirmPasswordReset(
      oobCode: any(named: 'oobCode'),
      newPassword: any(named: 'newPassword'),
    ),
  ).thenAnswer((_) async {});
  return cubit;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
  });

  // ── Unknown / missing mode ────────────────────────────────────────────────

  group('AuthActionPage — unknown mode', () {
    testWidgets('shows error widget for empty mode', (tester) async {
      final cubit = _stubCubit(const InitialState());

      await tester.pumpWidget(_buildApp(cubit, mode: ''));
      await tester.pumpAndSettle();

      expect(find.byType(GradientButton), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('shows error widget for unrecognised mode', (tester) async {
      final cubit = _stubCubit(const InitialState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'recoverEmail'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong. Please try again.'),
          findsOneWidget);
    });
  });

  // ── verifyEmail ───────────────────────────────────────────────────────────

  group('AuthActionPage — verifyEmail mode', () {
    testWidgets('calls cubit.verifyEmail on init', (tester) async {
      final cubit = _stubCubit(const PendingState());

      await tester.pumpWidget(
          _buildApp(cubit, mode: 'verifyEmail', oobCode: 'abc123'));
      await tester.pump();

      verify(() => cubit.verifyEmail('abc123')).called(1);
    });

    testWidgets('shows loading card when PendingState', (tester) async {
      final cubit = _stubCubit(const PendingState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'verifyEmail'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Verifying your email...'), findsOneWidget);
    });

    testWidgets('shows success card when AuthEmailVerifiedState',
        (tester) async {
      final cubit = _stubCubit(const AuthEmailVerifiedState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'verifyEmail'));
      await tester.pumpAndSettle();

      expect(find.text('Email Verified!'), findsOneWidget);
    });

    testWidgets('shows "Go to Sign In" button on success', (tester) async {
      final cubit = _stubCubit(const AuthEmailVerifiedState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'verifyEmail'));
      await tester.pumpAndSettle();

      expect(find.byType(GradientButton), findsOneWidget);
      expect(find.text('Go to Sign In'), findsOneWidget);
    });

    testWidgets('shows error for AuthInvalidActionCodeState', (tester) async {
      final cubit = _stubCubit(const AuthInvalidActionCodeState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'verifyEmail'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'This link has expired or has already been used. Please request a new one.'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Back to Sign In" primary button on error',
        (tester) async {
      final cubit = _stubCubit(const AuthInvalidActionCodeState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'verifyEmail'));
      await tester.pumpAndSettle();

      expect(find.text('Back to Sign In'), findsAtLeast(1));
    });

    testWidgets('shows error for SomethingWentWrongState', (tester) async {
      final cubit = _stubCubit(const SomethingWentWrongState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'verifyEmail'));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong. Please try again.'),
          findsOneWidget);
    });
  });

  // ── resetPassword ─────────────────────────────────────────────────────────

  group('AuthActionPage — resetPassword mode', () {
    testWidgets('calls cubit.verifyPasswordResetCode on init', (tester) async {
      final cubit = _stubCubit(const PendingState());

      await tester.pumpWidget(
          _buildApp(cubit, mode: 'resetPassword', oobCode: 'xyz789'));
      await tester.pump();

      verify(() => cubit.verifyPasswordResetCode('xyz789')).called(1);
    });

    testWidgets('shows loading card when PendingState (before code verified)',
        (tester) async {
      final cubit = _stubCubit(const PendingState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Validating reset link...'), findsOneWidget);
    });

    testWidgets('shows password form when AuthPasswordResetCodeVerifiedState',
        (tester) async {
      final cubit = _stubCubit(
        const AuthPasswordResetCodeVerifiedState(email: 'user@test.com'),
      );

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Set New Password'), findsOneWidget);
    });

    testWidgets('shows success card when AuthPasswordResetConfirmedState',
        (tester) async {
      final cubit = _stubCubit(const AuthPasswordResetConfirmedState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pumpAndSettle();

      expect(find.text('Password Reset!'), findsOneWidget);
    });

    testWidgets('shows "Go to Sign In" button on password reset success',
        (tester) async {
      final cubit = _stubCubit(const AuthPasswordResetConfirmedState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pumpAndSettle();

      expect(find.text('Go to Sign In'), findsOneWidget);
    });

    testWidgets('shows error for AuthInvalidActionCodeState', (tester) async {
      final cubit = _stubCubit(const AuthInvalidActionCodeState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pumpAndSettle();

      expect(
        find.text(
            'This link has expired or has already been used. Please request a new one.'),
        findsOneWidget,
      );
    });

    testWidgets('shows "Request New Link" button on resetPassword error',
        (tester) async {
      final cubit = _stubCubit(const AuthInvalidActionCodeState());

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pumpAndSettle();

      expect(find.text('Request New Link'), findsOneWidget);
      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets(
        'calls cubit.confirmPasswordReset with correct args on valid submit',
        (tester) async {
      final cubit = _stubCubit(
        const AuthPasswordResetCodeVerifiedState(email: 'user@test.com'),
      );

      await tester.pumpWidget(
          _buildApp(cubit, mode: 'resetPassword', oobCode: 'reset-code'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(0), 'NewPass1');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'NewPass1');

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verify(
        () => cubit.confirmPasswordReset(
          oobCode: 'reset-code',
          newPassword: 'NewPass1',
        ),
      ).called(1);
    });

    testWidgets('does not submit when passwords do not match', (tester) async {
      final cubit = _stubCubit(
        const AuthPasswordResetCodeVerifiedState(email: 'user@test.com'),
      );

      await tester.pumpWidget(_buildApp(cubit, mode: 'resetPassword'));
      await tester.pumpAndSettle();

      await tester.enterText(
          find.byType(TextFormField).at(0), 'NewPass1');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'DifferentPass1');

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verifyNever(
        () => cubit.confirmPasswordReset(
          oobCode: any(named: 'oobCode'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });
  });
}
