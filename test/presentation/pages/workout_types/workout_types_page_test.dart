import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/workout/workout_cubit.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/pages/workout_types/workout_types_page.dart';

class MockWorkoutCubit extends Mock implements WorkoutCubit {}

Widget _buildApp(WorkoutCubit cubit) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<WorkoutCubit>.value(
      value: cubit,
      child: const WorkoutTypesView(userId: 'user-1'),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(const InitialState());
    registerFallbackValue(
      const TrainingType(id: 'id', name: 'Type', color: '#6366f1', icon: '🏋️'),
    );
  });

  group('WorkoutTypesView', () {
    testWidgets('loads workout types on init', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final cubit = MockWorkoutCubit();
      when(() => cubit.state).thenReturn(const InitialState());
      when(() => cubit.stream).thenAnswer((_) => controller.stream);
      when(() => cubit.loadTypes(any())).thenAnswer((_) async {});
      when(() => cubit.createType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.updateType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.deleteType(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      verify(() => cubit.loadTypes('user-1')).called(1);
    });

    testWidgets('shows loading state', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final cubit = MockWorkoutCubit();
      when(() => cubit.state).thenReturn(const PendingState());
      when(() => cubit.stream).thenAnswer((_) => controller.stream);
      when(() => cubit.loadTypes(any())).thenAnswer((_) async {});
      when(() => cubit.createType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.updateType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.deleteType(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      expect(find.text('Loading workout types...'), findsOneWidget);
    });

    testWidgets('shows empty state after loaded empty list', (tester) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final cubit = MockWorkoutCubit();
      when(() => cubit.state).thenReturn(const PendingState());
      when(() => cubit.stream).thenAnswer((_) => controller.stream);
      when(() => cubit.loadTypes(any())).thenAnswer((_) async {});
      when(() => cubit.createType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.updateType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.deleteType(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      controller.add(const WorkoutTypesLoadedState(types: []));
      await tester.pump();

      expect(find.text('No workout types yet'), findsOneWidget);
      expect(find.text('Create First Type'), findsOneWidget);
    });

    testWidgets('shows list item and deletes after confirmation', (
      tester,
    ) async {
      final controller = StreamController<BaseState>.broadcast(sync: true);
      addTearDown(controller.close);

      final cubit = MockWorkoutCubit();
      when(() => cubit.state).thenReturn(const PendingState());
      when(() => cubit.stream).thenAnswer((_) => controller.stream);
      when(() => cubit.loadTypes(any())).thenAnswer((_) async {});
      when(() => cubit.createType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.updateType(any(), any())).thenAnswer((_) async {});
      when(() => cubit.deleteType(any(), any())).thenAnswer((_) async {});

      await tester.pumpWidget(_buildApp(cubit));
      await tester.pump();

      controller.add(
        const WorkoutTypesLoadedState(
          types: [
            TrainingType(
              id: 't1',
              name: 'Strength',
              color: '#6366f1',
              icon: '🏋️',
            ),
          ],
        ),
      );
      await tester.pump();

      expect(find.text('Strength'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Delete workout type'), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => cubit.deleteType('user-1', 't1')).called(1);
    });
  });
}
