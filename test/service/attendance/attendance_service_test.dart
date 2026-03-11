// Unit tests for AttendanceService
//
// STRATEGY: mock AttendanceDaySource.
// Key things tested:
//   • yearMonth key derivation from date string ("YYYY-MM-DD" → "YYYY-MM")
//   • delegation to source for all CRUD operations
//   • static yearMonthKey helper
//
// Run:  flutter test test/service/attendance/attendance_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/data/remote/attendance/attendance_day_source.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';

// ─── Mock ─────────────────────────────────────────────────────────────────

class MockAttendanceDaySource extends Mock implements AttendanceDaySource {}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _userId = 'user_001';

final _day = AttendanceDay(
  date: '2025-03-15',
  timestamp: DateTime(2025, 3, 15, 9),
  trainingTypeId: 'type_a',
  durationMinutes: 60,
  notes: 'Good session',
);

void main() {
  late MockAttendanceDaySource mockSource;
  late AttendanceService sut;

  setUp(() {
    mockSource = MockAttendanceDaySource();
    sut = AttendanceService(mockSource);
  });

  // ─── yearMonthKey ────────────────────────────────────────────────────────

  group('yearMonthKey', () {
    test('returns zero-padded YYYY-MM string', () {
      expect(AttendanceService.yearMonthKey(2025, 3), '2025-03');
      expect(AttendanceService.yearMonthKey(2024, 12), '2024-12');
      expect(AttendanceService.yearMonthKey(2024, 1), '2024-01');
    });
  });

  // ─── watchMonth ─────────────────────────────────────────────────────────

  group('watchMonth', () {
    test('passes correct yearMonth key to source', () {
      when(() => mockSource.watchMonth(_userId, '2025-03'))
          .thenAnswer((_) => Stream.value([_day]));

      expect(
        sut.watchMonth(userId: _userId, year: 2025, month: 3),
        emits(hasLength(1)),
      );
      verify(() => mockSource.watchMonth(_userId, '2025-03')).called(1);
    });

    test('streams an empty list', () {
      when(() => mockSource.watchMonth(_userId, '2025-01'))
          .thenAnswer((_) => Stream.value([]));

      expect(
        sut.watchMonth(userId: _userId, year: 2025, month: 1),
        emits(isEmpty),
      );
    });
  });

  // ─── getDay ──────────────────────────────────────────────────────────────

  group('getDay', () {
    test('derives yearMonth from date and delegates to source', () async {
      when(() => mockSource.getDay(_userId, '2025-03', '2025-03-15'))
          .thenAnswer((_) async => _day);

      final result = await sut.getDay(userId: _userId, date: '2025-03-15');

      expect(result, _day);
      verify(() => mockSource.getDay(_userId, '2025-03', '2025-03-15'))
          .called(1);
    });

    test('returns null when source returns null', () async {
      when(() => mockSource.getDay(_userId, '2025-03', '2025-03-99'))
          .thenAnswer((_) async => null);

      final result = await sut.getDay(userId: _userId, date: '2025-03-99');

      expect(result, isNull);
    });
  });

  // ─── upsertDay ───────────────────────────────────────────────────────────

  group('upsertDay', () {
    test('derives yearMonth from model.date and delegates to source', () async {
      when(() => mockSource.upsertDay(_userId, '2025-03', _day))
          .thenAnswer((_) async {});

      await sut.upsertDay(userId: _userId, model: _day);

      verify(() => mockSource.upsertDay(_userId, '2025-03', _day)).called(1);
    });
  });

  // ─── deleteDay ───────────────────────────────────────────────────────────

  group('deleteDay', () {
    test('derives yearMonth from date string and delegates to source', () async {
      when(() => mockSource.deleteDay(_userId, '2025-03', '2025-03-15'))
          .thenAnswer((_) async {});

      await sut.deleteDay(userId: _userId, date: '2025-03-15');

      verify(() => mockSource.deleteDay(_userId, '2025-03', '2025-03-15'))
          .called(1);
    });
  });
}
