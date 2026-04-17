part of 'app_config_service.dart';

/// Thrown when the `appConfig/version` document is missing from Firestore.
class AppConfigMissingException implements Exception {
  const AppConfigMissingException();
}
