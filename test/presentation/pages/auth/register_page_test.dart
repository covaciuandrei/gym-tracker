// Widget tests for RegisterPage.
//
// Tests inject a MockAuthCubit via BlocProvider.value to avoid getIt setup.
//
// Run: flutter test test/presentation/pages/auth/register_page_test.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/presentation/controls/gradient_button.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/pages/auth/register_page.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Mock ─────────────────────────────────────────────────────────────────────

class MockAuthCubit extends Mock implements AuthCubit {}

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildApp(AuthCubit cubit) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: BlocProvider<AuthCubit>.value(value: cubit, child: const RegisterPage()),
);

MockAuthCubit _idleCubit() {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(const InitialState());
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  return cubit;
}

Future<void> _registerHelpers() async {
  SharedPreferences.setMockInitialValues(const {'app_locale': 'en'});
  final prefs = await SharedPreferences.getInstance();

  if (getIt.isRegistered<LocaleHelper>()) {
    getIt.unregister<LocaleHelper>();
  }
  if (getIt.isRegistered<AppVersionStatus>()) {
    getIt.unregister<AppVersionStatus>();
  }
  getIt.registerSingleton<LocaleHelper>(LocaleHelper(prefs));
  getIt.registerSingleton<AppVersionStatus>(AppVersionStatus());
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(const <String, Object?>{});
  });

  setUp(() async {
    await _registerHelpers();
  });

  tearDown(() {
    if (getIt.isRegistered<LocaleHelper>()) {
      getIt.unregister<LocaleHelper>();
    }
    if (getIt.isRegistered<AppVersionStatus>()) {
      getIt.unregister<AppVersionStatus>();
    }
  });

  group('RegisterPage — initial state', () {
    testWidgets('shows four form fields (displayName, email, password, confirm)', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('shows submit GradientButton', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(GradientButton), findsOneWidget);
    });

    testWidgets('shows footer sign-in link', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('first button reads "Continue" on iOS, where a personal-details step follows', (tester) async {
      await tester.pumpWidget(_buildApp(_idleCubit()));
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(GradientButton), matching: find.text('Continue')), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('first button reads "Create Account" on Android, where there is no second step', (tester) async {
      await tester.pumpWidget(_buildApp(_idleCubit()));
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(GradientButton), matching: find.text('Create Account')), findsOneWidget);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });

  group('RegisterPage — loading state', () {
    testWidgets('GradientButton shows spinner when PendingState', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const PendingState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('RegisterPage — error states', () {
    testWidgets('shows error banner for AuthEmailAlreadyInUseState', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthEmailAlreadyInUseState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('This email is already in use.'), findsOneWidget);
    });

    testWidgets('shows error banner for AuthWeakPasswordState', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthWeakPasswordState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Password is too weak.'), findsOneWidget);
    });

    testWidgets('shows error banner for SomethingWentWrongState', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const SomethingWentWrongState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong. Please try again.'), findsOneWidget);
    });
  });

  group('RegisterPage — success state', () {
    testWidgets('shows success card for AuthSignUpSuccessState', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthSignUpSuccessState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Account Created!'), findsOneWidget);
    });

    testWidgets('hides form fields on success', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthSignUpSuccessState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('hides footer section on success', (tester) async {
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const AuthSignUpSuccessState());
      when(() => cubit.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      expect(find.text('Sign in'), findsNothing);
    });
  });

  group('RegisterPage — form submit', () {
    testWidgets('calls cubit.signUp with correct credentials after skipping personal details (iOS)', (tester) async {
      final cubit = _idleCubit();
      when(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
          sex: any(named: 'sex'),
          birthDate: any(named: 'birthDate'),
          heightCm: any(named: 'heightCm'),
          weightKg: any(named: 'weightKg'),
          bodyType: any(named: 'bodyType'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePass1');

      // Two checkboxes now: age (first) + legal consent (second).
      await tester.ensureVisible(find.byType(Checkbox).first);
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      await tester.ensureVisible(find.byType(Checkbox).at(1));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      // Continue advances to the optional personal-details step (step 2) —
      // signUp is not called yet.
      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      verifyNever(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
          sex: any(named: 'sex'),
          birthDate: any(named: 'birthDate'),
          heightCm: any(named: 'heightCm'),
          weightKg: any(named: 'weightKg'),
          bodyType: any(named: 'bodyType'),
        ),
      );

      // Skip the personal-details step — signUp fires with every optional
      // field set to null regardless of the (empty) form state.
      await tester.ensureVisible(find.text('Skip for now'));
      await tester.tap(find.text('Skip for now'));
      await tester.pump();

      verify(
        () => cubit.signUp(
          email: 'user@test.com',
          password: 'SecurePass1',
          displayName: 'Test User',
          language: 'en',
          consent: any(named: 'consent'),
          sex: null,
          birthDate: null,
          heightCm: null,
          weightKg: null,
          bodyType: null,
        ),
      ).called(1);
    }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

    testWidgets('signs up straight from the first step on Android, with no personal details', (tester) async {
      final cubit = _idleCubit();
      when(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
          sex: any(named: 'sex'),
          birthDate: any(named: 'birthDate'),
          heightCm: any(named: 'heightCm'),
          weightKg: any(named: 'weightKg'),
          bodyType: any(named: 'bodyType'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePass1');

      await tester.ensureVisible(find.byType(Checkbox).first);
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();
      await tester.ensureVisible(find.byType(Checkbox).at(1));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pumpAndSettle();

      verify(
        () => cubit.signUp(
          email: 'user@test.com',
          password: 'SecurePass1',
          displayName: 'Test User',
          language: 'en',
          consent: any(named: 'consent'),
          sex: null,
          birthDate: null,
          heightCm: null,
          weightKg: null,
          bodyType: null,
        ),
      ).called(1);
      expect(find.text('Skip for now'), findsNothing);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));

    testWidgets('does NOT call signUp when legal consent is unchecked', (tester) async {
      final cubit = _idleCubit();
      when(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePass1');

      // Tick age only, leave legal unchecked.
      await tester.ensureVisible(find.byType(Checkbox).at(0));
      await tester.tap(find.byType(Checkbox).at(0));
      await tester.pump();

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verifyNever(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      );
      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsOneWidget);
    });

    testWidgets('does NOT call signUp when age confirmation is unchecked', (tester) async {
      final cubit = _idleCubit();
      when(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePass1');

      // Tick legal only, leave age unchecked.
      await tester.ensureVisible(find.byType(Checkbox).at(1));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verifyNever(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      );
      expect(find.text('You must be at least 16 years old to use this app.'), findsOneWidget);
    });

    testWidgets('shows consent error then clears it when user ticks the checkbox', (tester) async {
      final cubit = _idleCubit();
      when(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'user@test.com');
      await tester.enterText(find.byType(TextFormField).at(2), 'SecurePass1');
      await tester.enterText(find.byType(TextFormField).at(3), 'SecurePass1');

      // Trigger the error first by submitting without consent.
      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();
      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsOneWidget);

      // Ticking the legal checkbox clears the legal error.
      await tester.ensureVisible(find.byType(Checkbox).at(1));
      await tester.tap(find.byType(Checkbox).at(1));
      await tester.pump();

      expect(find.text('You must accept the Terms of Service and Privacy Policy to continue.'), findsNothing);
    });

    testWidgets('does not call signUp when email is invalid', (tester) async {
      final cubit = _idleCubit();
      when(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      // Fill displayName and password but use an invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'Test User');
      await tester.enterText(find.byType(TextFormField).at(1), 'not-an-email');

      await tester.ensureVisible(find.byType(GradientButton));
      await tester.tap(find.byType(GradientButton));
      await tester.pump();

      verifyNever(
        () => cubit.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          displayName: any(named: 'displayName'),
          language: any(named: 'language'),
          consent: any(named: 'consent'),
        ),
      );
    });
  });

  group('RegisterPage — buildWhen', () {
    testWidgets('rebuilds when PendingState is emitted via stream', (tester) async {
      final streamCtrl = StreamController<BaseState>.broadcast();
      final cubit = MockAuthCubit();
      when(() => cubit.state).thenReturn(const InitialState());
      when(() => cubit.stream).thenAnswer((_) => streamCtrl.stream);

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pumpAndSettle();

      // No spinner initially
      expect(find.byType(CircularProgressIndicator), findsNothing);

      when(() => cubit.state).thenReturn(const PendingState());
      streamCtrl.add(const PendingState());
      await tester.pump(); // flush stream delivery microtask
      await tester.pump(); // render the rebuilt frame

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await streamCtrl.close();
    });
  });
}
