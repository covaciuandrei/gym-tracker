// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supplement_product_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SupplementProductDto _$SupplementProductDtoFromJson(
  Map<String, dynamic> json,
) => SupplementProductDto(
  name: json['name'] as String? ?? '',
  brand: json['brand'] as String? ?? '',
  ingredients:
      (json['ingredients'] as List<dynamic>?)
          ?.map((e) => ProductIngredientDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  servingsPerDayDefault:
      (json['servings_per_day_default'] as num?)?.toDouble() ?? 1.0,
  createdBy: json['created_by'] as String?,
  verified: json['verified'] as bool?,
);

Map<String, dynamic> _$SupplementProductDtoToJson(
  SupplementProductDto instance,
) => <String, dynamic>{
  'name': instance.name,
  'brand': instance.brand,
  'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
  'servings_per_day_default': instance.servingsPerDayDefault,
  'created_by': instance.createdBy,
  'verified': instance.verified,
};
