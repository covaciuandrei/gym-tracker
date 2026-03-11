// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_ingredient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductIngredientDto _$ProductIngredientDtoFromJson(
  Map<String, dynamic> json,
) => ProductIngredientDto(
  stdId: json['std_id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
  unit: json['unit'] as String? ?? '',
);

Map<String, dynamic> _$ProductIngredientDtoToJson(
  ProductIngredientDto instance,
) => <String, dynamic>{
  'std_id': instance.stdId,
  'name': instance.name,
  'amount': instance.amount,
  'unit': instance.unit,
};
