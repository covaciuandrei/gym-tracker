// Unit tests for BaseCubit
//
// Covers:
//   - guardedAction() emits PendingState then delegates to the action body.
//   - guardedAction() is a no-op when the cubit is already in PendingState
//     (reentrancy guard: the action callback is never invoked).
//   - safeEmit() does not throw after the cubit is closed.
//
// Run:  flutter test test/cubit/base_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';

// ─── Test double ──────────────────────────────────────────────────────────

class _TestSuccessState extends BaseState {
  const _TestSuccessState();
}

/// Minimal concrete subclass so we can instantiate BaseCubit directly.
class _TestCubit extends BaseCubit {}

// ─── Tests ────────────────────────────────────────────────────────────────

void main() {
  group('BaseCubit.guardedAction', () {
    late _TestCubit sut;

    setUp(() => sut = _TestCubit());
    tearDown(() => sut.close());

    test('emits PendingState then terminal state from action', () async {
      final future = expectLater(
        sut.stream,
        emitsInOrder([const PendingState(), const _TestSuccessState()]),
      );

      await sut.guardedAction(() async {
        sut.safeEmit(const _TestSuccessState());
      });

      await future;
    });

    test(
      'is a no-op when already in PendingState (reentrancy guard)',
      () async {
        var actionCallCount = 0;

        // Prime the cubit into PendingState.
        sut.safeEmit(const PendingState());

        // A second call while pending must not invoke the action.
        await sut.guardedAction(() async {
          actionCallCount++;
        });

        expect(actionCallCount, 0);
        // State must remain PendingState — nothing was emitted.
        expect(sut.state, const PendingState());
      },
    );

    test('allows a second call after the action completes', () async {
      int actionCallCount = 0;

      await sut.guardedAction(() async {
        actionCallCount++;
        sut.safeEmit(const _TestSuccessState());
      });

      await sut.guardedAction(() async {
        actionCallCount++;
        sut.safeEmit(const _TestSuccessState());
      });

      expect(actionCallCount, 2);
    });
  });

  group('BaseCubit.safeEmit', () {
    test('does not throw when cubit is closed', () async {
      final sut = _TestCubit();
      await sut.close();
      expect(() => sut.safeEmit(const _TestSuccessState()), returnsNormally);
    });
  });
}
