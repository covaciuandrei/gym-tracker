// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i17;
import 'package:flutter/material.dart' as _i18;
import 'package:gym_tracker/presentation/pages/auth/forgot_password_page.dart'
    as _i4;
import 'package:gym_tracker/presentation/pages/auth/login_page.dart' as _i6;
import 'package:gym_tracker/presentation/pages/auth/register_page.dart' as _i12;
import 'package:gym_tracker/presentation/pages/calendar/calendar_page.dart'
    as _i1;
import 'package:gym_tracker/presentation/pages/change_password/change_password_page.dart'
    as _i2;
import 'package:gym_tracker/presentation/pages/force_update/force_update_page.dart'
    as _i3;
import 'package:gym_tracker/presentation/pages/health/health_page.dart' as _i5;
import 'package:gym_tracker/presentation/pages/main_shell/main_shell_page.dart'
    as _i7;
import 'package:gym_tracker/presentation/pages/maintenance/maintenance_page.dart'
    as _i8;
import 'package:gym_tracker/presentation/pages/no_connection/no_connection_page.dart'
    as _i9;
import 'package:gym_tracker/presentation/pages/onboarding/onboarding_page.dart'
    as _i10;
import 'package:gym_tracker/presentation/pages/profile/profile_page.dart'
    as _i11;
import 'package:gym_tracker/presentation/pages/settings/settings_page.dart'
    as _i13;
import 'package:gym_tracker/presentation/pages/splash/splash_page.dart' as _i14;
import 'package:gym_tracker/presentation/pages/stats/stats_page.dart' as _i15;
import 'package:gym_tracker/presentation/pages/workout_types/workout_types_page.dart'
    as _i16;

/// generated route for
/// [_i1.CalendarPage]
class CalendarRoute extends _i17.PageRouteInfo<void> {
  const CalendarRoute({List<_i17.PageRouteInfo>? children})
    : super(CalendarRoute.name, initialChildren: children);

  static const String name = 'CalendarRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i1.CalendarPage());
    },
  );
}

/// generated route for
/// [_i2.ChangePasswordPage]
class ChangePasswordRoute extends _i17.PageRouteInfo<void> {
  const ChangePasswordRoute({List<_i17.PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i2.ChangePasswordPage());
    },
  );
}

/// generated route for
/// [_i3.ForceUpdatePage]
class ForceUpdateRoute extends _i17.PageRouteInfo<ForceUpdateRouteArgs> {
  ForceUpdateRoute({
    _i18.Key? key,
    required String currentVersion,
    required String requiredVersion,
    required String androidStoreUrl,
    required String iosStoreUrl,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         ForceUpdateRoute.name,
         args: ForceUpdateRouteArgs(
           key: key,
           currentVersion: currentVersion,
           requiredVersion: requiredVersion,
           androidStoreUrl: androidStoreUrl,
           iosStoreUrl: iosStoreUrl,
         ),
         initialChildren: children,
       );

  static const String name = 'ForceUpdateRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ForceUpdateRouteArgs>();
      return _i3.ForceUpdatePage(
        key: args.key,
        currentVersion: args.currentVersion,
        requiredVersion: args.requiredVersion,
        androidStoreUrl: args.androidStoreUrl,
        iosStoreUrl: args.iosStoreUrl,
      );
    },
  );
}

class ForceUpdateRouteArgs {
  const ForceUpdateRouteArgs({
    this.key,
    required this.currentVersion,
    required this.requiredVersion,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
  });

  final _i18.Key? key;

  final String currentVersion;

  final String requiredVersion;

  final String androidStoreUrl;

  final String iosStoreUrl;

  @override
  String toString() {
    return 'ForceUpdateRouteArgs{key: $key, currentVersion: $currentVersion, requiredVersion: $requiredVersion, androidStoreUrl: $androidStoreUrl, iosStoreUrl: $iosStoreUrl}';
  }
}

/// generated route for
/// [_i4.ForgotPasswordPage]
class ForgotPasswordRoute extends _i17.PageRouteInfo<void> {
  const ForgotPasswordRoute({List<_i17.PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i4.ForgotPasswordPage());
    },
  );
}

/// generated route for
/// [_i5.HealthPage]
class HealthRoute extends _i17.PageRouteInfo<HealthRouteArgs> {
  HealthRoute({
    _i18.Key? key,
    String? testUserId,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         HealthRoute.name,
         args: HealthRouteArgs(key: key, testUserId: testUserId),
         initialChildren: children,
       );

  static const String name = 'HealthRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<HealthRouteArgs>(
        orElse: () => const HealthRouteArgs(),
      );
      return _i17.WrappedRoute(
        child: _i5.HealthPage(key: args.key, testUserId: args.testUserId),
      );
    },
  );
}

class HealthRouteArgs {
  const HealthRouteArgs({this.key, this.testUserId});

  final _i18.Key? key;

  final String? testUserId;

  @override
  String toString() {
    return 'HealthRouteArgs{key: $key, testUserId: $testUserId}';
  }
}

/// generated route for
/// [_i6.LoginPage]
class LoginRoute extends _i17.PageRouteInfo<void> {
  const LoginRoute({List<_i17.PageRouteInfo>? children})
    : super(LoginRoute.name, initialChildren: children);

  static const String name = 'LoginRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i6.LoginPage());
    },
  );
}

/// generated route for
/// [_i7.MainShellPage]
class MainShellRoute extends _i17.PageRouteInfo<void> {
  const MainShellRoute({List<_i17.PageRouteInfo>? children})
    : super(MainShellRoute.name, initialChildren: children);

  static const String name = 'MainShellRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i7.MainShellPage());
    },
  );
}

/// generated route for
/// [_i8.MaintenancePage]
class MaintenanceRoute extends _i17.PageRouteInfo<MaintenanceRouteArgs> {
  MaintenanceRoute({
    _i18.Key? key,
    required String message,
    List<_i17.PageRouteInfo>? children,
  }) : super(
         MaintenanceRoute.name,
         args: MaintenanceRouteArgs(key: key, message: message),
         initialChildren: children,
       );

  static const String name = 'MaintenanceRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<MaintenanceRouteArgs>();
      return _i8.MaintenancePage(key: args.key, message: args.message);
    },
  );
}

class MaintenanceRouteArgs {
  const MaintenanceRouteArgs({this.key, required this.message});

  final _i18.Key? key;

  final String message;

  @override
  String toString() {
    return 'MaintenanceRouteArgs{key: $key, message: $message}';
  }
}

/// generated route for
/// [_i9.NoConnectionPage]
class NoConnectionRoute extends _i17.PageRouteInfo<void> {
  const NoConnectionRoute({List<_i17.PageRouteInfo>? children})
    : super(NoConnectionRoute.name, initialChildren: children);

  static const String name = 'NoConnectionRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i9.NoConnectionPage();
    },
  );
}

/// generated route for
/// [_i10.OnboardingPage]
class OnboardingRoute extends _i17.PageRouteInfo<void> {
  const OnboardingRoute({List<_i17.PageRouteInfo>? children})
    : super(OnboardingRoute.name, initialChildren: children);

  static const String name = 'OnboardingRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i10.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i11.ProfilePage]
class ProfileRoute extends _i17.PageRouteInfo<void> {
  const ProfileRoute({List<_i17.PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i11.ProfilePage());
    },
  );
}

/// generated route for
/// [_i12.RegisterPage]
class RegisterRoute extends _i17.PageRouteInfo<void> {
  const RegisterRoute({List<_i17.PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i12.RegisterPage());
    },
  );
}

/// generated route for
/// [_i13.SettingsPage]
class SettingsRoute extends _i17.PageRouteInfo<void> {
  const SettingsRoute({List<_i17.PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i13.SettingsPage());
    },
  );
}

/// generated route for
/// [_i14.SplashPage]
class SplashRoute extends _i17.PageRouteInfo<void> {
  const SplashRoute({List<_i17.PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return const _i14.SplashPage();
    },
  );
}

/// generated route for
/// [_i15.StatsPage]
class StatsRoute extends _i17.PageRouteInfo<void> {
  const StatsRoute({List<_i17.PageRouteInfo>? children})
    : super(StatsRoute.name, initialChildren: children);

  static const String name = 'StatsRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i15.StatsPage());
    },
  );
}

/// generated route for
/// [_i16.WorkoutTypesPage]
class WorkoutTypesRoute extends _i17.PageRouteInfo<void> {
  const WorkoutTypesRoute({List<_i17.PageRouteInfo>? children})
    : super(WorkoutTypesRoute.name, initialChildren: children);

  static const String name = 'WorkoutTypesRoute';

  static _i17.PageInfo page = _i17.PageInfo(
    name,
    builder: (data) {
      return _i17.WrappedRoute(child: const _i16.WorkoutTypesPage());
    },
  );
}
