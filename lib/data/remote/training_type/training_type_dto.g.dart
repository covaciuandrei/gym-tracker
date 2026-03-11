// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'training_type_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrainingTypeDto _$TrainingTypeDtoFromJson(Map<String, dynamic> json) =>
    TrainingTypeDto(
      name: json['name'] as String? ?? '',
      color: json['color'] as String? ?? '',
      icon: json['icon'] as String?,
      createdAt: json['created_at'],
    );

Map<String, dynamic> _$TrainingTypeDtoToJson(TrainingTypeDto instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
      'icon': instance.icon,
      'created_at': instance.createdAt,
    };
