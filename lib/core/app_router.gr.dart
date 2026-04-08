// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i14;
import 'package:flutter/material.dart' as _i15;
import 'package:gym_tracker/presentation/pages/auth/forgot_password_page.dart'
    as _i3;
import 'package:gym_tracker/presentation/pages/auth/login_page.dart' as _i5;
import 'package:gym_tracker/presentation/pages/auth/register_page.dart' as _i9;
import 'package:gym_tracker/presentation/pages/calendar/calendar_page.dart'
    as _i1;
import 'package:gym_tracker/presentation/pages/change_password/change_password_page.dart'
    as _i2;
import 'package:gym_tracker/presentation/pages/health/health_page.dart' as _i4;
import 'package:gym_tracker/presentation/pages/main_shell/main_shell_page.dart'
    as _i6;
import 'package:gym_tracker/presentation/pages/onboarding/onboarding_page.dart'
    as _i7;
import 'package:gym_tracker/presentation/pages/profile/profile_page.dart'
    as _i8;
import 'package:gym_tracker/presentation/pages/settings/settings_page.dart'
    as _i10;
import 'package:gym_tracker/presentation/pages/splash/splash_page.dart' as _i11;
import 'package:gym_tracker/presentation/pages/stats/stats_page.dart' as _i12;
import 'package:gym_tracker/presentation/pages/workout_types/workout_types_page.dart'
    as _i13;

/// generated route for
/// [_i1.CalendarPage]
class CalendarRoute extends _i14.PageRouteInfo<void> {
  const CalendarRoute({List<_i14.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i1.CalendarPage());
    },
  );
}

/// generated route for
/// [_i2.ChangePasswordPage]
class ChangePasswordRoute extends _i14.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i14.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i2.ChangePasswordPage());
    },
  );
}

/// generated route for
/// [_i3.ForgotPasswordPage]
class ForgotPasswordRoute extends _i14.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i14.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i3.ForgotPasswordPage());
    },
  );
}

/// generated route for
/// [_i4.HealthPage]
class HealthRoute extends _i14.PageRouteInfo<HealthRouteArgs> {
  HealthRoute({
    _i15.Key? key,
    String? testUserId,
    List<_i14.PageRouteInfo>? children,
  }) : super(
         HealthRoute.name,
         args: HealthRouteArgs(key: key, testUserId: testUserId),
         initialChildren: children,
       );

  static const String name = 'HealthRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HealthRouteArgs>(
        orElse: () => const HealthRouteArgs(),
      );
      return _i14.WrappedRoute(
        child: _i4.HealthPage(key: args.key, testUserId: args.testUserId),
      );
    },
  );
}

class HealthRouteArgs {
  const HealthRouteArgs({this.key, this.testUserId});

  final _i15.Key? key;

  final String? testUserId;

  @override
  String toString() {
    return 'HealthRouteArgs{key: $key, testUserId: $testUserId}';
  }
}

/// generated route for
/// [_i5.LoginPage]
class LoginRoute extends _i14.PageRouteInfo<void> {
  const LoginRoute({List<_i14.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i5.LoginPage());
    },
  );
}

/// generated route for
/// [_i6.MainShellPage]
class MainShellRoute extends _i14.PageRouteInfo<void> {
  const MainShellRoute({List<_i14.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i6.MainShellPage());
    },
  );
}

/// generated route for
/// [_i7.OnboardingPage]
class OnboardingRoute extends _i14.PageRouteInfo<void> {
  const OnboardingRoute({List<_i14.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i7.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i8.ProfilePage]
class ProfileRoute extends _i14.PageRouteInfo<void> {
  const ProfileRoute({List<_i14.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i8.ProfilePage());
    },
  );
}

/// generated route for
/// [_i9.RegisterPage]
class RegisterRoute extends _i14.PageRouteInfo<void> {
  const RegisterRoute({List<_i14.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i9.RegisterPage());
    },
  );
}

/// generated route for
/// [_i10.SettingsPage]
class SettingsRoute extends _i14.PageRouteInfo<void> {
  const SettingsRoute({List<_i14.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i10.SettingsPage());
    },
  );
}

/// generated route for
/// [_i11.SplashPage]
class SplashRoute extends _i14.PageRouteInfo<void> {
  const SplashRoute({List<_i14.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return const _i11.SplashPage();
    },
  );
}

/// generated route for
/// [_i12.StatsPage]
class StatsRoute extends _i14.PageRouteInfo<void> {
  const StatsRoute({List<_i14.PageRouteInfo>? children})
    : super(StatsRoute.name, initialChildren: children);

  static const String name = 'StatsRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i12.StatsPage());
    },
  );
}

/// generated route for
/// [_i13.WorkoutTypesPage]
class WorkoutTypesRoute extends _i14.PageRouteInfo<void> {
  const WorkoutTypesRoute({List<_i14.PageRouteInfo>? children})
    : super(WorkoutTypesRoute.name, initialChildren: children);

  static const String name = 'WorkoutTypesRoute';

  static _i14.PageInfo page = _i14.PageInfo(
    name,
    builder: (data) {
      return _i14.WrappedRoute(child: const _i13.WorkoutTypesPage());
    },
  );
}
