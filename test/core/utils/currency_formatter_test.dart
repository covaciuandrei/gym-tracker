import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats supported currencies from minor units', () {
      expect(CurrencyFormatter.format(15000, 'RON'), '150 lei');
      expect(CurrencyFormatter.format(2999, 'EUR'), '29.99 €');
      expect(CurrencyFormatter.format(2999, 'USD'), r'$29.99');
      expect(CurrencyFormatter.format(2999, 'GBP'), '£29.99');
    });

    test('parses dot and comma decimal amounts without floating-point math', () {
      expect(CurrencyFormatter.parseMinor('150'), 15000);
      expect(CurrencyFormatter.parseMinor('29.9'), 2990);
      expect(CurrencyFormatter.parseMinor('29,99'), 2999);
    });

    test('rejects invalid or over-precise amounts', () {
      expect(CurrencyFormatter.parseMinor(''), isNull);
      expect(CurrencyFormatter.parseMinor('-1'), isNull);
      expect(CurrencyFormatter.parseMinor('1.999'), isNull);
      expect(CurrencyFormatter.parseMinor('one'), isNull);
    });
  });
}
