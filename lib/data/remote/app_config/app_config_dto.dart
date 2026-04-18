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
    required this.termsVersion,
    required this.privacyVersion,
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

  /// Revision id of the currently-published Terms of Service (free-form
  /// string, e.g. a date like '2026-04-18' or a semver). Persisted with the
  /// user's consent record so we can prove which text was accepted.
  @JsonKey(name: 'termsVersion', defaultValue: '')
  final String termsVersion;

  /// Revision id of the currently-published Privacy Policy. Same semantics
  /// as [termsVersion].
  @JsonKey(name: 'privacyVersion', defaultValue: '')
  final String privacyVersion;
}
