// Unit tests for StatsCubit
//
// STRATEGY: mock AttendanceService and WorkoutService (both stateless).
// StatsCubit calls .watchMonth(...).first for every month, so the test stubs
// watchMonth with Stream.value([...]) — the .first Future resolves
// immediately on the next microtask.
//
// Aggregation assertions use year = 2025 (a past year from the test date of
// March 2026), which makes `monthlyCount` computed for December 2025 and
// `currentWeekStreak = 0` (no data in the current/previous ISO week) — both
// deterministic regardless of when the test runs.
//
// Run:  flutter test test/cubit/stats/stats_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/stats/stats_cubit.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/attendance_stats.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockAttendanceService extends Mock implements AttendanceService {}

class MockWorkoutService extends Mock implements WorkoutService {}

// ─── Helpers ──────────────────────────────────────────────────────────────

/// Stubs all 12 months of [year] and the previous December to return [].
/// Optionally, [overrides] maps (year, month) → list to inject specific data.
void _stubMonths(
  MockAttendanceService mock,
  String userId,
  int year, {
  Map<(int, int), List<AttendanceDay>> overrides = const {},
}) {
  // Previous December
  final pairs = [(year - 1, 12), for (int m = 1; m <= 12; m++) (year, m)];
  for (final (y, m) in pairs) {
    final data = overrides[(y, m)] ?? <AttendanceDay>[];
    when(() => mock.watchMonth(userId: userId, year: y, month: m))
        .thenAnswer((_) => Stream.value(data));
  }
}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _userId = 'user_001';
const _year = 2025;

final _typeA = TrainingType(id: 'type_a', name: 'Chest', color: '#FF0000');
final _typeB = TrainingType(id: 'type_b', name: 'Cardio', color: '#00FF00');

// Three Mondays in June 2025 — three consecutive ISO weeks.
final _juneDays = [
  AttendanceDay(
    date: '2025-06-02', // Monday
    timestamp: DateTime(2025, 6, 2),
    trainingTypeId: 'type_a',
    durationMinutes: 60,
  ),
  AttendanceDay(
    date: '2025-06-09', // Monday
    timestamp: DateTime(2025, 6, 9),
    trainingTypeId: 'type_a',
    durationMinutes: 90,
  ),
  AttendanceDay(
    date: '2025-06-16', // Monday
    timestamp: DateTime(2025, 6, 16),
    // No trainingTypeId
    durationMinutes: 30,
  ),
];

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  late MockAttendanceService mockAttendance;
  late MockWorkoutService mockWorkout;
  late StatsCubit sut;

  setUp(() {
    mockAttendance = MockAttendanceService();
    mockWorkout = MockWorkoutService();
    sut = StatsCubit(mockAttendance, mockWorkout);
  });

  tearDown(() => sut.close());

  // ─── load – empty data ────────────────────────────────────────────────

  group('load – empty year', () {
    test('emits pending then StatsLoadedState with zero counts', () async {
      _stubMonths(mockAttendance, _userId, _year);
      when(() => mockWorkout.watchAll(_userId))
          .thenAnswer((_) => Stream.value([]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<StatsLoadedState>()
              .having((s) => s.year, 'year', _year)
              .having((s) => s.types, 'types', isEmpty)
              .having(
                (s) => s.stats.yearlyCount,
                'yearlyCount',
                0,
              )
              .having(
                (s) => s.stats.currentWeekStreak,
                'currentWeekStreak',
                0,
              )
              .having(
                (s) => s.stats.bestWeekStreak,
                'bestWeekStreak',
                0,
              )
              .having(
                (s) => s.stats.favoriteDaysOfWeek,
                'favoriteDaysOfWeek',
                isEmpty,
              ),
        ]),
      );
      await sut.load(userId: _userId, year: _year);
      await future;
    });
  });

  // ─── load – June data ─────────────────────────────────────────────────

  group('load – known June data', () {
    setUp(() {
      _stubMonths(
        mockAttendance,
        _userId,
        _year,
        overrides: {(_year, 6): _juneDays},
      );
      when(() => mockWorkout.watchAll(_userId))
          .thenAnswer((_) => Stream.value([_typeA, _typeB]));
    });

    test('yearlyCount equals total days', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      expect(state.stats.yearlyCount, 3);
      expect(state.stats.totalCount, 3);
    });

    test('typeDistribution counts only days with a trainingTypeId', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      // Two of the three days have type_a; the third has no type.
      expect(state.stats.typeDistribution, {'type_a': 2});
    });

    test('favoriteDaysOfWeek is Monday (weekday 1) for all-Monday data',
        () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      expect(state.stats.favoriteDaysOfWeek, [1]); // 1 = Monday
    });

    test('monthlyDurationAverages for June is correct mean', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      // June (month 6): 60 + 90 + 30 = 180 / 3 = 60.0
      expect(state.stats.monthlyDurationAverages[6], 60.0);
    });

    test('perTypeDurationAverages for type_a is correct mean', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      // type_a: 60 + 90 = 150 / 2 = 75.0
      expect(state.stats.perTypeDurationAverages['type_a'], 75.0);
    });

    test('bestWeekStreak is 3 for three consecutive Mondays', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      expect(state.stats.bestWeekStreak, 3);
    });

    test('currentWeekStreak is 0 because data is in the past year', () async {
      // June 2025 weeks are far in the past from the test execution date
      // (March 2026) so the streak is no longer "current".
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      expect(state.stats.currentWeekStreak, 0);
    });

    test('types list contains the training types from WorkoutService', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);
      await sut.load(userId: _userId, year: _year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().first;
      expect(state.types, [_typeA, _typeB]);
    });
  });

  // ─── load – service failure ───────────────────────────────────────────

  group('load – failure', () {
    test('emits pending then somethingWentWrong when service throws', () async {
      when(() => mockAttendance.watchMonth(
            userId: any(named: 'userId'),
            year: any(named: 'year'),
            month: any(named: 'month'),
          )).thenAnswer((_) => Stream.error(Exception('network')));
      when(() => mockWorkout.watchAll(_userId))
          .thenAnswer((_) => Stream.value([]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.load(userId: _userId, year: _year);
      await future;
    });
  });
}
