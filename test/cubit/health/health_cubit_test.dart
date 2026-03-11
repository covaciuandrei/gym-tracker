// Unit tests for HealthCubit
//
// STRATEGY: mock HealthService, verify emitted states via cubit.stream.
//
// Run:  flutter test test/cubit/health/health_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health/health_cubit.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/service/health/health_service.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockHealthService extends Mock implements HealthService {}

class _FakeSupplementLog extends Fake implements SupplementLog {}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _userId = 'user_001';
const _date = '2025-06-02';
const _entryId = 'entry_001';

final _product = SupplementProduct(
  id: 'prod_001',
  name: 'Whey Protein',
  brand: 'Optimum',
  ingredients: [],
  servingsPerDayDefault: 2,
);

final _log = SupplementLog(
  id: '',
  date: _date,
  productId: _product.id,
  servingsTaken: 1.5,
);

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSupplementLog());
  });

  late MockHealthService mockService;
  late HealthCubit sut;

  setUp(() {
    mockService = MockHealthService();
    sut = HealthCubit(mockService);
  });

  tearDown(() => sut.close());

  // ─── loadDayEntries ───────────────────────────────────────────────────

  group('loadDayEntries', () {
    test('emits pending then HealthDayEntriesLoadedState', () async {
      when(() => mockService.watchDayEntries(userId: _userId, date: _date))
          .thenAnswer((_) => Stream.value([_log]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<HealthDayEntriesLoadedState>()
              .having((s) => s.entries, 'entries', [_log])
              .having((s) => s.date, 'date', _date),
        ]),
      );
      sut.loadDayEntries(userId: _userId, date: _date);
      await future;
    });

    test('emits pending then empty state when no entries', () async {
      when(() => mockService.watchDayEntries(userId: _userId, date: _date))
          .thenAnswer((_) => Stream.value([]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<HealthDayEntriesLoadedState>()
              .having((s) => s.entries, 'entries', isEmpty),
        ]),
      );
      sut.loadDayEntries(userId: _userId, date: _date);
      await future;
    });

    test('emits somethingWentWrong on stream error', () async {
      when(() => mockService.watchDayEntries(userId: _userId, date: _date))
          .thenAnswer((_) => Stream.error(Exception('network')));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      sut.loadDayEntries(userId: _userId, date: _date);
      await future;
    });
  });

  // ─── loadProducts ─────────────────────────────────────────────────────

  group('loadProducts', () {
    test('emits pending then HealthProductsLoadedState', () async {
      when(() => mockService.watchAllProducts())
          .thenAnswer((_) => Stream.value([_product]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<HealthProductsLoadedState>()
              .having((s) => s.products, 'products', [_product]),
        ]),
      );
      sut.loadProducts(_userId);
      await future;
    });

    test('emits somethingWentWrong on stream error', () async {
      when(() => mockService.watchAllProducts())
          .thenAnswer((_) => Stream.error(Exception('network')));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      sut.loadProducts(_userId);
      await future;
    });
  });

  // ─── logSupplement ────────────────────────────────────────────────────

  group('logSupplement', () {
    test('emits pending then HealthEntryLoggedState with generated id',
        () async {
      when(() => mockService.logSupplement(userId: _userId, model: _log))
          .thenAnswer((_) async => _entryId);

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<HealthEntryLoggedState>()
              .having((s) => s.id, 'id', _entryId),
        ]),
      );
      await sut.logSupplement(userId: _userId, model: _log);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.logSupplement(userId: _userId, model: _log))
          .thenThrow(Exception('firestore'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.logSupplement(userId: _userId, model: _log);
      await future;
    });
  });

  // ─── deleteEntry ──────────────────────────────────────────────────────

  group('deleteEntry', () {
    test('emits pending then HealthEntryDeletedState', () async {
      when(() => mockService.deleteEntry(
            userId: _userId,
            date: _date,
            entryId: _entryId,
          )).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          const HealthEntryDeletedState(),
        ]),
      );
      await sut.deleteEntry(userId: _userId, date: _date, entryId: _entryId);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.deleteEntry(
            userId: _userId,
            date: _date,
            entryId: _entryId,
          )).thenThrow(Exception('firestore'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.deleteEntry(userId: _userId, date: _date, entryId: _entryId);
      await future;
    });
  });
}
