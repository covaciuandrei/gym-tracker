// Unit tests for CalendarCubit
//
// STRATEGY: mock AttendanceService, verify emitted states via cubit.stream.
//
// Run:  flutter test test/cubit/calendar/calendar_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/calendar/calendar_cubit.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/health/health_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';
import 'package:mocktail/mocktail.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockAttendanceService extends Mock implements AttendanceService {}

class MockHealthService extends Mock implements HealthService {}

class MockWorkoutService extends Mock implements WorkoutService {}

class _FakeAttendanceDay extends Fake implements AttendanceDay {}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _userId = 'user_001';
const _year = 2025;
const _month = 6;

final _dayA = AttendanceDay(
  date: '2025-06-02',
  timestamp: DateTime(2025, 6, 2),
  trainingTypeId: 'type_a',
  durationMinutes: 60,
);

final _dayB = AttendanceDay(date: '2025-06-09', timestamp: DateTime(2025, 6, 9));

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAttendanceDay());
  });

  late MockAttendanceService mockService;
  late MockHealthService mockHealthService;
  late MockWorkoutService mockWorkoutService;
  late CalendarCubit sut;

  setUp(() {
    mockService = MockAttendanceService();
    mockHealthService = MockHealthService();
    mockWorkoutService = MockWorkoutService();

    // Stub the health and workout service methods that CalendarCubit calls
    when(
      () => mockHealthService.watchMonthEntries(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) => Stream.value([]));

    when(() => mockWorkoutService.watchAll(any<String>())).thenAnswer((_) => Stream.value([]));

    sut = CalendarCubit(mockService, mockHealthService, mockWorkoutService);
  });

  tearDown(() => sut.close());

  // ─── loadMonth ────────────────────────────────────────────────────────

  group('loadMonth', () {
    test('emits pending then CalendarMonthLoadedState with days', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.value([_dayA, _dayB]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<CalendarMonthLoadedState>()
              .having((s) => s.days, 'days', [_dayA, _dayB])
              .having((s) => s.year, 'year', _year)
              .having((s) => s.month, 'month', _month),
        ]),
      );
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await future;
    });

    test('emits pending then empty CalendarMonthLoadedState', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.value([]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), isA<CalendarMonthLoadedState>().having((s) => s.days, 'days', isEmpty)]),
      );
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await future;
    });

    test('emits pending then somethingWentWrong on stream error', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.error(Exception('network')));

      final future = expectLater(sut.stream, emitsInOrder([const PendingState(), const SomethingWentWrongState()]));
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await future;
    });
  });

  // ─── markDay ──────────────────────────────────────────────────────────

  group('markDay', () {
    test('emits pending then CalendarDayMarkedState with the day', () async {
      when(() => mockService.upsertDay(userId: _userId, model: _dayA)).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), isA<CalendarDayMarkedState>().having((s) => s.day, 'day', _dayA)]),
      );
      await sut.markDay(userId: _userId, day: _dayA);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.upsertDay(userId: _userId, model: _dayA)).thenThrow(Exception('firestore'));

      final future = expectLater(sut.stream, emitsInOrder([const PendingState(), const SomethingWentWrongState()]));
      await sut.markDay(userId: _userId, day: _dayA);
      await future;
    });
  });

  // ─── clearDay ─────────────────────────────────────────────────────────

  group('clearDay', () {
    test('emits pending then CalendarDayClearedState', () async {
      when(() => mockService.deleteDay(userId: _userId, date: _dayA.date)).thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), isA<CalendarDayClearedState>().having((s) => s.date, 'date', _dayA.date)]),
      );
      await sut.clearDay(userId: _userId, date: _dayA.date);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.deleteDay(userId: _userId, date: _dayA.date)).thenThrow(Exception('firestore'));

      final future = expectLater(sut.stream, emitsInOrder([const PendingState(), const SomethingWentWrongState()]));
      await sut.clearDay(userId: _userId, date: _dayA.date);
      await future;
    });
  });
}
