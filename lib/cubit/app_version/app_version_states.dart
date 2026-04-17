part of 'app_version_cubit.dart';

/// Emitted when the app version is acceptable (≥ min required).
/// [softUpdateAvailable] is true when a newer [latestVersion] exists.
class AppVersionOkState extends BaseState {
  const AppVersionOkState({
    required this.currentVersion,
    required this.latestVersion,
    required this.softUpdateAvailable,
    required this.storeUrl,
  });

  final String currentVersion;
  final String latestVersion;
  final bool softUpdateAvailable;
  final String storeUrl;

  @override
  List<Object?> get props => [currentVersion, latestVersion, softUpdateAvailable, storeUrl];
}

/// Emitted when the installed version is below the min required version.
/// The app must navigate to the force-update screen.
class AppVersionForceUpdateState extends BaseState {
  const AppVersionForceUpdateState({
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

/// Emitted when maintenance mode is toggled on in the remote config.
class AppVersionMaintenanceState extends BaseState {
  const AppVersionMaintenanceState({required this.config});

  final AppConfig config;

  @override
  List<Object?> get props => [config];
}

/// Emitted when the remote config cannot be fetched. Because offline mode is
/// not supported, the app must navigate to the no-connection screen.
class AppVersionNetworkErrorState extends BaseState {
  const AppVersionNetworkErrorState();
}
