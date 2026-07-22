import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gym_tracker/data/remote/membership/gym_membership_dto.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:injectable/injectable.dart';

@injectable
class GymMembershipMapper {
  GymMembership mapDto(GymMembershipDto dto) => GymMembership(
    id: dto.id,
    gymName: dto.gymName,
    startDate: _toDate(dto.startDate),
    durationMonths: dto.durationMonths,
    validUntil: _toDate(dto.validUntil),
    priceMinor: dto.priceMinor,
    currency: dto.currency,
    createdAt: _toNullableDateTime(dto.createdAt),
    updatedAt: _toNullableDateTime(dto.updatedAt),
  );

  GymMembershipDto mapModel({required GymMembership model, required Object createdAt, required Object updatedAt}) {
    return GymMembershipDto(
      id: model.id,
      gymName: model.gymName,
      startDate: _formatDate(model.startDate),
      durationMonths: model.durationMonths,
      validUntil: _formatDate(model.validUntil),
      priceMinor: model.priceMinor,
      currency: model.currency,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  DateTime _toDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      throw FormatException('Invalid membership date: $raw');
    }
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  DateTime? _toNullableDateTime(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is Map) {
      final seconds = raw['seconds'];
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
      }
    }
    return null;
  }

  String _formatDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return '${normalized.year.toString().padLeft(4, '0')}-'
        '${normalized.month.toString().padLeft(2, '0')}-'
        '${normalized.day.toString().padLeft(2, '0')}';
  }
}
