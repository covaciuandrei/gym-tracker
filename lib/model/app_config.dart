import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  const AppConfig({
    required this.minRequiredVersion,
    required this.latestVersion,
    required this.maintenanceMode,
    required this.maintenanceMessages,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    this.termsUrls = const <String, String>{},
    this.privacyUrls = const <String, String>{},
    this.termsVersion = '',
    this.privacyVersion = '',
  });

  /// Lowest version still allowed to run. Below this = hard block.
  final String minRequiredVersion;

  /// Newest released version. Current app below this = soft banner.
  final String latestVersion;

  /// When true, the whole app is replaced by a maintenance screen.
  final bool maintenanceMode;

  /// Localized maintenance messages keyed by language code (e.g. 'en', 'ro').
  final Map<String, String> maintenanceMessages;

  final String androidStoreUrl;
  final String iosStoreUrl;

  /// Localized Terms of Service URLs keyed by language code. May be empty if
  /// remote config has not been populated; callers should fall back to
  /// hardcoded defaults in `lib/core/constants/legal_urls.dart`.
  final Map<String, String> termsUrls;

  /// Localized Privacy Policy URLs keyed by language code. Same fallback
  /// behaviour as [termsUrls].
  final Map<String, String> privacyUrls;

  /// Revision id of the currently-published Terms of Service (free-form
  /// string such as a date or semver). Persisted with the user's consent
  /// record so we can prove which text was accepted.
  final String termsVersion;

  /// Revision id of the currently-published Privacy Policy. Same semantics
  /// as [termsVersion].
  final String privacyVersion;

  /// Returns the maintenance message for [languageCode], falling back to 'en'
  /// and finally to an empty string.
  String messageFor(String languageCode) => maintenanceMessages[languageCode] ?? maintenanceMessages['en'] ?? '';

  @override
  List<Object?> get props => [
    minRequiredVersion,
    latestVersion,
    maintenanceMode,
    maintenanceMessages,
    androidStoreUrl,
    iosStoreUrl,
    termsUrls,
    privacyUrls,
    termsVersion,
    privacyVersion,
  ];
}
