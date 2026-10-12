// Widget tests for HealthInsightsPage.
//
// Tests inject a MockHealthInsightsCubit via BlocProvider.value to avoid
// getIt setup and real Health data loading.
//
// Run: flutter test test/presentation/pages/health_insights/health_insights_page_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health_insights/health_insights_cubit.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_insights_result.dart';
import 'package:gym_tracker/model/health_insights/physical_overview.dart';
import 'package:gym_tracker/presentation/pages/health_insights/health_insights_page.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthInsightsCubit extends Mock implements HealthInsightsCubit {}

Widget _buildApp(HealthInsightsCubit cubit) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: BlocProvider<HealthInsightsCubit>.value(value: cubit, child: const HealthInsightsPage()),
);

MockHealthInsightsCubit _cubitWith(BaseState state) {
  final cubit = MockHealthInsightsCubit();
  when(() => cubit.state).thenReturn(state);
  when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
  when(() => cubit.load()).thenAnswer((_) async {});
  when(() => cubit.refresh()).thenAnswer((_) async {});
  return cubit;
}

void main() {
  testWidgets('shows a skeleton while pending', (tester) async {
    final cubit = _cubitWith(const PendingState());

    await tester.pumpWidget(_buildApp(cubit));
    await tester.pump();

    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('renders the overview and all four insight cards when ready', (tester) async {
    // The 5 stacked cards don't all fit in the default test surface height,
    // and ListView only builds what's in the viewport — grow the surface so
    // every card is built without needing to scroll.
    tester.view.physicalSize = const Size(400, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final result = HealthInsightsResult(
      overview: PhysicalOverview(asOf: DateTime(2026, 7, 24), heightCm: 178, weightKg: 70.7),
      comparisonMode: ComparisonMode.population,
      comparisonWindow: ComparisonWindow.oneYear,
    );
    final cubit = _cubitWith(HealthInsightsReadyState(result: result));

    await tester.pumpWidget(_buildApp(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Physical Overview'), findsOneWidget);
    expect(find.text('Body Recomposition'), findsOneWidget);
    expect(find.text('Cardio Fitness (VO2Max)'), findsOneWidget);
    expect(find.text('Heart Rate Recovery'), findsOneWidget);
    expect(find.text('Resting Energy & TDEE'), findsOneWidget);
  });

  testWidgets('shows a no-Apple-Health-data state whose retry re-reads Apple Health', (tester) async {
    final cubit = _cubitWith(const HealthInsightsPermissionDeniedState());

    await tester.pumpWidget(_buildApp(cubit));
    await tester.pumpAndSettle();

    expect(find.text('No Apple Health data'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();
    verify(() => cubit.refresh()).called(1);
    verifyNever(() => cubit.load());
  });

  testWidgets('shows a generic error state with retry', (tester) async {
    final cubit = _cubitWith(const SomethingWentWrongState());

    await tester.pumpWidget(_buildApp(cubit));
    await tester.pumpAndSettle();

    expect(find.text('Something went wrong. Please try again.'), findsWidgets);

    await tester.tap(find.text('Try Again'));
    await tester.pump();
    verify(() => cubit.load()).called(1);
  });
}
