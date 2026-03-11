// Unit tests for WorkoutService
//
// STRATEGY: mock TrainingTypeSource (the Firestore access layer).
// WorkoutService is a thin orchestration layer — tests verify:
//   • delegation to the source for happy-path operations
//   • the existence-guard on update() throws TrainingTypeNotFoundException
//
// Run:  flutter test test/service/workout/workout_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/data/remote/training_type/training_type_source.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/service/workout/workout_service.dart';

// ─── Mock ─────────────────────────────────────────────────────────────────

class MockTrainingTypeSource extends Mock implements TrainingTypeSource {}
// Fallback needed for any() on custom types
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

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeTrainingType());
  });

  late MockTrainingTypeSource mockSource;
  late WorkoutService sut;

  setUp(() {
    mockSource = MockTrainingTypeSource();
    sut = WorkoutService(mockSource);
  });

  // ─── watchAll ───────────────────────────────────────────────────────────

  group('watchAll', () {
    test('streams the list returned by source', () {
      when(() => mockSource.watchAll(_userId))
          .thenAnswer((_) => Stream.value([_typeA, _typeB]));

      expect(
        sut.watchAll(_userId),
        emits(hasLength(2)),
      );
    });

    test('streams an empty list when no types exist', () {
      when(() => mockSource.watchAll(_userId))
          .thenAnswer((_) => Stream.value([]));

      expect(
        sut.watchAll(_userId),
        emits(isEmpty),
      );
    });
  });

  // ─── getById ────────────────────────────────────────────────────────────

  group('getById', () {
    test('returns the type returned by source', () async {
      when(() => mockSource.getById(_userId, 'type_a'))
          .thenAnswer((_) async => _typeA);

      final result = await sut.getById(_userId, 'type_a');

      expect(result, _typeA);
    });

    test('returns null when source returns null', () async {
      when(() => mockSource.getById(_userId, 'missing'))
          .thenAnswer((_) async => null);

      final result = await sut.getById(_userId, 'missing');

      expect(result, isNull);
    });
  });

  // ─── create ─────────────────────────────────────────────────────────────

  group('create', () {
    test('delegates to source and returns generated id', () async {
      when(() => mockSource.create(_userId, _typeA))
          .thenAnswer((_) async => 'new_doc_id');

      final id = await sut.create(_userId, _typeA);

      expect(id, 'new_doc_id');
      verify(() => mockSource.create(_userId, _typeA)).called(1);
    });
  });

  // ─── update ─────────────────────────────────────────────────────────────

  group('update', () {
    test('delegates to source when type exists', () async {
      when(() => mockSource.getById(_userId, _typeA.id))
          .thenAnswer((_) async => _typeA);
      when(() => mockSource.update(_userId, _typeA))
          .thenAnswer((_) async {});

      await sut.update(_userId, _typeA);

      verify(() => mockSource.update(_userId, _typeA)).called(1);
    });

    test('throws TrainingTypeNotFoundException when type does not exist',
        () async {
      when(() => mockSource.getById(_userId, _typeA.id))
          .thenAnswer((_) async => null);

      expect(
        () => sut.update(_userId, _typeA),
        throwsA(isA<TrainingTypeNotFoundException>()),
      );
      verifyNever(() => mockSource.update(_userId, _typeA));
    });
  });

  // ─── delete ─────────────────────────────────────────────────────────────

  group('delete', () {
    test('delegates to source', () async {
      when(() => mockSource.delete(_userId, 'type_a'))
          .thenAnswer((_) async {});

      await sut.delete(_userId, 'type_a');

      verify(() => mockSource.delete(_userId, 'type_a')).called(1);
    });
  });
}
