import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/body_type.dart';

void main() {
  test('storageValue round-trips through fromStorage', () {
    for (final value in BodyType.values) {
      expect(BodyType.fromStorage(value.storageValue), value);
    }
  });

  test('fromStorage returns null for missing or unrecognized values', () {
    expect(BodyType.fromStorage(null), isNull);
    expect(BodyType.fromStorage('muscular'), isNull);
  });
}
