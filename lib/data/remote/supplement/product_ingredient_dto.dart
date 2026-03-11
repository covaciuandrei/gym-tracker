import 'package:json_annotation/json_annotation.dart';

part 'product_ingredient_dto.g.dart';

@JsonSerializable()
class ProductIngredientDto {
  ProductIngredientDto({
    required this.stdId,
    required this.name,
    required this.amount,
    required this.unit,
  });

  factory ProductIngredientDto.fromJson(Map<String, dynamic> json) =>
      _$ProductIngredientDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ProductIngredientDtoToJson(this);

  @JsonKey(name: 'std_id', defaultValue: '')
  final String stdId;

  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  @JsonKey(name: 'amount', defaultValue: 0.0)
  final double amount;

  @JsonKey(name: 'unit', defaultValue: '')
  final String unit;
}
