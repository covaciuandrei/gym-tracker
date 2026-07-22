import 'package:json_annotation/json_annotation.dart';

part 'gym_membership_dto.g.dart';

@JsonSerializable()
class GymMembershipDto {
  GymMembershipDto({
    required this.gymName,
    required this.startDate,
    required this.durationMonths,
    required this.validUntil,
    required this.priceMinor,
    required this.currency,
    this.id = '',
    this.createdAt,
    this.updatedAt,
  });

  factory GymMembershipDto.fromJson(Map<String, dynamic> json) => _$GymMembershipDtoFromJson(json);

  Map<String, dynamic> toJson() => _$GymMembershipDtoToJson(this);

  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: '')
  final String id;

  @JsonKey(name: 'gym_name', defaultValue: '')
  final String gymName;

  @JsonKey(name: 'start_date', defaultValue: '')
  final String startDate;

  @JsonKey(name: 'duration_months', defaultValue: 1)
  final int durationMonths;

  @JsonKey(name: 'valid_until', defaultValue: '')
  final String validUntil;

  @JsonKey(name: 'price_minor', defaultValue: 0)
  final int priceMinor;

  @JsonKey(name: 'currency', defaultValue: 'EUR')
  final String currency;

  @JsonKey(name: 'created_at')
  final Object? createdAt;

  @JsonKey(name: 'updated_at')
  final Object? updatedAt;
}
