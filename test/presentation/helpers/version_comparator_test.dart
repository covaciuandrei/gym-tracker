import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/presentation/helpers/version_comparator.dart';

void main() {
  group('VersionComparator.compare', () {
    test('equal versions return 0', () {
      expect(VersionComparator.compare('1.0.0', '1.0.0'), 0);
    });

    test('patch diff', () {
      expect(VersionComparator.compare('1.0.0', '1.0.1'), lessThan(0));
      expect(VersionComparator.compare('1.0.2', '1.0.1'), greaterThan(0));
    });

    test('minor diff', () {
      expect(VersionComparator.compare('1.1.0', '1.2.0'), lessThan(0));
    });

    test('major diff', () {
      expect(VersionComparator.compare('2.0.0', '1.9.9'), greaterThan(0));
    });

    test('missing segments treated as zero', () {
      expect(VersionComparator.compare('1.2', '1.2.0'), 0);
      expect(VersionComparator.compare('1', '1.0.0'), 0);
    });

    test('non-numeric segments treated as zero', () {
      expect(VersionComparator.compare('abc', '0.0.0'), 0);
      // '1.x.0' parses to [1, 0, 0] which is less than [1, 0, 5].
      expect(VersionComparator.compare('1.x.0', '1.0.5'), lessThan(0));
    });

    test('strips build-number suffix', () {
      expect(VersionComparator.compare('1.0.0+1', '1.0.0'), 0);
      expect(VersionComparator.compare('1.0.0+42', '1.0.1'), lessThan(0));
    });

    test('numeric compare, not lexicographic', () {
      expect(VersionComparator.compare('1.10.0', '1.2.0'), greaterThan(0));
    });
  });

  group('VersionComparator.isBelow', () {
    test('true when strictly older', () {
      expect(VersionComparator.isBelow('1.0.0', '1.0.1'), isTrue);
    });

    test('false when equal', () {
      expect(VersionComparator.isBelow('1.0.0', '1.0.0'), isFalse);
    });

    test('false when newer', () {
      expect(VersionComparator.isBelow('1.0.2', '1.0.1'), isFalse);
    });
  });
}
