import 'package:injectable/injectable.dart';

/// In-memory snapshot of the remote-config version gate result, captured by
/// [SplashPage] after a successful version check and later read by
/// [MainShellPage] to render the soft-update banner.
///
/// This is a plain singleton (not a cubit) because the data is written once
/// per cold-launch and consumed by a handful of widgets; no stream/emit is
/// required.
@lazySingleton
class AppVersionStatus {
  AppVersionStatus();

  /// True when [latestVersion] is newer than the installed app version.
  bool softUpdateAvailable = false;

  /// The latest version advertised by remote config. Used for display in the
  /// banner and as the key for persisted dismissals.
  String latestVersion = '';

  /// Store URL resolved for the current platform. Consumed directly by the
  /// banner's Update action.
  String storeUrl = '';

  /// Records the result of a successful version check so it can be read
  /// later by the main shell's soft-update banner.
  void getAppVersionDetails({
    required bool softUpdateAvailable,
    required String latestVersion,
    required String storeUrl,
  }) {
    this.softUpdateAvailable = softUpdateAvailable;
    this.latestVersion = latestVersion;
    this.storeUrl = storeUrl;
  }
}
