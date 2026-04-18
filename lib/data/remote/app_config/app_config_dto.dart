import 'package:json_annotation/json_annotation.dart';

part 'app_config_dto.g.dart';

@JsonSerializable()
class AppConfigDto {
  AppConfigDto({
    required this.minRequiredVersion,
    required this.latestVersion,
    required this.maintenanceMode,
    required this.maintenanceMessages,
    required this.androidStoreUrl,
    required this.iosStoreUrl,
    required this.termsUrls,
    required this.privacyUrls,
  });

  factory AppConfigDto.fromJson(Map<String, dynamic> json) => _$AppConfigDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AppConfigDtoToJson(this);

  @JsonKey(name: 'minRequiredVersion', defaultValue: '0.0.0')
  final String minRequiredVersion;

  @JsonKey(name: 'latestVersion', defaultValue: '0.0.0')
  final String latestVersion;

  @JsonKey(name: 'maintenanceMode', defaultValue: false)
  final bool maintenanceMode;

  @JsonKey(name: 'maintenanceMessages', defaultValue: <String, String>{})
  final Map<String, String> maintenanceMessages;

  @JsonKey(name: 'androidStoreUrl', defaultValue: '')
  final String androidStoreUrl;

  @JsonKey(name: 'iosStoreUrl', defaultValue: '')
  final String iosStoreUrl;

  /// Localized Terms of Service URLs keyed by language code (e.g. 'en', 'ro').
  /// When missing or empty, the app falls back to hardcoded constants in
  /// `lib/core/constants/legal_urls.dart`.
  @JsonKey(name: 'termsUrls', defaultValue: <String, String>{})
  final Map<String, String> termsUrls;

  /// Localized Privacy Policy URLs keyed by language code (e.g. 'en', 'ro').
  /// Same fallback behaviour as [termsUrls].
  @JsonKey(name: 'privacyUrls', defaultValue: <String, String>{})
  final Map<String, String> privacyUrls;
}
