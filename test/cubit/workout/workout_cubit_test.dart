// Unit tests for WorkoutCubit
//
// STRATEGY: mock WorkoutService, verify emitted states via cubit.stream.
// Stream-based methods (loadTypes) set up a StreamSubscription; the test uses
// Stream.value([...]) so the event arrives on the next microtask.
// The pattern is:
//   1. final future = expectLater(sut.stream, emitsInOrder([...]));
//   2. call the method (sync or async)
//   3. await future
//
// Run:  flutter test test/cubit/workout/workout_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/workout/workout_cubit.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────

class MockWorkoutService extends Mock implements WorkoutService {}

class _FakeTrainingType extends Fake implements TrainingType {}

// ─── Fixtures ─────────────────────────────────────────────────────────────

const _userId = 'user_001';

final _typeA = TrainingType(
  id: 'type_a',
  name: 'Chest',
  color: '#FF5733',
  icon: '🏋️',
);

final _typeB = TrainingType(
  id: 'type_b',
  name: 'Cardio',
  color: '#00FF00',
);

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTrainingType());
  });

  late MockWorkoutService mockService;
  late WorkoutCubit sut;

  setUp(() {
    mockService = MockWorkoutService();
    sut = WorkoutCubit(mockService);
  });

  tearDown(() => sut.close());

  // ─── loadTypes ────────────────────────────────────────────────────────

  group('loadTypes', () {
    test('emits pending then WorkoutTypesLoadedState with types', () async {
      when(() => mockService.watchAll(_userId))
          .thenAnswer((_) => Stream.value([_typeA, _typeB]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<WorkoutTypesLoadedState>()
              .having((s) => s.types, 'types', [_typeA, _typeB]),
        ]),
      );
      sut.loadTypes(_userId);
      await future;
    });

    test('emits pending then WorkoutTypesLoadedState with empty list', () async {
      when(() => mockService.watchAll(_userId))
          .thenAnswer((_) => Stream.value([]));

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<WorkoutTypesLoadedState>().having((s) => s.types, 'types', isEmpty),
        ]),
      );
      sut.loadTypes(_userId);
      await future;
    });

    test('emits pending then somethingWentWrong on stream error', () async {
      when(() => mockService.watchAll(_userId))
          .thenAnswer((_) => Stream.error(Exception('network')));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      sut.loadTypes(_userId);
      await future;
    });
  });

  // ─── createType ───────────────────────────────────────────────────────

  group('createType', () {
    test('emits pending then WorkoutTypeCreatedState with generated id',
        () async {
      when(() => mockService.create(_userId, _typeA))
          .thenAnswer((_) async => 'new_doc_id');

      final future = expectLater(
        sut.stream,
        emitsInOrder([
          const PendingState(),
          isA<WorkoutTypeCreatedState>()
              .having((s) => s.id, 'id', 'new_doc_id'),
        ]),
      );
      await sut.createType(_userId, _typeA);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.create(_userId, _typeA))
          .thenThrow(Exception('firestore'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.createType(_userId, _typeA);
      await future;
    });
  });

  // ─── deleteType ───────────────────────────────────────────────────────

  group('deleteType', () {
    test('emits pending then WorkoutTypeDeletedState', () async {
      when(() => mockService.delete(_userId, _typeA.id))
          .thenAnswer((_) async {});

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const WorkoutTypeDeletedState()]),
      );
      await sut.deleteType(_userId, _typeA.id);
      await future;
    });

    test('emits somethingWentWrong on failure', () async {
      when(() => mockService.delete(_userId, _typeA.id))
          .thenThrow(Exception('firestore'));

      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const SomethingWentWrongState()]),
      );
      await sut.deleteType(_userId, _typeA.id);
      await future;
    });
  });
}
