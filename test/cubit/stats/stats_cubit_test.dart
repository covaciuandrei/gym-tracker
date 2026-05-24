import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/stats/stats_cubit.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/health/health_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';
import 'package:mocktail/mocktail.dart';

class MockAttendanceService extends Mock implements AttendanceService {}

class MockWorkoutService extends Mock implements WorkoutService {}

class MockHealthService extends Mock implements HealthService {}

void _stubMonths(
  MockAttendanceService mock,
  String userId,
  int year, {
  Map<(int, int), List<AttendanceDay>> overrides = const {},
}) {
  final pairs = [(year - 1, 12), for (int m = 1; m <= 12; m++) (year, m)];
  for (final (y, m) in pairs) {
    final data = overrides[(y, m)] ?? <AttendanceDay>[];
    when(() => mock.watchMonth(userId: userId, year: y, month: m)).thenAnswer((_) => Stream.value(data));
  }
}

const _userId = 'user_001';
const _year = 2025;

final _typeA = TrainingType(id: 'type_a', name: 'Chest', color: '#FF0000');
final _typeB = TrainingType(id: 'type_b', name: 'Cardio', color: '#00FF00');

// Three Mondays in June 2025 — three consecutive ISO weeks.
final _juneDays = [
  AttendanceDay(date: '2025-06-02', timestamp: DateTime(2025, 6, 2), trainingTypeId: 'type_a', durationMinutes: 60),
  AttendanceDay(date: '2025-06-09', timestamp: DateTime(2025, 6, 9), trainingTypeId: 'type_a', durationMinutes: 90),
  AttendanceDay(
    date: '2025-06-16', // Monday
    timestamp: DateTime(2025, 6, 16),
    // No trainingTypeId
    durationMinutes: 30,
  ),
];

void main() {
  late MockAttendanceService mockAttendance;
  late MockWorkoutService mockWorkout;
  late MockHealthService mockHealth;
  late StatsCubit sut;

  setUp(() {
    mockAttendance = MockAttendanceService();
    mockWorkout = MockWorkoutService();
    mockHealth = MockHealthService();

    when(
      () => mockHealth.watchMonthEntries(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) => Stream.value([]));

    when(() => mockHealth.watchAllProducts()).thenAnswer((_) => Stream.value([]));

    sut = StatsCubit(mockAttendance, mockWorkout, mockHealth);
  });

  tearDown(() => sut.close());

  group('initYear', () {
    test('emits StatsYearInitializedState with the requested year', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await Future<void>.delayed(Duration.zero);

      final init = emitted.whereType<StatsYearInitializedState>().last;
      expect(init.year, _year);
      // No slice-level states should have been emitted yet.
      expect(emitted.whereType<StatsAttendancesLoadingState>(), isEmpty);
      expect(emitted.whereType<StatsWorkoutsLoadingState>(), isEmpty);
      expect(emitted.whereType<StatsDurationLoadingState>(), isEmpty);
      expect(emitted.whereType<StatsHealthLoadingState>(), isEmpty);
    });
  });

  group('loadTab - attendances', () {
    test('emits Loading then Loaded for attendances slice only', () async {
      _stubMonths(mockAttendance, _userId, _year);
      when(() => mockWorkout.watchAll(_userId)).thenAnswer((_) => Stream.value([]));

      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.attendances);
      await Future<void>.delayed(Duration.zero);

      expect(emitted.whereType<StatsAttendancesLoadingState>().length, 1);
      final loaded = emitted.whereType<StatsAttendancesLoadedState>().last;
      expect(loaded.year, _year);
      expect(loaded.stats.yearlyCount, 0);
      expect(emitted.whereType<StatsWorkoutsLoadedState>(), isEmpty);
      expect(emitted.whereType<StatsDurationLoadedState>(), isEmpty);
      expect(emitted.whereType<StatsHealthLoadedState>(), isEmpty);

      verifyNever(() => mockWorkout.watchAll(_userId));
      verifyNever(() => mockHealth.watchAllProducts());
    });

    test('emits StatsAttendancesErrorState when fetch throws', () async {
      when(
        () => mockAttendance.watchMonth(
          userId: any(named: 'userId'),
          year: any(named: 'year'),
          month: any(named: 'month'),
        ),
      ).thenThrow(Exception('network'));

      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.attendances);
      await Future<void>.delayed(Duration.zero);

      final err = emitted.whereType<StatsAttendancesErrorState>().last;
      expect(err.year, _year);
      expect(emitted.whereType<StatsAttendancesLoadedState>(), isEmpty);
    });
  });

  group('loadTab - workouts/duration', () {
    setUp(() {
      _stubMonths(mockAttendance, _userId, _year, overrides: {(_year, 6): _juneDays});
      when(() => mockWorkout.watchAll(_userId)).thenAnswer((_) => Stream.value([_typeA, _typeB]));
    });

    test('loads workouts slice and keeps other slices untouched', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.workouts);
      await Future<void>.delayed(Duration.zero);

      final loaded = emitted.whereType<StatsWorkoutsLoadedState>().last;
      expect(loaded.year, _year);
      expect(loaded.stats.yearlyCount, 3);
      expect(loaded.stats.typeDistribution, {'type_a': 2});
      expect(loaded.stats.monthlyDurationAverages[6], 60.0);
      expect(loaded.stats.perTypeDurationAverages['type_a'], 75.0);
      expect(loaded.types, [_typeA, _typeB]);

      expect(emitted.whereType<StatsAttendancesLoadedState>(), isEmpty);
      expect(emitted.whereType<StatsDurationLoadedState>(), isEmpty);
      expect(emitted.whereType<StatsHealthLoadedState>(), isEmpty);
    });

    test('loads duration independently and reuses already fetched source data', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.workouts);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.duration);
      await Future<void>.delayed(Duration.zero);

      verify(() => mockWorkout.watchAll(_userId)).called(1);
      expect(emitted.whereType<StatsWorkoutsLoadedState>(), isNotEmpty);
      final duration = emitted.whereType<StatsDurationLoadedState>().last;
      expect(duration.year, _year);
      expect(duration.types, [_typeA, _typeB]);
    });
  });

  group('loadTab - health', () {
    test('loads health slice only', () async {
      _stubMonths(mockAttendance, _userId, _year);
      when(() => mockWorkout.watchAll(_userId)).thenAnswer((_) => Stream.value([]));
      when(
        () => mockHealth.watchMonthEntries(
          userId: _userId,
          year: _year,
          month: any(named: 'month'),
        ),
      ).thenAnswer((_) => Stream.value([]));
      when(() => mockHealth.watchAllProducts()).thenAnswer(
        (_) => Stream.value([
          const SupplementProduct(
            id: 'p1',
            name: 'Magnesium',
            brand: 'Brand',
            ingredients: [],
            servingsPerDayDefault: 1,
          ),
        ]),
      );

      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.health);
      await Future<void>.delayed(Duration.zero);

      final loaded = emitted.whereType<StatsHealthLoadedState>().last;
      expect(loaded.year, _year);
      expect(emitted.whereType<StatsAttendancesLoadedState>(), isEmpty);
      expect(emitted.whereType<StatsWorkoutsLoadedState>(), isEmpty);
      expect(emitted.whereType<StatsDurationLoadedState>(), isEmpty);

      verifyNever(() => mockWorkout.watchAll(_userId));
    });
  });

  group('loadTab - year switch', () {
    test('ignores stale in-flight load emissions after year change', () async {
      final year2025Completer = Completer<List<AttendanceDay>>();
      when(
        () => mockAttendance.watchMonth(userId: _userId, year: _year - 1, month: 12),
      ).thenAnswer((_) => Stream.fromFuture(year2025Completer.future));
      for (int month = 1; month <= 12; month++) {
        when(
          () => mockAttendance.watchMonth(userId: _userId, year: _year, month: month),
        ).thenAnswer((_) => Stream.value(const []));
        when(
          () => mockAttendance.watchMonth(userId: _userId, year: _year + 1, month: month),
        ).thenAnswer((_) => Stream.value(const []));
      }
      when(
        () => mockAttendance.watchMonth(userId: _userId, year: _year, month: 12),
      ).thenAnswer((_) => Stream.value(const []));

      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      unawaited(sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.attendances));

      sut.initYear(_year + 1);
      await sut.loadTab(userId: _userId, year: _year + 1, tab: StatsTabKind.attendances);
      year2025Completer.complete(const []);
      await Future<void>.delayed(Duration.zero);

      // No Loaded state was emitted for the stale (older) year.
      final loaded = emitted.whereType<StatsAttendancesLoadedState>().toList();
      expect(loaded.where((s) => s.year == _year), isEmpty);
      expect(loaded.last.year, _year + 1);
    });
  });
}
