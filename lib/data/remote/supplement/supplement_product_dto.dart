import 'package:json_annotation/json_annotation.dart';

import 'product_ingredient_dto.dart';

part 'supplement_product_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class SupplementProductDto {
  SupplementProductDto({
    required this.name,
    required this.brand,
    required this.ingredients,
    required this.servingsPerDayDefault,
    this.id = '',
    this.createdBy,
    this.verified,
  });

  factory SupplementProductDto.fromJson(Map<String, dynamic> json) =>
      _$SupplementProductDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupplementProductDtoToJson(this);

  /// Document id — excluded from Firestore fields.
  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: '')
  final String id;

  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  @JsonKey(name: 'brand', defaultValue: '')
  final String brand;

  @JsonKey(name: 'ingredients', defaultValue: [])
  final List<ProductIngredientDto> ingredients;

  @JsonKey(name: 'servings_per_day_default', defaultValue: 1.0)
  final double servingsPerDayDefault;

  @JsonKey(name: 'created_by')
  final String? createdBy;

  @JsonKey(name: 'verified')
  final bool? verified;
}
