import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/auth_user.dart';
import 'package:gym_tracker/presentation/pages/profile/profile_page.dart';

class MockAuthCubit extends Mock implements AuthCubit {}

class MockStackRouter extends Mock implements StackRouter {}

Widget _buildApp(AuthCubit cubit, StackRouter router) {
  return StackRouterScope(
    controller: router,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthCubit>.value(
        value: cubit,
        child: const ProfilePage(),
      ),
    ),
  );
}

MockAuthCubit _stubCubit(BaseState state, Stream<BaseState> stream) {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => stream);
  when(() => cubit.watchAuthState()).thenReturn(null);
  when(() => cubit.signOut()).thenAnswer((_) async {});
  return cubit;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(const LoginRoute());
    registerFallbackValue(const WorkoutTypesRoute());
    registerFallbackValue(const SettingsRoute());
    registerFallbackValue(const ChangePasswordRoute());
  });

  group('ProfilePage', () {
    testWidgets('renders user card and section rows', (tester) async {
      final router = MockStackRouter();
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

      final cubit = _stubCubit(
        const AuthAuthenticatedState(
          user: AuthUser(
            uid: 'u1',
            email: 'alex@example.com',
            displayName: 'Alex',
            emailVerified: true,
          ),
        ),
        const Stream.empty(),
      );

      await tester.pumpWidget(_buildApp(cubit, router));

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('MANAGE'), findsOneWidget);
      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('Workout Types'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Sign Out'), findsOneWidget);
      expect(find.text('alex@example.com'), findsOneWidget);

      verify(() => cubit.watchAuthState()).called(1);
    });

    testWidgets('navigates to feature routes from row taps', (tester) async {
      final router = MockStackRouter();
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

      final cubit = _stubCubit(
        const AuthAuthenticatedState(
          user: AuthUser(
            uid: 'u1',
            email: 'alex@example.com',
            displayName: 'Alex',
            emailVerified: true,
          ),
        ),
        const Stream.empty(),
      );

      await tester.pumpWidget(_buildApp(cubit, router));

      await tester.tap(find.text('Workout Types'));
      await tester.pump();
      verify(
        () => router.push(
          const WorkoutTypesRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);

      await tester.tap(find.text('Settings'));
      await tester.pump();
      verify(
        () => router.push(
          const SettingsRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);

      await tester.tap(find.text('Change Password'));
      await tester.pump();
      verify(
        () => router.push(
          const ChangePasswordRoute(),
          onFailure: any(named: 'onFailure'),
        ),
      ).called(1);
    });

    testWidgets('calls signOut when sign-out row is tapped', (tester) async {
      final router = MockStackRouter();
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

      final cubit = _stubCubit(
        const AuthAuthenticatedState(
          user: AuthUser(
            uid: 'u1',
            email: 'alex@example.com',
            displayName: 'Alex',
            emailVerified: true,
          ),
        ),
        const Stream.empty(),
      );

      await tester.pumpWidget(_buildApp(cubit, router));
      await tester.tap(find.text('Sign Out'));
      await tester.pump();

      verify(() => cubit.signOut()).called(1);
    });

    testWidgets('redirects to login on unauthenticated state', (tester) async {
      final router = MockStackRouter();
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

      final cubit = _stubCubit(
        const AuthAuthenticatedState(
          user: AuthUser(
            uid: 'u1',
            email: 'alex@example.com',
            displayName: 'Alex',
            emailVerified: true,
          ),
        ),
        controller.stream,
      );

      await tester.pumpWidget(_buildApp(cubit, router));
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
