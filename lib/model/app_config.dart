import 'package:equatable/equatable.dart';

class AppConfig extends Equatable {
  const AppConfig({
    required this.minRequiredVersion,
    required this.latestVersion,
    required this.maintenanceMode,
    required this.maintenanceMessages,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
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
  ];
}
