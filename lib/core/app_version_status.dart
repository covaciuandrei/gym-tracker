import 'package:gym_tracker/core/constants/legal_urls.dart';
import 'package:injectable/injectable.dart';

/// In-memory snapshot of the remote-config version gate result, captured by
/// [SplashPage] after a successful version check and later read by
/// [MainShellPage] to decide whether to surface the "big update available"
/// bottom sheet.
///
/// This is a plain singleton (not a cubit) because the data is written once
/// per cold-launch and consumed by a handful of widgets; no stream/emit is
/// required.
@lazySingleton
class AppVersionStatus {
  AppVersionStatus();

  /// True when the latest released version represents a big jump from the
  /// installed version (major bump or minor bump of 2+).
  ///
  /// Patch bumps and single-step minor bumps are considered small and leave
  /// this flag `false` — small updates have no in-app prompt.
  bool bigUpdateAvailable = false;

  /// The latest version advertised by remote config. Used for display in the
  /// update bottom sheet and as the key for persisted dismissals.
  String latestVersion = '';

  /// Store URL resolved for the current platform. Consumed directly by the
  /// bottom sheet's Update action.
  String storeUrl = '';

  /// Localized Terms of Service URLs captured from remote config. Empty until
  /// the splash flow populates them. Readers should go through [termsUrlFor]
  /// which transparently falls back to hardcoded constants when empty.
  Map<String, String> termsUrls = const <String, String>{};

  /// Localized Privacy Policy URLs — same semantics as [termsUrls].
  Map<String, String> privacyUrls = const <String, String>{};

  /// Records the result of a successful version check so it can be read
  /// later by the main shell's big-update bottom sheet.
  void getAppVersionDetails({
    required bool bigUpdateAvailable,
    required String latestVersion,
    required String storeUrl,
  }) {
    this.bigUpdateAvailable = bigUpdateAvailable;
    this.latestVersion = latestVersion;
    this.storeUrl = storeUrl;
  }

  /// Stores the localized legal URL maps captured from remote config. Called
  /// once per cold launch on the ok (non-maintenance / non-force-update)
  /// path.
  void setLegalUrls({required Map<String, String> termsUrls, required Map<String, String> privacyUrls}) {
    this.termsUrls = termsUrls;
    this.privacyUrls = privacyUrls;
  }

  /// Returns the Terms of Service URL for [languageCode], falling back to the
  /// English entry and finally to the hardcoded constant defined in
  /// [legalTermsUrlEn] / [legalTermsUrlRo].
  String termsUrlFor(String languageCode) => resolveLegalUrl(
    languageMap: termsUrls,
    languageCode: languageCode,
    fallback: legalTermsFallbackUrls[languageCode] ?? legalTermsUrlEn,
  );

  /// Returns the Privacy Policy URL for [languageCode]. Same fallback
  /// behaviour as [termsUrlFor].
  String privacyUrlFor(String languageCode) => resolveLegalUrl(
    languageMap: privacyUrls,
    languageCode: languageCode,
    fallback: legalPrivacyFallbackUrls[languageCode] ?? legalPrivacyUrlEn,
  );
}
