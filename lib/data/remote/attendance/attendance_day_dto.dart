import 'package:json_annotation/json_annotation.dart';

part 'attendance_day_dto.g.dart';

@JsonSerializable()
class AttendanceDayDto {
  AttendanceDayDto({
    required this.date,
    required this.timestamp,
    this.trainingTypeId,
    this.durationMinutes,
    this.notes,
  });

  factory AttendanceDayDto.fromJson(Map<String, dynamic> json) =>
      _$AttendanceDayDtoFromJson(json);

  Map<String, dynamic> toJson() => _$AttendanceDayDtoToJson(this);

  /// Date string in format "YYYY-MM-DD".
  @JsonKey(name: 'date', defaultValue: '')
  final String date;

  /// Stored as a Firestore Timestamp; serialized as an ISO-8601 String in unit tests.
  @JsonKey(name: 'timestamp')
  final Object timestamp;

  @JsonKey(name: 'training_type_id')
  final String? trainingTypeId;

  @JsonKey(name: 'duration_minutes')
  final int? durationMinutes;

  @JsonKey(name: 'notes')
  final String? notes;
}
