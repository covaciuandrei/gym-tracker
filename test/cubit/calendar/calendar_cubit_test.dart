// Unit tests for CalendarCubit
//
// STRATEGY: mock AttendanceService, verify emitted states via cubit.stream.
//
// Run:  flutter test test/cubit/calendar/calendar_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/calendar/calendar_cubit.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/gym_membership.dart';
import 'package:gym_tracker/service/attendance/attendance_service.dart';
import 'package:gym_tracker/service/health/health_service.dart';
import 'package:gym_tracker/service/membership/gym_membership_service.dart';
import 'package:gym_tracker/service/membership/membership_reminder_service.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';
import 'package:mocktail/mocktail.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockAttendanceService extends Mock implements AttendanceService {}

class MockHealthService extends Mock implements HealthService {}

class MockWorkoutService extends Mock implements WorkoutService {}

class MockGymMembershipService extends Mock implements GymMembershipService {}

class MockMembershipReminderService extends Mock implements MembershipReminderService {}

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

final _membership = GymMembership(
  id: 'membership_1',
  gymName: 'Test Gym',
  startDate: DateTime(2025, 6, 1),
  durationMonths: 1,
  validUntil: DateTime(2025, 7, 1),
  priceMinor: 15000,
  currency: 'RON',
);

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeAttendanceDay());
  });

  late MockAttendanceService mockService;
  late MockHealthService mockHealthService;
  late MockWorkoutService mockWorkoutService;
  late MockGymMembershipService mockMembershipService;
  late MockMembershipReminderService mockReminderService;
  late CalendarCubit sut;

  setUp(() {
    mockService = MockAttendanceService();
    mockHealthService = MockHealthService();
    mockWorkoutService = MockWorkoutService();
    mockMembershipService = MockGymMembershipService();
    mockReminderService = MockMembershipReminderService();

    // Stub the health and workout service methods that CalendarCubit calls
    when(
      () => mockHealthService.watchMonthEntries(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) => Stream.value([]));

    // Background prefetch for prev/next months uses one-shot get*() calls.
    when(
      () => mockService.getMonth(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) async => <AttendanceDay>[]);
    when(
      () => mockHealthService.getMonthEntries(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        month: any(named: 'month'),
      ),
    ).thenAnswer((_) async => []);

    when(() => mockHealthService.watchAllProducts()).thenAnswer((_) => Stream.value([]));

    when(() => mockWorkoutService.watchAll(any<String>())).thenAnswer((_) => Stream.value([]));

    when(() => mockMembershipService.getRelevant(userId: any(named: 'userId'))).thenAnswer((_) async => null);
    when(() => mockReminderService.isPermanentlyDismissed(userId: any(named: 'userId'))).thenAnswer((_) async => false);
    when(
      () => mockReminderService.remainingInitialDelay(accountCreatedAt: any(named: 'accountCreatedAt')),
    ).thenReturn(Duration.zero);

    sut = CalendarCubit(mockService, mockHealthService, mockWorkoutService, mockMembershipService, mockReminderService);
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

    test('degrades a stream error to an empty loaded state', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.error(Exception('network')));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<CalendarMonthLoadedState>().having((state) => state.days, 'days', isEmpty),
        ]),
      );
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await future;
    });
  });

  group('loadMembershipOverview', () {
    test('adds checked membership data to the current calendar state', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.value([]));
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await sut.stream.where((state) => state is CalendarMonthLoadedState).cast<CalendarMonthLoadedState>().first;

      when(() => mockMembershipService.getRelevant(userId: _userId)).thenAnswer((_) async => _membership);
      final updatedState = sut.stream
          .where((state) => state is CalendarMonthLoadedState)
          .cast<CalendarMonthLoadedState>()
          .firstWhere((state) => state.membershipChecked);

      await sut.loadMembershipOverview(userId: _userId);
      final state = await updatedState;

      expect(state.membership, _membership);
      expect(state.membershipChecked, isTrue);
      expect(state.membershipReminderEligible, isTrue);
      expect(state.membershipReminderDismissed, isFalse);
    });

    test('keeps a missing-membership reminder ineligible during the new-account grace period', () async {
      final accountCreatedAt = DateTime(2026, 7, 21, 10);
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockReminderService.remainingInitialDelay(accountCreatedAt: accountCreatedAt),
      ).thenReturn(const Duration(hours: 1));
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await sut.stream.where((state) => state is CalendarMonthLoadedState).cast<CalendarMonthLoadedState>().first;

      final updatedState = sut.stream
          .where((state) => state is CalendarMonthLoadedState)
          .cast<CalendarMonthLoadedState>()
          .firstWhere((state) => state.membershipChecked);
      await sut.loadMembershipOverview(userId: _userId, accountCreatedAt: accountCreatedAt);
      final state = await updatedState;

      expect(state.membership, isNull);
      expect(state.membershipReminderEligible, isFalse);
    });

    test('permanent dismissal is reflected in the loaded calendar state', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.value([]));
      when(() => mockReminderService.isPermanentlyDismissed(userId: _userId)).thenAnswer((_) async => true);
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await sut.stream.where((state) => state is CalendarMonthLoadedState).cast<CalendarMonthLoadedState>().first;

      final updatedState = sut.stream
          .where((state) => state is CalendarMonthLoadedState)
          .cast<CalendarMonthLoadedState>()
          .firstWhere((state) => state.membershipChecked);
      await sut.loadMembershipOverview(userId: _userId);
      final state = await updatedState;

      expect(state.membershipReminderDismissed, isTrue);
    });

    test('dismissMembershipReminder persists and re-emits the calendar state', () async {
      when(
        () => mockService.watchMonth(userId: _userId, year: _year, month: _month),
      ).thenAnswer((_) => Stream.value([]));
      when(() => mockReminderService.rememberPermanentDismissal(userId: _userId)).thenAnswer((_) async {});
      sut.loadMonth(userId: _userId, year: _year, month: _month);
      await sut.stream.where((state) => state is CalendarMonthLoadedState).cast<CalendarMonthLoadedState>().first;
      await sut.loadMembershipOverview(userId: _userId);

      final expectation = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<CalendarMonthLoadedState>().having(
            (state) => state.membershipReminderDismissed,
            'membershipReminderDismissed',
            isTrue,
          ),
        ]),
      );
      await sut.dismissMembershipReminder(userId: _userId);
      await expectation;
      verify(() => mockReminderService.rememberPermanentDismissal(userId: _userId)).called(1);
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
