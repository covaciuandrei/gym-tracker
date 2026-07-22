import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/core/utils/app_date_formatter.dart';

void main() {
  group('AppDateFormatter', () {
    test('formats complete dates as dd.MM.yyyy with leading zeros', () {
      expect(AppDateFormatter.format(DateTime(2026, 7, 2)), '02.07.2026');
      expect(AppDateFormatter.format(DateTime(2026, 11, 22, 23, 59)), '22.11.2026');
    });

    test('converts canonical ISO dates to the display format', () {
      expect(AppDateFormatter.tryFormatIsoDate('2024-02-29'), '29.02.2024');
    });

    test('rejects invalid or non-canonical ISO dates', () {
      expect(AppDateFormatter.tryFormatIsoDate('2026-02-29'), isNull);
      expect(AppDateFormatter.tryFormatIsoDate('2026-7-2'), isNull);
      expect(AppDateFormatter.tryFormatIsoDate('not-a-date'), isNull);
    });
  });
}
