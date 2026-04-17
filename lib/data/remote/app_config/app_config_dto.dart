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
}
