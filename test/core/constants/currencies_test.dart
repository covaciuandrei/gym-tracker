import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/constants/currencies.dart';

void main() {
  test('uses EUR as the account creation and legacy fallback', () {
    expect(fallbackCurrencyCode, 'EUR');
    expect(supportedCurrencyCodes, contains(fallbackCurrencyCode));
  });

  test('normalizeCurrencyCode accepts supported values and falls back to EUR', () {
    expect(normalizeCurrencyCode(' ron '), 'RON');
    expect(normalizeCurrencyCode('CAD'), 'EUR');
    expect(normalizeCurrencyCode(null), 'EUR');
  });
}
