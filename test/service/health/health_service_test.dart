// Unit tests for HealthService
//
// STRATEGY: mock HealthSource.
// Key things tested:
//   • product CRUD delegation
//   • existence-guard on updateProduct throws SupplementProductNotFoundException
//   • yearMonth / date derivation for log entry operations
//
// Run:  flutter test test/service/health/health_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/data/remote/supplement/health_source.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/service/health/health_service.dart';

// ─── Mock ─────────────────────────────────────────────────────────────────

class MockHealthSource extends Mock implements HealthSource {}
// Fallbacks needed for any() on custom types
class _FakeSupplementProduct extends Fake implements SupplementProduct {}

class _FakeSupplementLog extends Fake implements SupplementLog {}
// ─── Fixtures ─────────────────────────────────────────────────────────────

const _userId = 'user_001';

final _product = SupplementProduct(
  id: 'prod_001',
  name: 'Whey Pro',
  brand: 'ON',
  ingredients: [],
  servingsPerDayDefault: 1.0,
);

final _log = SupplementLog(
  id: 'log_001',
  date: '2025-04-10',
  productId: 'prod_001',
  productName: 'Whey Pro',
  productBrand: 'ON',
  servingsTaken: 1.5,
);

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSupplementProduct());
    registerFallbackValue(_FakeSupplementLog());
  });

  late MockHealthSource mockSource;
  late HealthService sut;

  setUp(() {
    mockSource = MockHealthSource();
    sut = HealthService(mockSource);
  });

  // ─── yearMonthKey ────────────────────────────────────────────────────────

  group('yearMonthKey', () {
    test('zero-pads single-digit months', () {
      expect(HealthService.yearMonthKey(2025, 4), '2025-04');
      expect(HealthService.yearMonthKey(2025, 11), '2025-11');
    });
  });

  // ─── watchAllProducts ────────────────────────────────────────────────────

  group('watchAllProducts', () {
    test('streams the list from source', () {
      when(() => mockSource.watchAllProducts())
          .thenAnswer((_) => Stream.value([_product]));

      expect(sut.watchAllProducts(), emits(hasLength(1)));
    });
  });

  // ─── watchMyProducts ─────────────────────────────────────────────────────

  group('watchMyProducts', () {
    test('delegates to source with userId', () {
      when(() => mockSource.watchMyProducts(_userId))
          .thenAnswer((_) => Stream.value([_product]));

      expect(sut.watchMyProducts(_userId), emits(hasLength(1)));
      verify(() => mockSource.watchMyProducts(_userId)).called(1);
    });
  });

  // ─── getProduct ──────────────────────────────────────────────────────────

  group('getProduct', () {
    test('returns product from source', () async {
      when(() => mockSource.getProduct('prod_001'))
          .thenAnswer((_) async => _product);

      final result = await sut.getProduct('prod_001');
      expect(result, _product);
    });

    test('returns null when product does not exist', () async {
      when(() => mockSource.getProduct('missing'))
          .thenAnswer((_) async => null);

      expect(await sut.getProduct('missing'), isNull);
    });
  });

  // ─── createProduct ───────────────────────────────────────────────────────

  group('createProduct', () {
    test('delegates to source and returns new id', () async {
      when(() => mockSource.createProduct(_product))
          .thenAnswer((_) async => 'new_prod_id');

      final id = await sut.createProduct(_product);
      expect(id, 'new_prod_id');
      verify(() => mockSource.createProduct(_product)).called(1);
    });
  });

  // ─── updateProduct ───────────────────────────────────────────────────────

  group('updateProduct', () {
    test('delegates to source when product exists', () async {
      when(() => mockSource.getProduct(_product.id))
          .thenAnswer((_) async => _product);
      when(() => mockSource.updateProduct(_product))
          .thenAnswer((_) async {});

      await sut.updateProduct(_product);

      verify(() => mockSource.updateProduct(_product)).called(1);
    });

    test('throws SupplementProductNotFoundException when product missing',
        () async {
      when(() => mockSource.getProduct(_product.id))
          .thenAnswer((_) async => null);

      expect(
        () => sut.updateProduct(_product),
        throwsA(isA<SupplementProductNotFoundException>()),
      );
      verifyNever(() => mockSource.updateProduct(_product));
    });
  });

  // ─── deleteProduct ───────────────────────────────────────────────────────

  group('deleteProduct', () {
    test('delegates to source', () async {
      when(() => mockSource.deleteProduct('prod_001'))
          .thenAnswer((_) async {});

      await sut.deleteProduct('prod_001');

      verify(() => mockSource.deleteProduct('prod_001')).called(1);
    });
  });

  // ─── watchMonthEntries ───────────────────────────────────────────────────

  group('watchMonthEntries', () {
    test('passes correct yearMonth to source', () {
      when(() => mockSource.watchMonthEntries(_userId, '2025-04'))
          .thenAnswer((_) => Stream.value([_log]));

      expect(
        sut.watchMonthEntries(userId: _userId, year: 2025, month: 4),
        emits(hasLength(1)),
      );
      verify(() => mockSource.watchMonthEntries(_userId, '2025-04')).called(1);
    });
  });

  // ─── watchDayEntries ─────────────────────────────────────────────────────

  group('watchDayEntries', () {
    test('derives yearMonth from date and delegates to source', () {
      when(() => mockSource.watchDayEntries(_userId, '2025-04', '2025-04-10'))
          .thenAnswer((_) => Stream.value([_log]));

      expect(
        sut.watchDayEntries(userId: _userId, date: '2025-04-10'),
        emits(hasLength(1)),
      );
      verify(() =>
              mockSource.watchDayEntries(_userId, '2025-04', '2025-04-10'))
          .called(1);
    });
  });

  // ─── logSupplement ───────────────────────────────────────────────────────

  group('logSupplement', () {
    test('derives yearMonth from log.date and delegates to source', () async {
      when(() => mockSource.createEntry(_userId, '2025-04', _log))
          .thenAnswer((_) async => 'entry_001');

      final id = await sut.logSupplement(userId: _userId, model: _log);

      expect(id, 'entry_001');
      verify(() => mockSource.createEntry(_userId, '2025-04', _log)).called(1);
    });
  });

  // ─── deleteEntry ─────────────────────────────────────────────────────────

  group('deleteEntry', () {
    test('derives yearMonth from date and delegates to source', () async {
      when(() => mockSource.deleteEntry(_userId, '2025-04', 'log_001'))
          .thenAnswer((_) async {});

      await sut.deleteEntry(
        userId: _userId,
        date: '2025-04-10',
        entryId: 'log_001',
      );

      verify(() => mockSource.deleteEntry(_userId, '2025-04', 'log_001'))
          .called(1);
    });
  });
}
