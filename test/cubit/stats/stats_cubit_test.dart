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
    test('emits idle statuses for all mini-pages', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.year, _year);
      expect(state.attendancesStatus, StatsLoadStatus.idle);
      expect(state.workoutsStatus, StatsLoadStatus.idle);
      expect(state.durationStatus, StatsLoadStatus.idle);
      expect(state.healthStatus, StatsLoadStatus.idle);
    });
  });

  group('loadTab - attendances', () {
    test('loads only attendances slice', () async {
      _stubMonths(mockAttendance, _userId, _year);
      when(() => mockWorkout.watchAll(_userId)).thenAnswer((_) => Stream.value([]));

      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.attendances);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.attendancesStatus, StatsLoadStatus.loaded);
      expect(state.attendancesStats?.yearlyCount, 0);
      expect(state.workoutsStatus, StatsLoadStatus.idle);
      expect(state.durationStatus, StatsLoadStatus.idle);
      expect(state.healthStatus, StatsLoadStatus.idle);

      verifyNever(() => mockWorkout.watchAll(_userId));
      verifyNever(() => mockHealth.watchAllProducts());
    });

    test('sets error when attendances loading fails', () async {
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

      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.attendancesStatus, StatsLoadStatus.error);
      expect(state.attendancesStats, isNull);
    });
  });

  group('loadTab - workouts/duration', () {
    setUp(() {
      _stubMonths(mockAttendance, _userId, _year, overrides: {(_year, 6): _juneDays});
      when(() => mockWorkout.watchAll(_userId)).thenAnswer((_) => Stream.value([_typeA, _typeB]));
    });

    test('loads workouts slice and keeps duration idle', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.workouts);
      await Future<void>.delayed(Duration.zero);

      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.workoutsStatus, StatsLoadStatus.loaded);
      expect(state.workoutsStats?.yearlyCount, 3);
      expect(state.workoutsStats?.typeDistribution, {'type_a': 2});
      expect(state.workoutsStats?.monthlyDurationAverages[6], 60.0);
      expect(state.workoutsStats?.perTypeDurationAverages['type_a'], 75.0);
      expect(state.durationStatus, StatsLoadStatus.idle);
      expect(state.durationStats, isNull);
      expect(state.types, [_typeA, _typeB]);
      expect(state.attendancesStatus, StatsLoadStatus.idle);
      expect(state.healthStatus, StatsLoadStatus.idle);
    });

    test('loads duration independently and reuses already fetched source data', () async {
      final emitted = <BaseState>[];
      sut.stream.listen(emitted.add);

      sut.initYear(_year);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.workouts);
      await sut.loadTab(userId: _userId, year: _year, tab: StatsTabKind.duration);
      await Future<void>.delayed(Duration.zero);

      verify(() => mockWorkout.watchAll(_userId)).called(1);
      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.workoutsStatus, StatsLoadStatus.loaded);
      expect(state.durationStatus, StatsLoadStatus.loaded);
      expect(state.durationStats, isNotNull);
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

      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.healthStatus, StatsLoadStatus.loaded);
      expect(state.healthStats, isNotNull);
      expect(state.attendancesStatus, StatsLoadStatus.idle);
      expect(state.workoutsStatus, StatsLoadStatus.idle);
      expect(state.durationStatus, StatsLoadStatus.idle);

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

      final state = emitted.whereType<StatsLoadedState>().last;
      expect(state.year, _year + 1);
      expect(state.attendancesStatus, StatsLoadStatus.loaded);
    });
  });
}
