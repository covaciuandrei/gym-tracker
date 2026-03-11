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
    AutoRoute(path: '/splash', page: SplashRoute.page, initial: true),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
    AutoRoute(path: '/auth/action', page: AuthActionRoute.page),
    AutoRoute(
      path: '/',
      page: MainShellRoute.page,
      children: [
        AutoRoute(path: 'calendar', page: CalendarRoute.page),
        AutoRoute(path: 'stats', page: StatsRoute.page),
        AutoRoute(path: 'health', page: HealthRoute.page),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
        RedirectRoute(path: '', redirectTo: 'calendar'),
      ],
    ),
    AutoRoute(path: '/workout-types', page: WorkoutTypesRoute.page),
    AutoRoute(path: '/settings', page: SettingsRoute.page),
  ];
}
