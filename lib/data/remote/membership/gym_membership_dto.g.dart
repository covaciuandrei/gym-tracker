// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gym_membership_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GymMembershipDto _$GymMembershipDtoFromJson(Map<String, dynamic> json) =>
    GymMembershipDto(
      gymName: json['gym_name'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      durationMonths: (json['duration_months'] as num?)?.toInt() ?? 1,
      validUntil: json['valid_until'] as String? ?? '',
      priceMinor: (json['price_minor'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'RON',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );

Map<String, dynamic> _$GymMembershipDtoToJson(GymMembershipDto instance) =>
    <String, dynamic>{
      'gym_name': instance.gymName,
      'start_date': instance.startDate,
      'duration_months': instance.durationMonths,
      'valid_until': instance.validUntil,
      'price_minor': instance.priceMinor,
      'currency': instance.currency,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };
