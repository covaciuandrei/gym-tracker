// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppConfigDto _$AppConfigDtoFromJson(Map<String, dynamic> json) => AppConfigDto(
  minRequiredVersion: json['minRequiredVersion'] as String? ?? '0.0.0',
  latestVersion: json['latestVersion'] as String? ?? '0.0.0',
  maintenanceMode: json['maintenanceMode'] as bool? ?? false,
  maintenanceMessages:
      (json['maintenanceMessages'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  androidStoreUrl: json['androidStoreUrl'] as String? ?? '',
  iosStoreUrl: json['iosStoreUrl'] as String? ?? '',
  termsUrls:
      (json['termsUrls'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  privacyUrls:
      (json['privacyUrls'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  termsVersion: json['termsVersion'] as String? ?? '',
  privacyVersion: json['privacyVersion'] as String? ?? '',
);

Map<String, dynamic> _$AppConfigDtoToJson(AppConfigDto instance) =>
    <String, dynamic>{
      'minRequiredVersion': instance.minRequiredVersion,
      'latestVersion': instance.latestVersion,
      'maintenanceMode': instance.maintenanceMode,
      'maintenanceMessages': instance.maintenanceMessages,
      'androidStoreUrl': instance.androidStoreUrl,
      'iosStoreUrl': instance.iosStoreUrl,
      'termsUrls': instance.termsUrls,
      'privacyUrls': instance.privacyUrls,
      'termsVersion': instance.termsVersion,
      'privacyVersion': instance.privacyVersion,
    };
