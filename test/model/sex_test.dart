import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/model/sex.dart';

void main() {
  test('storageValue round-trips through fromStorage', () {
    for (final value in Sex.values) {
      expect(Sex.fromStorage(value.storageValue), value);
    }
  });

  test('fromStorage returns null for missing or unrecognized values', () {
    expect(Sex.fromStorage(null), isNull);
    expect(Sex.fromStorage(''), isNull);
    expect(Sex.fromStorage('other'), isNull);
  });
}
