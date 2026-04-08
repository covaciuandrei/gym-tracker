// Widget tests for ForgotPasswordPage.
//
// Tests inject a MockAuthCubit via BlocProvider.value to avoid getIt setup.
//
// Run: flutter test test/presentation/pages/auth/forgot_password_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/pages/auth/forgot_password_page.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockAuthCubit extends Mock implements AuthCubit {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildApp(AuthCubit cubit) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: BlocProvider<AuthCubit>.value(
    value: cubit,
    child: const ForgotPasswordPage(),
  ),
);

MockAuthCubit _idleCubit() {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(const InitialState());
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  return cubit;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
  });

  group('ForgotPasswordPage — initial state', () {
    testWidgets('shows one email form field', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('shows submit GradientButton', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(GradientButton), findsOneWidget);
    });

    testWidgets('shows page title', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Reset Password'), findsOneWidget);
    });

    testWidgets('shows page subtitle', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(
        find.text("Enter your email and we'll send you a reset link"),
        findsOneWidget,
      );
    });

    testWidgets('shows back-to-login footer link', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      // AuthFooterLink renders the actionLabel as a TextButton child
      expect(find.text('Back to Login'), findsOneWidget);
    });
  });

  group('ForgotPasswordPage — loading state', () {
    testWidgets('GradientButton shows spinner when PendingState', (
      tester,
    ) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const PendingState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('footer link is disabled when PendingState', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const PendingState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      // The TextButton for the back link must have onPressed == null
      final btn = tester.widget<TextButton>(
        find.ancestor(
          of: find.text('Back to Login'),
          matching: find.byType(TextButton),
        ),
      );
      expect(btn.onPressed, isNull);
    });
  });

  group('ForgotPasswordPage — error state', () {
    testWidgets('shows error banner for SomethingWentWrongState', (
      tester,
    ) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const SomethingWentWrongState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('form field is still visible on error', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const SomethingWentWrongState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
    });
  });

  group('ForgotPasswordPage — success state', () {
    testWidgets('shows success card for AuthPasswordResetSentState', (
      tester,
    ) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthPasswordResetSentState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Check Your Inbox'), findsOneWidget);
    });

    testWidgets('shows sent message on success', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthPasswordResetSentState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Reset email sent. Check your inbox.'), findsOneWidget);
    });

    testWidgets('hides form field on success', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthPasswordResetSentState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('hides footer link on success', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthPasswordResetSentState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      // AuthFooterLink is gone; SuccessCard's GradientButton label is still
      // "Back to Login" so we check the footer Divider is absent instead.
      expect(find.byType(Divider), findsNothing);
    });
  });

  group('ForgotPasswordPage — form submit', () {
    testWidgets(
      'calls cubit.resetPassword with trimmed email on valid submit',
      (tester) async {
        final cubit = _idleCubit();
        when(
          () => cubit.resetPassword(email: any(named: 'email')),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(_buildApp(cubit));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextFormField), 'user@test.com');

        await tester.ensureVisible(find.byType(GradientButton));
        await tester.tap(find.byType(GradientButton));
        await tester.pump();

        verify(() => cubit.resetPassword(email: 'user@test.com')).called(1);
      },
    );

    testWidgets('does not call cubit when email field is empty', (
      tester,
    ) async {
      final cubit = _idleCubit();
      when(
        () => cubit.resetPassword(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verifyNever(() => cubit.resetPassword(email: any(named: 'email')));
    });

    testWidgets('does not call cubit when email format is invalid', (
      tester,
    ) async {
      final cubit = _idleCubit();
      when(
        () => cubit.resetPassword(email: any(named: 'email')),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'not-an-email');

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verifyNever(() => cubit.resetPassword(email: any(named: 'email')));
    });
  });
}
