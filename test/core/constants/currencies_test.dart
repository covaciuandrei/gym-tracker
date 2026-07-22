import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/constants/currencies.dart';

void main() {
  group('defaultCurrencyForLanguage', () {
    test('uses RON for Romanian locales', () {
      expect(defaultCurrencyForLanguage('ro'), 'RON');
      expect(defaultCurrencyForLanguage('ro-RO'), 'RON');
    });

    test('uses EUR for every other language', () {
      expect(defaultCurrencyForLanguage('en'), 'EUR');
      expect(defaultCurrencyForLanguage(''), 'EUR');
    });
  });

  test('normalizeCurrencyCode accepts supported values and falls back to EUR', () {
    expect(normalizeCurrencyCode(' ron '), 'RON');
    expect(normalizeCurrencyCode('CAD'), 'EUR');
    expect(normalizeCurrencyCode(null), 'EUR');
  });
}
