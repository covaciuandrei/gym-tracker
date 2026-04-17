part of 'splash_cubit.dart';

/// Maintenance mode is active — show the maintenance screen with a localized
/// message.
class SplashNavigateMaintenanceState extends BaseState {
  const SplashNavigateMaintenanceState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Installed version is below the minimum required — show the force-update
/// screen.
class SplashNavigateForceUpdateState extends BaseState {
  const SplashNavigateForceUpdateState({
    required this.currentVersion,
    required this.requiredVersion,
    required this.storeUrl,
  });

  final String currentVersion;
  final String requiredVersion;
  final String storeUrl;

  @override
  List<Object?> get props => [currentVersion, requiredVersion, storeUrl];
}

/// Remote config could not be fetched — show the no-connection screen.
class SplashNavigateNoConnectionState extends BaseState {
  const SplashNavigateNoConnectionState();
}

/// Version gate passed and this is the first launch — show onboarding.
class SplashNavigateOnboardingState extends BaseState {
  const SplashNavigateOnboardingState();
}

/// Version gate passed and the user is already signed in — enter the main
/// shell.
class SplashNavigateMainShellState extends BaseState {
  const SplashNavigateMainShellState();
}

/// Version gate passed but the user is signed out — go to login.
class SplashNavigateLoginState extends BaseState {
  const SplashNavigateLoginState();
}
