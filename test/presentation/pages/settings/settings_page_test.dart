import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/assets/theme/theme_helper.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/settings/settings_cubit.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/pages/settings/settings_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

class MockSettingsCubit extends Mock implements SettingsCubit {}

class MockStackRouter extends Mock implements StackRouter {}

Widget _buildApp(
  AuthCubit authCubit,
  SettingsCubit settingsCubit,
  StackRouter router,
) {
  return StackRouterScope(
    controller: router,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<SettingsCubit>.value(value: settingsCubit),
        ],
        child: const SettingsPage(),
      ),
    ),
  );
}

MockAuthCubit _stubAuthCubit(BaseState state, Stream<BaseState> stream) {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => stream);
  when(() => cubit.signOut()).thenAnswer((_) async {});
  when(
    () => cubit.deleteAccount(currentPassword: any(named: 'currentPassword')),
  ).thenAnswer((_) async {});
  return cubit;
}

MockSettingsCubit _stubSettingsCubit(BaseState state) {
  final cubit = MockSettingsCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => cubit.init()).thenAnswer((_) async {});
  return cubit;
}

Future<void> _registerHelpers() async {
  SharedPreferences.setMockInitialValues(const {
    'app_theme_dark': true,
    'app_locale': 'en',
  });
  final prefs = await SharedPreferences.getInstance();

  if (getIt.isRegistered<ThemeHelper>()) {
    getIt.unregister<ThemeHelper>();
  }
  if (getIt.isRegistered<LocaleHelper>()) {
    getIt.unregister<LocaleHelper>();
  }

  getIt.registerSingleton<ThemeHelper>(ThemeHelper(prefs));
  getIt.registerSingleton<LocaleHelper>(LocaleHelper(prefs));
}

StackRouter _stubRouter() {
  final router = MockStackRouter();
  when(() => router.canPop()).thenReturn(true);
  when(
    () => router.push(any<PageRouteInfo>(), onFailure: any(named: 'onFailure')),
  ).thenAnswer((_) async => null);
  when(
    () => router.replace(
      any<PageRouteInfo>(),
      onFailure: any(named: 'onFailure'),
    ),
  ).thenAnswer((_) async => null);
  return router;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(const ChangePasswordRoute());
    registerFallbackValue(const LoginRoute());
    registerFallbackValue(const SettingsReadyState(appVersion: '-'));
  });

  tearDown(() {
    if (getIt.isRegistered<ThemeHelper>()) {
      getIt.unregister<ThemeHelper>();
    }
    if (getIt.isRegistered<LocaleHelper>()) {
      getIt.unregister<LocaleHelper>();
    }
  });

  group('SettingsPage', () {
    testWidgets('renders key sections and labels', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final authCubit = _stubAuthCubit(
        const InitialState(),
        const Stream.empty(),
      );
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
      expect(find.text('ACTIONS'), findsOneWidget);
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Change Password'), findsWidgets);
      verify(() => settingsCubit.init()).called(1);
    });

    testWidgets('navigates to change-password page from account row', (
      tester,
    ) async {
      await _registerHelpers();

      final router = _stubRouter();
      final authCubit = _stubAuthCubit(
        const InitialState(),
        const Stream.empty(),
      );
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      await tester.tap(find.text('Change Password'));
      await tester.pump();

      verify(
        () => router.push(
          const ChangePasswordRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);
    });

    testWidgets('calls signOut when Sign Out is tapped', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final authCubit = _stubAuthCubit(
        const InitialState(),
        const Stream.empty(),
      );
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      await tester.ensureVisible(find.text('Sign Out'));
      await tester.tap(find.text('Sign Out'));
      await tester.pump();

      verify(() => authCubit.signOut()).called(1);
    });

    testWidgets('redirects to login on sign-out success', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final authCubit = _stubAuthCubit(const InitialState(), controller.stream);
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      controller.add(const AuthSignOutSuccessState());
      await tester.pump();

      verify(
        () => router.replace(
          const LoginRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);
    });

    testWidgets('redirects to login on account deleted', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final authCubit = _stubAuthCubit(const InitialState(), controller.stream);
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      controller.add(const AuthAccountDeletedState());
      await tester.pump();

      verify(
        () => router.replace(
          const LoginRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);
    });

    testWidgets('shows delete account option in actions section', (
      tester,
    ) async {
      await _registerHelpers();

      final router = _stubRouter();
      final authCubit = _stubAuthCubit(
        const InitialState(),
        const Stream.empty(),
      );
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      await tester.ensureVisible(find.text('Delete Account'));
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('shows dash for version during loading', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final authCubit = _stubAuthCubit(
        const InitialState(),
        const Stream.empty(),
      );
      final settingsCubit = _stubSettingsCubit(const PendingState());

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('shows snackbar on invalid credentials', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final authCubit = _stubAuthCubit(const InitialState(), controller.stream);
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      controller.add(const AuthInvalidCredentialsState());
      await tester.pump();

      expect(find.text('Invalid email or password.'), findsOneWidget);
    });

    testWidgets('shows snackbar on something went wrong', (tester) async {
      await _registerHelpers();

      final router = _stubRouter();
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final authCubit = _stubAuthCubit(const InitialState(), controller.stream);
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      controller.add(const SomethingWentWrongState());
      await tester.pump();

      expect(
        find.text('Something went wrong. Please try again.'),
        findsOneWidget,
      );
    });

    testWidgets('delete account dialog submits password to cubit', (
      tester,
    ) async {
      await _registerHelpers();

      final router = _stubRouter();
      final authCubit = _stubAuthCubit(
        const InitialState(),
        const Stream.empty(),
      );
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      // Tap the "Delete Account" row to open the dialog.
      await tester.ensureVisible(find.text('Delete Account'));
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      // Dialog should be visible.
      expect(find.text('Delete Account'), findsWidgets);
      expect(
        find.text(
          'This will permanently delete your account and all your data '
          '(workouts, supplements logs, training types). '
          'This action cannot be undone.',
        ),
        findsOneWidget,
      );

      // Enter password into the text field.
      await tester.enterText(find.byType(TextField), 'MyPassword1!');
      await tester.pump();

      // Tap the confirm button.
      await tester.tap(find.text('Delete My Account'));
      await tester.pumpAndSettle();

      verify(
        () => authCubit.deleteAccount(currentPassword: 'MyPassword1!'),
      ).called(1);
    });

    testWidgets(
      'delete account dialog does not call cubit with empty password',
      (tester) async {
        await _registerHelpers();

        final router = _stubRouter();
        final authCubit = _stubAuthCubit(
          const InitialState(),
          const Stream.empty(),
        );
        final settingsCubit = _stubSettingsCubit(
          const SettingsReadyState(appVersion: '1.0.0'),
        );

        await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
        await tester.pump();

        // Open the dialog.
        await tester.ensureVisible(find.text('Delete Account'));
        await tester.tap(find.text('Delete Account'));
        await tester.pumpAndSettle();

        // Tap confirm without entering a password.
        await tester.tap(find.text('Delete My Account'));
        await tester.pumpAndSettle();

        verifyNever(
          () => authCubit.deleteAccount(
            currentPassword: any(named: 'currentPassword'),
          ),
        );
      },
    );
  });
}
