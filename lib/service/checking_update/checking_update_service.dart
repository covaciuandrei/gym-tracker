import 'package:gym_tracker/core/app_version_status.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Orchestrates the "big update available" prompt: reads the cached version
/// gate result from [AppVersionStatus], applies a per-version dismissal
/// cool-down stored in [SharedPreferences], and launches the store URL when
/// the user accepts.
///
/// Keeping this out of the page layer lets the main shell stay purely UI:
/// the cubit calls [shouldShowBigUpdate] / [rememberDismissal] /
/// [launchStoreUrl], and the widget only renders.
@injectable
class CheckingUpdateService {
  const CheckingUpdateService(this._versionStatus);

  final AppVersionStatus _versionStatus;

  /// SharedPreferences key holding the [AppVersionStatus.latestVersion] for
  /// which the user last tapped "Remind me later".
  static const String dismissedVersionPrefsKey = 'big_update_dismissed_version';

  /// SharedPreferences key storing the UTC epoch millis at which the user
  /// last dismissed the big-update bottom sheet for [dismissedVersionPrefsKey].
  static const String dismissedAtPrefsKey = 'big_update_dismissed_at_ms';

  /// How long a per-version "Remind me later" dismissal is honored before the
  /// bottom sheet becomes eligible to re-appear.
  static const Duration dismissalCoolDown = Duration(days: 3);

  /// Latest version string captured by the splash version gate.
  String get latestVersion => _versionStatus.latestVersion;

  /// Returns `true` iff the big-update bottom sheet should be presented now.
  ///
  /// Rules:
  ///   * splash must have flagged `bigUpdateAvailable`,
  ///   * `latestVersion` must be non-empty,
  ///   * either no dismissal exists, the dismissed version differs from the
  ///     current latest, or the 3-day cool-down has elapsed.
  Future<bool> shouldShowBigUpdate() async {
    if (!_versionStatus.bigUpdateAvailable || _versionStatus.latestVersion.isEmpty) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final dismissedVersion = prefs.getString(dismissedVersionPrefsKey);
    final dismissedAtMs = prefs.getInt(dismissedAtPrefsKey);

    if (dismissedVersion == _versionStatus.latestVersion && dismissedAtMs != null) {
      final dismissedAt = DateTime.fromMillisecondsSinceEpoch(dismissedAtMs);
      if (DateTime.now().difference(dismissedAt) < dismissalCoolDown) {
        return false;
      }
    }
    return true;
  }

  /// Persists the current [AppVersionStatus.latestVersion] + now() as the
  /// user's last "Remind me later" snooze.
  Future<void> rememberDismissal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dismissedVersionPrefsKey, _versionStatus.latestVersion);
    await prefs.setInt(dismissedAtPrefsKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Opens [AppVersionStatus.storeUrl] in an external browser / store app.
  /// No-op when the URL is empty or un-parseable.
  Future<void> launchStoreUrl() async {
    final url = _versionStatus.storeUrl;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
