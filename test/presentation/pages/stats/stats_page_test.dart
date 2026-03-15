import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/stats/stats_cubit.dart';
import 'package:gym_tracker/model/attendance_stats.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/pages/stats/stats_page.dart';
import 'package:mocktail/mocktail.dart';

class MockStatsCubit extends Mock implements StatsCubit {}

class MockStackRouter extends Mock implements StackRouter {}

Widget _buildApp({required StatsCubit cubit, required StackRouter router}) {
  return StackRouterScope(
    controller: router,
    stateHash: 0,
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<StatsCubit>.value(
        value: cubit,
        child: const StatsView(userId: 'user-1'),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    registerFallbackValue(StatsTabKind.attendances);
  });

  MockStatsCubit stubCubit(Stream<BaseState> stream) {
    final cubit = MockStatsCubit();
    when(() => cubit.state).thenReturn(const InitialState());
    when(() => cubit.stream).thenAnswer((_) => stream);
    when(() => cubit.initYear(any())).thenReturn(null);
    when(
      () => cubit.loadTab(
        userId: any(named: 'userId'),
        year: any(named: 'year'),
        tab: any(named: 'tab'),
        force: any(named: 'force'),
      ),
    ).thenAnswer((_) async {});
    return cubit;
  }

  AttendanceStats sampleStats() {
    return const AttendanceStats(
      totalCount: 20,
      yearlyCount: 20,
      monthlyCount: 5,
      currentWeekStreak: 2,
      bestWeekStreak: 6,
      currentStreakInfo: StreakInfo(count: 2, startDate: '2024-01-01', endDate: '2024-01-14'),
      bestStreakInfo: StreakInfo(count: 6, startDate: '2024-02-01', endDate: '2024-03-14'),
      favoriteDaysOfWeek: [1],
      favoriteDayCount: 5,
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
    final cubit = stubCubit(controller.stream);
    final router = MockStackRouter();
    when(() => router.canPop()).thenReturn(false);

    await tester.pumpWidget(_buildApp(cubit: cubit, router: router));

    controller.add(
      StatsLoadedState(
        year: DateTime.now().year,
        attendancesStatus: StatsLoadStatus.loaded,
        workoutsStatus: StatsLoadStatus.loaded,
        durationStatus: StatsLoadStatus.loaded,
        healthStatus: StatsLoadStatus.loaded,
        attendancesStats: sampleStats(),
        workoutsStats: sampleStats(),
        durationStats: sampleStats(),
        healthStats: sampleStats(),
        types: [
          TrainingType(id: 't1', name: 'Strength', color: '#6366f1', icon: '🏋️'),
          TrainingType(id: 't2', name: 'Cardio', color: '#10b981', icon: '🏃'),
        ],
      ),
    );
    await tester.pump();

    expect(find.text('Attendances'), findsWidgets);
    expect(find.text('Workout'), findsWidgets);
    expect(find.text('Duration'), findsWidgets);
    expect(find.text('Health'), findsWidgets);
  });
}
