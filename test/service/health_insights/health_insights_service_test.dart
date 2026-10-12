// Unit tests for HealthInsightsService — the orchestrator that resolves the
// user's profile (self-reported first, HealthKit characteristics as
// fallback), fetches every metric from the repository, and composes the
// five analyzers' outputs into one HealthInsightsResult.
//
// Uses the REAL MockHealthRepository (backed by the anonymized test fixtures
// extracted from a sample Apple Health export) and REAL analyzer instances, so
// this also exercises the whole pipeline end-to-end against realistic data.
//
// Run: flutter test test/service/health_insights/health_insights_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/model/user.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/health_insights/body_composition_analyzer.dart';
import 'package:gym_tracker/service/health_insights/cardio_fitness_analyzer.dart';
import 'package:gym_tracker/service/health_insights/heart_rate_recovery_analyzer.dart';
import 'package:gym_tracker/service/health_insights/health_insights_service.dart';
import 'package:gym_tracker/service/health_insights/metabolic_analyzer.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';
import 'package:gym_tracker/service/health_insights/stress_index_analyzer.dart';
import 'package:gym_tracker/service/user/user_service.dart';
import 'package:mocktail/mocktail.dart';

import '../../data/health_insights/fixture_loader.dart';
import '../../data/health_insights/mock_health_repository.dart';

class MockUserService extends Mock implements UserService {}

class MockAuthService extends Mock implements AuthService {}

class _EmptyHealthRepository extends Mock implements HealthRepository {}

User _user({Sex? sex, DateTime? birthDate, double? heightCm, double? weightKg}) => User(
  id: 'user_1',
  email: 'user@test.com',
  displayName: 'User',
  theme: 'dark',
  language: 'en',
  currency: 'EUR',
  lastLoginAt: DateTime(2026),
  createdAt: DateTime(2026),
  totalAttendances: 0,
  sex: sex,
  birthDate: birthDate,
  heightCm: heightCm,
  weightKg: weightKg,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockUserService userService;
  late MockAuthService authService;
  late HealthInsightsService service;

  HealthInsightsService serviceWith(HealthRepository repository) {
    const norms = PopulationNorms();
    return HealthInsightsService(
      repository,
      userService,
      authService,
      BodyCompositionAnalyzer(norms),
      CardioFitnessAnalyzer(norms),
      const HeartRateRecoveryAnalyzer(),
      const StressIndexAnalyzer(),
      MetabolicAnalyzer(),
    );
  }

  setUpAll(() => registerFallbackValue(HealthMetric.bodyMass));

  setUp(() {
    userService = MockUserService();
    authService = MockAuthService();
    when(() => authService.currentUserId).thenReturn('user_1');
    service = serviceWith(MockHealthRepository(HealthInsightsFixtureLoader()));
  });

  test('loads a full result using the profile stored on the user account', () async {
    when(
      () => userService.getById(userId: 'user_1'),
    ).thenAnswer((_) async => _user(sex: Sex.male, birthDate: DateTime(2000, 1, 1), heightCm: 178, weightKg: 70));

    final result = await service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear);

    expect(result.overview.heightCm, 178);
    expect(result.bodyComposition, isNotNull);
    expect(result.cardioFitness, isNotNull);
    expect(result.heartRateRecovery, isNotNull);
    expect(result.metabolic, isNotNull);
    // Fixture baseline: current weight ~70.7kg (2026-05-02).
    expect(result.overview.weightKg, closeTo(70.7, 0.5));
  });

  test('falls back to HealthKit characteristics + latest Height sample when the profile has none set', () async {
    when(() => userService.getById(userId: 'user_1')).thenAnswer((_) async => _user());

    final result = await service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear);

    // characteristics.json carries sex=male / birthDate=2000-01-01;
    // height.json carries the real 178cm reading — both are fallbacks.
    expect(result.overview.heightCm, 178);
    expect(result.cardioFitness?.benchmark, isNotNull);
  });

  test('missing profile document (signed out) still resolves via HealthKit characteristics', () async {
    when(() => authService.currentUserId).thenReturn(null);

    final result = await service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear);

    expect(result.cardioFitness?.benchmark, isNotNull);
  });

  test('self-reported profile values take priority over HealthKit characteristics', () async {
    // A different birth date than the fixture's 2000-01-01 — the
    // self-reported value must win so the age math uses it.
    when(() => userService.getById(userId: 'user_1')).thenAnswer((_) async => _user(sex: Sex.female, birthDate: DateTime(1990, 1, 1), heightCm: 165));

    final result = await service.load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear);

    expect(result.overview.heightCm, 165);
    expect(result.overview.age, DateTime.now().year - 1990);
  });

  test('reports no Apple Health data (and drops the cached snapshot) when nothing comes back', () async {
    final repository = _EmptyHealthRepository();
    when(repository.requestAuthorization).thenAnswer((_) async => true);
    when(repository.characteristics).thenAnswer((_) async => const HealthCharacteristics());
    when(
      () => repository.samples(
        any(),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer((_) async => const []);
    when(repository.clearCache).thenAnswer((_) async {});
    when(() => userService.getById(userId: 'user_1')).thenAnswer((_) async => _user(sex: Sex.male, heightCm: 178));

    await expectLater(
      serviceWith(repository).load(comparisonMode: ComparisonMode.population, comparisonWindow: ComparisonWindow.oneYear),
      throwsA(isA<HealthPermissionDeniedException>()),
    );
    verify(repository.clearCache).called(1);
  });
}
