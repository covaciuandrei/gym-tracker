import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';

import 'app_router.gr.dart';
import 'guards/auth_guard.dart';
import 'guards/onboarding_guard.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = <AutoRoute>[
    AutoRoute(path: '/', page: SplashRoute.page, initial: true),
    AutoRoute(path: '/onboarding', page: OnboardingRoute.page),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
    AutoRoute(
      path: '/app',
      page: MainShellRoute.page,
      guards: [AuthGuard(), OnboardingGuard()],
      children: [
        AutoRoute(path: 'calendar', page: CalendarRoute.page),
        AutoRoute(path: 'workouts', page: WorkoutsRoute.page),
        AutoRoute(path: 'stats', page: StatsRoute.page, maintainState: false),
        AutoRoute(path: 'health', page: HealthRoute.page, maintainState: false),
        AutoRoute(path: 'profile', page: ProfileRoute.page),
        RedirectRoute(path: '', redirectTo: 'calendar'),
      ],
    ),
    AutoRoute(
      path: '/workout-types',
      page: WorkoutTypesRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/settings',
      page: SettingsRoute.page,
      maintainState: false,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/change-password',
      page: ChangePasswordRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/membership-history',
      page: MembershipHistoryRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/health-insights',
      page: HealthInsightsRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/health-insights/timeline',
      page: MetricTimelineRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/health-insights/compare',
      page: TwoColumnComparisonRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(
      path: '/health-insights/overview',
      page: PhysicalOverviewDetailRoute.page,
      guards: [AuthGuard()],
    ),
    AutoRoute(path: '/force-update', page: ForceUpdateRoute.page),
    AutoRoute(path: '/maintenance', page: MaintenanceRoute.page),
    AutoRoute(path: '/no-connection', page: NoConnectionRoute.page),
  ];
}
