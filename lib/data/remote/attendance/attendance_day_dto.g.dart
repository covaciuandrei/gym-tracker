// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_day_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceDayDto _$AttendanceDayDtoFromJson(Map<String, dynamic> json) =>
    AttendanceDayDto(
      date: json['date'] as String? ?? '',
      timestamp: json['timestamp'] as Object,
      trainingTypeId: json['training_type_id'] as String?,
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$AttendanceDayDtoToJson(AttendanceDayDto instance) =>
    <String, dynamic>{
      'date': instance.date,
      'timestamp': instance.timestamp,
      'training_type_id': instance.trainingTypeId,
      'duration_minutes': instance.durationMinutes,
      'notes': instance.notes,
    };
