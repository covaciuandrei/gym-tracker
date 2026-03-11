// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplement_log_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementLogDto _$SupplementLogDtoFromJson(Map<String, dynamic> json) =>
    SupplementLogDto(
      date: json['date'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      servingsTaken: (json['servings_taken'] as num?)?.toDouble() ?? 1.0,
      productName: json['product_name'] as String?,
      productBrand: json['product_brand'] as String?,
      timestamp: json['timestamp'],
    );

Map<String, dynamic> _$SupplementLogDtoToJson(SupplementLogDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'product_id': instance.productId,
      'product_name': instance.productName,
      'product_brand': instance.productBrand,
      'servings_taken': instance.servingsTaken,
      'timestamp': instance.timestamp,
    };
