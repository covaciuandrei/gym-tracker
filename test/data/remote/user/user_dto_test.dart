import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/user/user_dto.dart';

void main() {
  test('missing account currency falls back to EUR', () {
    final dto = UserDto.fromJson(const <String, dynamic>{});

    expect(dto.currency, 'EUR');
  });

  test('currency round-trips as a top-level profile field', () {
    final json = UserDto(
      id: 'user_1',
      email: 'user@test.com',
      displayName: 'User',
      theme: 'dark',
      language: 'ro',
      currency: 'RON',
      lastLoginAt: 'last-login',
      createdAt: 'created',
      totalAttendances: 0,
    ).toJson();

    expect(json['currency'], 'RON');
    expect(json.containsKey('id'), isFalse);
  });
}
