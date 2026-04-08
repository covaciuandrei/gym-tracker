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
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/settings/settings_cubit.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/pages/settings/settings_page.dart';

class MockSettingsCubit extends Mock implements SettingsCubit {}

class MockStackRouter extends Mock implements StackRouter {}

Widget _buildApp(
  SettingsCubit settingsCubit,
  StackRouter router,
) {
  return StackRouterScope(
    controller: router,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<SettingsCubit>.value(
        value: settingsCubit,
        child: const SettingsPage(),
      ),
    ),
  );
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

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(const ChangePasswordRoute());
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

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(settingsCubit, router));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('ABOUT'), findsOneWidget);
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('GENERAL'), findsOneWidget);
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

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(settingsCubit, router));
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

    testWidgets('shows dash for version during loading', (tester) async {
      await _registerHelpers();

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final settingsCubit = _stubSettingsCubit(const PendingState());

      await tester.pumpWidget(_buildApp(settingsCubit, router));
      await tester.pump();

      expect(find.text('-'), findsOneWidget);
    });
  });
}
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

MockAuthCubit _stubCubit(BaseState state, Stream<BaseState> stream) {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => stream);
  when(() => cubit.signOut()).thenAnswer((_) async {});
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

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => router.replace(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final authCubit = _stubCubit(const InitialState(), const Stream.empty());
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

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => router.replace(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final authCubit = _stubCubit(const InitialState(), const Stream.empty());
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

    testWidgets('calls signOut when bottom sign-out is tapped', (tester) async {
      await _registerHelpers();

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => router.replace(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final authCubit = _stubCubit(const InitialState(), const Stream.empty());
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

    testWidgets('redirects to login when unauthenticated state is emitted', (
      tester,
    ) async {
      await _registerHelpers();

      final router = MockStackRouter();
      when(() => router.canPop()).thenReturn(true);
      when(
        () => router.push(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);
      when(
        () => router.replace(
          any<PageRouteInfo>(),
          onFailure: any(named: 'onFailure'),
        ),
      ).thenAnswer((_) async => null);

      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final authCubit = _stubCubit(const InitialState(), controller.stream);
      final settingsCubit = _stubSettingsCubit(
        const SettingsReadyState(appVersion: '1.0.0'),
      );

      await tester.pumpWidget(_buildApp(authCubit, settingsCubit, router));
      await tester.pump();

      controller.add(const AuthUnauthenticatedState());
      await tester.pump();

      verify(
        () => router.replace(
          const LoginRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);
    });
  });
}
