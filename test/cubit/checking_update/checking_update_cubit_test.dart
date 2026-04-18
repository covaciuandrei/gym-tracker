// Unit tests for CheckingUpdateCubit.

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/checking_update/checking_update_cubit.dart';
import 'package:gym_tracker/service/checking_update/checking_update_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockService extends Mock implements CheckingUpdateService {}

void main() {
  late _MockService service;
  late CheckingUpdateCubit sut;

  setUp(() {
    service = _MockService();
    when(() => service.latestVersion).thenReturn('3.0.0');
    sut = CheckingUpdateCubit(service);
  });

  tearDown(() => sut.close());

  group('evaluate', () {
    test('emits CheckingUpdateIdleState when the service says no big update', () async {
      when(() => service.shouldShowBigUpdate()).thenAnswer((_) async => false);

      final emitted = expectLater(sut.stream, emitsInOrder([isA<CheckingUpdateIdleState>()]));

      await sut.evaluate(presentationDelay: Duration.zero);
      await emitted;
    });

    test('emits CheckingUpdateShowSheetState with the latest version when eligible', () async {
      when(() => service.shouldShowBigUpdate()).thenAnswer((_) async => true);

      final emitted = expectLater(
        sut.stream,
        emitsInOrder([
          predicate<BaseState>(
            (s) => s is CheckingUpdateShowSheetState && s.latestVersion == '3.0.0',
            'CheckingUpdateShowSheetState(latestVersion: 3.0.0)',
          ),
        ]),
      );

      await sut.evaluate(presentationDelay: Duration.zero);
      await emitted;
    });

    test('emits CheckingUpdateIdleState when the service throws', () async {
      when(() => service.shouldShowBigUpdate()).thenThrow(Exception('boom'));

      final emitted = expectLater(sut.stream, emitsInOrder([isA<CheckingUpdateIdleState>()]));

      await sut.evaluate(presentationDelay: Duration.zero);
      await emitted;
    });
  });

  group('remindLater', () {
    test('persists dismissal and emits CheckingUpdateDismissedState', () async {
      when(() => service.rememberDismissal()).thenAnswer((_) async {});

      final emitted = expectLater(sut.stream, emitsInOrder([isA<CheckingUpdateDismissedState>()]));

      await sut.remindLater();
      await emitted;

      verify(() => service.rememberDismissal()).called(1);
    });

    test('still emits CheckingUpdateDismissedState when the service throws', () async {
      when(() => service.rememberDismissal()).thenThrow(Exception('boom'));

      final emitted = expectLater(sut.stream, emitsInOrder([isA<CheckingUpdateDismissedState>()]));

      await sut.remindLater();
      await emitted;
    });
  });

  group('updateNow', () {
    test('launches the store URL and emits CheckingUpdateDismissedState', () async {
      when(() => service.launchStoreUrl()).thenAnswer((_) async {});

      final emitted = expectLater(sut.stream, emitsInOrder([isA<CheckingUpdateDismissedState>()]));

      await sut.updateNow();
      await emitted;

      verify(() => service.launchStoreUrl()).called(1);
    });

    test('still emits CheckingUpdateDismissedState when the launcher throws', () async {
      when(() => service.launchStoreUrl()).thenThrow(Exception('boom'));

      final emitted = expectLater(sut.stream, emitsInOrder([isA<CheckingUpdateDismissedState>()]));

      await sut.updateNow();
      await emitted;
    });
  });
}
