import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/stats/stats_cubit.dart';
import 'package:gym_tracker/model/attendance_stats.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/pages/stats/stats_page.dart';

class MockStatsCubit extends Mock implements StatsCubit {}

void main() {
  MockStatsCubit _stubCubit(Stream<BaseState> stream) {
    final cubit = MockStatsCubit();
    when(() => cubit.state).thenReturn(const InitialState());
    when(() => cubit.stream).thenAnswer((_) => stream);
    when(
      () => cubit.load(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
      ),
    ).thenAnswer((_) async {});
    return cubit;
  }

  AttendanceStats _sampleStats() {
    return const AttendanceStats(
      totalCount: 20,
      yearlyCount: 20,
      monthlyCount: 5,
      currentWeekStreak: 2,
      bestWeekStreak: 6,
      favoriteDaysOfWeek: [1],
      weekdayAttendanceCounts: [5, 3, 2, 4, 3, 2, 1],
      monthlyAttendanceCounts: [2, 1, 3, 2, 4, 1, 0, 2, 1, 2, 1, 1],
      typeDistribution: {'t1': 10, 't2': 5},
      monthlyTypeDistribution: {
        1: {'t1': 2, 't2': 1},
      },
      monthlyDurationAverages: {1: 45},
      monthlyTypeDurationAverages: {
        1: {'t1': 50, 't2': 40},
      },
      perTypeDurationAverages: {'t1': 50, 't2': 40},
      yearlyAverageDurationMinutes: 47,
      yearlyUntrackedDurationCount: 3,
      monthlyUntrackedDurationCounts: [1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0],
      healthTotalLogs: 12,
      healthConsistencyPct: 30,
      monthlyHealthServings: [4, 2, 1, 0, 1, 0, 0, 0, 1, 2, 0, 1],
      mostTakenSupplementName: 'Magnesium',
      mostTakenSupplementBrand: 'Brand',
      mostTakenSupplementCount: 8,
      monthlySupplementServings: {
        1: {'p1': 4},
      },
      productNames: {'p1': 'Magnesium'},
      productBrands: {'p1': 'Brand'},
      topNutrients: [NutrientTotal(name: 'Magnesium', amount: 320, unit: 'mg')],
    );
  }

  testWidgets('StatsView renders tabs and loaded content', (tester) async {
    final controller = StreamController<BaseState>.broadcast(sync: true);
    addTearDown(controller.close);
    final cubit = _stubCubit(controller.stream);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<StatsCubit>.value(
          value: cubit,
          child: const StatsView(userId: 'user-1'),
        ),
      ),
    );

    controller.add(
      StatsLoadedState(
        stats: _sampleStats(),
        year: DateTime.now().year,
        types: const [
          TrainingType(
            id: 't1',
            name: 'Strength',
            color: '#6366f1',
            icon: '🏋️',
          ),
          TrainingType(id: 't2', name: 'Cardio', color: '#10b981', icon: '🏃'),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Attendances'), findsWidgets);
    expect(find.text('Workouts'), findsWidgets);
    expect(find.text('Duration'), findsWidgets);
    expect(find.text('Health'), findsWidgets);
    expect(find.text('Magnesium'), findsWidgets);
  });
}
