// Widget tests for MainShellPage.
//
// AutoTabsScaffold requires a [RouterScope] (with a full RoutingController)
// to render its nested tab pages. That scope is NOT provided here because
// creating it requires a fully wired AppRouter with real route collection.
// Instead, the tests let the resulting FlutterError surface and consume it
// immediately with [WidgetTester.takeException].
//
// The two behaviors verified at the widget level:
//   1. watchAuthState() is called exactly once in initState.
//   2. The current route is replaced with LoginRoute on sign-out /
//      token-expiry events (ctx.router.replace — the stack is already
//      clean when entering the shell, so replaceAll is not needed).
//
// Both are verifiable without rendering the tab pages because:
//   • initState() runs before build() throws, so the cubit call is confirmed.
//   • BlocListener subscribes its stream in its own initState(), which also
//     fires before AutoTabsScaffold fails; the listener therefore keeps
//     processing stream events even when the tab area shows an ErrorWidget.
//
// Run: flutter test test/presentation/pages/main_shell/main_shell_page_test.dart

import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/cubit/auth/auth_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/checking_update/checking_update_cubit.dart';
import 'package:gym_tracker/presentation/pages/main_shell/main_shell_page.dart';
import 'package:mocktail/mocktail.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────

class MockAuthCubit extends Mock implements AuthCubit {}

class MockCheckingUpdateCubit extends Mock implements CheckingUpdateCubit {}

class MockStackRouter extends Mock implements StackRouter {}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Wraps [MainShellPage] in the minimum scaffolding needed for tests:
///   • [StackRouterScope] so that [ctx.router] resolves to [mockRouter].
///   • [MaterialApp] for theme / l10n delegates.
///   • [BlocProvider.value] for the injected cubits.
///
/// NOTE: [AutoTabsScaffold] additionally requires a [RouterScope] and cannot
/// render tab pages without a full [RootStackRouter]. The tests below consume
/// the resulting [FlutterError] via [WidgetTester.takeException].
Widget _buildApp(AuthCubit authCubit, {StackRouter? router, CheckingUpdateCubit? checkingUpdateCubit}) {
  final effectiveRouter = router ?? MockStackRouter();
  final effectiveCheckingUpdate = checkingUpdateCubit ?? _idleCheckingUpdateCubit();
  return StackRouterScope(
    controller: effectiveRouter,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>.value(value: authCubit),
          BlocProvider<CheckingUpdateCubit>.value(value: effectiveCheckingUpdate),
        ],
        child: const MainShellPage(),
      ),
    ),
  );
}

/// Idle [AuthCubit]: holds [InitialState] and emits nothing.
MockAuthCubit _idleCubit() {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(const InitialState());
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => cubit.watchAuthState()).thenReturn(null);
  return cubit;
}

/// Idle [CheckingUpdateCubit]: never emits a show-sheet state so the test
/// path stays focused on auth behavior.
MockCheckingUpdateCubit _idleCheckingUpdateCubit() {
  final cubit = MockCheckingUpdateCubit();
  when(() => cubit.state).thenReturn(const InitialState());
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => cubit.evaluate()).thenAnswer((_) async {});
  return cubit;
}

/// [AuthCubit] backed by a [StreamController] so tests can push states on demand.
MockAuthCubit _streamCubit(Stream<BaseState> stream) {
  final cubit = MockAuthCubit();
  when(() => cubit.state).thenReturn(const InitialState());
  when(() => cubit.stream).thenAnswer((_) => stream);
  when(() => cubit.watchAuthState()).thenReturn(null);
  return cubit;
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(const LoginRoute());
  });

  // ── initState ─────────────────────────────────────────────────────────────

  group('MainShellPage — init', () {
    testWidgets('calls watchAuthState once when the page is mounted', (tester) async {
      final cubit = _idleCubit();

      await tester.pumpWidget(_buildApp(cubit));
      // AutoTabsScaffold throws without RouterScope; consume the error so the
      // verify below is not shadowed. watchAuthState() fires in initState(),
      // which runs before AutoTabsRouter attempts its router look-up.
      tester.takeException();

      verify(() => cubit.watchAuthState()).called(1);
    });

    testWidgets('calls CheckingUpdateCubit.evaluate() on the first post-frame', (tester) async {
      final auth = _idleCubit();
      final checkingUpdate = _idleCheckingUpdateCubit();

      await tester.pumpWidget(_buildApp(auth, checkingUpdateCubit: checkingUpdate));
      tester.takeException();
      // Post-frame callback runs on the next pump.
      await tester.pump();

      verify(() => checkingUpdate.evaluate()).called(1);
    });
  });

  // ── sign-out / session-expiry navigation ──────────────────────────────────

  group('MainShellPage — sign-out navigation', () {
    late MockStackRouter mockRouter;
    late StreamController<BaseState> streamController;

    setUp(() {
      mockRouter = MockStackRouter();
      when(() => mockRouter.replace(any<PageRouteInfo>())).thenAnswer((_) async {
        return null;
      });
      // Use a synchronous broadcast stream so that add() delivers the event
      // inline — before the next pump can trigger another AutoTabsRouter rebuild
      // attempt that would deactivate the BlocListener's element.
      streamController = StreamController<BaseState>.broadcast(sync: true);
    });

    tearDown(() async {
      await streamController.close();
    });

    testWidgets('replaces navigation stack with LoginRoute on AuthSignOutSuccessState', (tester) async {
      final cubit = _streamCubit(streamController.stream);

      await tester.pumpWidget(_buildApp(cubit, router: mockRouter));
      tester.takeException();

      // Sync broadcast: listener fires inline, BlocListener still mounted.
      streamController.add(const AuthSignOutSuccessState());

      verify(() => mockRouter.replace(const LoginRoute())).called(1);
    });

    testWidgets('replaces navigation stack with LoginRoute on AuthUnauthenticatedState', (tester) async {
      final cubit = _streamCubit(streamController.stream);

      await tester.pumpWidget(_buildApp(cubit, router: mockRouter));
      tester.takeException();

      streamController.add(const AuthUnauthenticatedState());

      verify(() => mockRouter.replace(const LoginRoute())).called(1);
    });

    testWidgets('does NOT replace stack on unrelated state changes', (tester) async {
      final cubit = _streamCubit(streamController.stream);

      await tester.pumpWidget(_buildApp(cubit, router: mockRouter));
      tester.takeException();

      streamController.add(const PendingState());

      verifyNever(() => mockRouter.replace(any<PageRouteInfo>()));
    });
  });
}
