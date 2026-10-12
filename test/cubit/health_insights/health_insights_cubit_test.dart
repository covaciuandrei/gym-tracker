import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health_insights/health_insights_cubit.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_insights_result.dart';
import 'package:gym_tracker/model/health_insights/physical_overview.dart';
import 'package:gym_tracker/service/health_insights/health_insights_service.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthInsightsService extends Mock implements HealthInsightsService {}

HealthInsightsResult _result() => HealthInsightsResult(
  overview: PhysicalOverview(asOf: DateTime(2026), heightCm: 178),
  comparisonMode: ComparisonMode.population,
  comparisonWindow: ComparisonWindow.oneYear,
);

void main() {
  late MockHealthInsightsService service;
  late HealthInsightsCubit cubit;

  setUpAll(() {
    registerFallbackValue(ComparisonMode.population);
    registerFallbackValue(ComparisonWindow.oneYear);
  });

  setUp(() {
    service = MockHealthInsightsService();
    cubit = HealthInsightsCubit(service);
  });

  tearDown(() => cubit.close());

  test('load always compares against population norms over a 1-year window', () async {
    when(
      () => service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear),
    ).thenAnswer((_) async => _result());

    final expectation = expectLater(cubit.stream, emitsInOrder([const PendingState(), isA<HealthInsightsReadyState>()]));

    await cubit.load();
    await expectation;

    verify(() => service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear)).called(1);
  });

  test('load maps HealthPermissionDeniedException to a dedicated state', () async {
    when(
      () => service.load(
        comparisonMode: any(named: 'comparisonMode'),
        comparisonWindow: any(named: 'comparisonWindow'),
      ),
    ).thenThrow(const HealthPermissionDeniedException());

    final expectation = expectLater(cubit.stream, emitsInOrder([const PendingState(), const HealthInsightsPermissionDeniedState()]));

    await cubit.load();
    await expectation;
  });

  test('load maps unexpected errors to SomethingWentWrongState', () async {
    when(
      () => service.load(
        comparisonMode: any(named: 'comparisonMode'),
        comparisonWindow: any(named: 'comparisonWindow'),
      ),
    ).thenThrow(Exception('boom'));

    final expectation = expectLater(cubit.stream, emitsInOrder([const PendingState(), const SomethingWentWrongState()]));

    await cubit.load();
    await expectation;
  });

  test('refresh drops the cached Apple Health snapshot before reloading', () async {
    when(() => service.clearCache()).thenAnswer((_) async {});
    when(
      () => service.load(
        comparisonMode: any(named: 'comparisonMode'),
        comparisonWindow: any(named: 'comparisonWindow'),
      ),
    ).thenAnswer((_) async => _result());

    await cubit.refresh();

    verifyInOrder([
      () => service.clearCache(),
      () => service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear),
    ]);
    expect(cubit.state, isA<HealthInsightsReadyState>());
  });
}
