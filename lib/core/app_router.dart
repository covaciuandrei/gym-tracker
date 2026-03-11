import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = <AutoRoute>[
    // ── Splash ───────────────────────────────────────────────────────────
    AutoRoute(
      path: '/splash',
      page: SplashRoute.page,
      initial: true,
      maintainState: false,
    ),

    // ── Auth (public — no bottom nav) ─────────────────────────────────────
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
    AutoRoute(path: '/auth/action', page: AuthActionRoute.page),

    // ── Main shell with bottom navigation ────────────────────────────────
    AutoRoute(
      path: '/',
      page: MainShellRoute.page,
      children: [
        AutoRoute(path: 'calendar', page: CalendarRoute.page),
        AutoRoute(path: 'stats', page: StatsRoute.page),
        AutoRoute(path: 'health', page: HealthRoute.page),
        AutoRoute(
          path: 'profile',
          page: ProfileRoute.page,
        ),
        // Default tab redirect
        RedirectRoute(path: '', redirectTo: 'calendar'),
      ],
    ),

    // ── Profile sub-screens ───────────────────────────────────────────────
    AutoRoute(path: '/workout-types', page: WorkoutTypesRoute.page),
    AutoRoute(path: '/settings', page: SettingsRoute.page),
  ];
}
