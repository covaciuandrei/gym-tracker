import 'package:json_annotation/json_annotation.dart';

part 'training_type_dto.g.dart';

@JsonSerializable()
class TrainingTypeDto {
  TrainingTypeDto({
    required this.name,
    required this.color,
    this.id = '',
    this.icon,
    this.createdAt,
  });

  factory TrainingTypeDto.fromJson(Map<String, dynamic> json) =>
      _$TrainingTypeDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TrainingTypeDtoToJson(this);

  /// Document id — excluded from Firestore fields (comes from doc.id).
  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: '')
  final String id;

  @JsonKey(name: 'name', defaultValue: '')
  final String name;

  @JsonKey(name: 'color', defaultValue: '')
  final String color;

  @JsonKey(name: 'icon')
  final String? icon;

  @JsonKey(name: 'created_at')
  final Object? createdAt;
}
