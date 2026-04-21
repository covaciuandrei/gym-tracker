/// Hardcoded fallback URLs for the hosted Terms of Service and Privacy Policy.
///
/// These constants are used when the corresponding maps in the Firestore
/// `appConfig/version` document are missing or empty. Keeping a local
/// fallback ensures the in-app "Terms" and "Privacy" links always resolve to
/// a working URL even if remote config has not been populated.
///
/// The canonical URLs point at the Firebase Hosting deployment of the
/// `legal/` folder in this repository.
library;

/// Base URL of the Firebase Hosting site that serves the legal pages.
const String legalHostingBaseUrl = 'https://gym-presence-tracker-16edc.web.app';

const String legalTermsUrlEn = '$legalHostingBaseUrl/terms?lang=en';
const String legalTermsUrlRo = '$legalHostingBaseUrl/terms?lang=ro';

const String legalPrivacyUrlEn = '$legalHostingBaseUrl/privacy?lang=en';
const String legalPrivacyUrlRo = '$legalHostingBaseUrl/privacy?lang=ro';

/// Fallback map used when `appConfig/version.termsUrls` is missing.
const Map<String, String> legalTermsFallbackUrls = {'en': legalTermsUrlEn, 'ro': legalTermsUrlRo};

/// Fallback map used when `appConfig/version.privacyUrls` is missing.
const Map<String, String> legalPrivacyFallbackUrls = {'en': legalPrivacyUrlEn, 'ro': legalPrivacyUrlRo};

/// Resolves a URL from a [languageMap] for [languageCode], falling back to
/// the English entry and finally to [fallback] if both are missing.
String resolveLegalUrl({
  required Map<String, String> languageMap,
  required String languageCode,
  required String fallback,
}) {
  final value = languageMap[languageCode];
  if (value != null && value.isNotEmpty) return value;
  final en = languageMap['en'];
  if (en != null && en.isNotEmpty) return en;
  return fallback;
}
