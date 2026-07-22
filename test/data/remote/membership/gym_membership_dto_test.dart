import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/membership/gym_membership_dto.dart';

void main() {
  test('fromJson maps membership fields and excludes document id', () {
    final dto = GymMembershipDto.fromJson({
      'id': 'ignored',
      'gym_name': 'Test Gym',
      'start_date': '2026-07-21',
      'duration_months': 3,
      'valid_until': '2026-10-21',
      'price_minor': 15000,
      'currency': 'RON',
      'created_at': 'created',
      'updated_at': 'updated',
    });

    expect(dto.id, '');
    expect(dto.gymName, 'Test Gym');
    expect(dto.startDate, '2026-07-21');
    expect(dto.durationMonths, 3);
    expect(dto.validUntil, '2026-10-21');
    expect(dto.priceMinor, 15000);
    expect(dto.currency, 'RON');
  });

  test('toJson uses Firestore field names and excludes document id', () {
    final json = GymMembershipDto(
      id: 'membership_1',
      gymName: 'Test Gym',
      startDate: '2026-07-21',
      durationMonths: 1,
      validUntil: '2026-08-21',
      priceMinor: 15000,
      currency: 'RON',
    ).toJson();

    expect(json['gym_name'], 'Test Gym');
    expect(json['duration_months'], 1);
    expect(json['price_minor'], 15000);
    expect(json.containsKey('id'), isFalse);
  });

  test('missing currency falls back to EUR', () {
    final dto = GymMembershipDto.fromJson(const <String, dynamic>{});

    expect(dto.currency, 'EUR');
  });
}
