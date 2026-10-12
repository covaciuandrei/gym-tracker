// Unit tests for AppleHealthRepository — reads Apple Health once per calendar
// day and serves every other read that day from the cached snapshot.
//
// Run: flutter test test/data/health_insights/apple_health_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/health_insights/apple_health_repository.dart';
import 'package:gym_tracker/data/health_insights/health_cache_store.dart';
import 'package:gym_tracker/data/health_insights/health_snapshot.dart';
import 'package:gym_tracker/data/health_insights/healthkit_source.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:mocktail/mocktail.dart';

class MockHealthKitSource extends Mock implements HealthKitSource {}

class MockHealthCacheStore extends Mock implements HealthCacheStore {}

HealthSample _weight(DateTime date, double kg) =>
    HealthSample(metric: HealthMetric.bodyMass, value: kg, unit: 'kg', dateFrom: date, dateTo: date, sourceName: HealthKitSource.sourceName);

HealthSnapshot _snapshotFetchedAt(DateTime fetchedAt) => HealthSnapshot(
  fetchedAt: fetchedAt,
  characteristics: const HealthCharacteristics(sex: Sex.male),
  samples: {
    HealthMetric.bodyMass: [_weight(DateTime(2026, 9, 30), 72)],
  },
);

void main() {
  late MockHealthKitSource source;
  late MockHealthCacheStore store;
  late DateTime now;
  late AppleHealthRepository repository;

  setUpAll(() {
    registerFallbackValue(HealthMetric.bodyMass);
    registerFallbackValue(DateTime(2026));
    registerFallbackValue(_snapshotFetchedAt(DateTime(2026)));
  });

  setUp(() {
    source = MockHealthKitSource();
    store = MockHealthCacheStore();
    now = DateTime(2026, 10, 9, 9, 30);
    repository = AppleHealthRepository(source, store, clock: () => now);

    when(() => store.read()).thenAnswer((_) async => null);
    when(() => store.write(any())).thenAnswer((_) async {});
    when(() => store.delete()).thenAnswer((_) async {});
    when(() => source.characteristics()).thenAnswer((_) async => const HealthCharacteristics(sex: Sex.female));
    when(
      () => source.samples(
        any(),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    ).thenAnswer(
      (invocation) async => invocation.positionalArguments.first == HealthMetric.bodyMass
          ? [_weight(DateTime(2026, 9, 1), 71), _weight(DateTime(2026, 10, 1), 70.5)]
          : const <HealthSample>[],
    );
  });

  void verifyFetchedOnce() {
    for (final metric in HealthKitSource.units.keys) {
      verify(
        () => source.samples(
          metric,
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).called(1);
    }
    verify(() => source.characteristics()).called(1);
  }

  test('first read fetches every metric for the last 24 months and saves the snapshot', () async {
    final weight = await repository.samples(HealthMetric.bodyMass);

    expect(weight.map((s) => s.value), [71, 70.5]);
    for (final metric in HealthKitSource.units.keys) {
      verify(() => source.samples(metric, from: DateTime(2024, 10, 9), to: now)).called(1);
    }
    final saved = verify(() => store.write(captureAny())).captured.single as HealthSnapshot;
    expect(saved.fetchedAt, now);
  });

  test('later reads the same day never touch Apple Health again', () async {
    await repository.samples(HealthMetric.bodyMass);
    now = DateTime(2026, 10, 9, 22);
    await repository.samples(HealthMetric.vo2Max);
    final characteristics = await repository.characteristics();

    expect(characteristics?.sex, Sex.female);
    verifyFetchedOnce();
  });

  test('a snapshot saved earlier today is reused after an app restart', () async {
    when(() => store.read()).thenAnswer((_) async => _snapshotFetchedAt(DateTime(2026, 10, 9, 7)));

    final weight = await repository.samples(HealthMetric.bodyMass);

    expect(weight.single.value, 72);
    verifyNever(
      () => source.samples(
        any(),
        from: any(named: 'from'),
        to: any(named: 'to'),
      ),
    );
    verifyNever(() => store.write(any()));
  });

  test("yesterday's saved snapshot is replaced on the first read of a new day", () async {
    when(() => store.read()).thenAnswer((_) async => _snapshotFetchedAt(DateTime(2026, 10, 8, 23, 59)));

    final weight = await repository.samples(HealthMetric.bodyMass);

    expect(weight.map((s) => s.value), [71, 70.5]);
    verifyFetchedOnce();
  });

  test('the in-memory snapshot expires at midnight', () async {
    await repository.samples(HealthMetric.bodyMass);
    now = DateTime(2026, 10, 10, 0, 5);
    await repository.samples(HealthMetric.bodyMass);

    verify(() => source.characteristics()).called(2);
  });

  test('clearCache deletes the saved snapshot and the next read queries Apple Health again', () async {
    await repository.samples(HealthMetric.bodyMass);
    await repository.clearCache();
    await repository.samples(HealthMetric.bodyMass);

    verify(() => store.delete()).called(1);
    verify(() => source.characteristics()).called(2);
  });

  test('concurrent reads share one Apple Health fetch', () async {
    await Future.wait([repository.samples(HealthMetric.bodyMass), repository.samples(HealthMetric.leanBodyMass), repository.characteristics()]);

    verifyFetchedOnce();
  });

  test('filters the snapshot by from/to', () async {
    final september = await repository.samples(HealthMetric.bodyMass, from: DateTime(2026, 9, 1), to: DateTime(2026, 9, 30));

    expect(september.single.value, 71);
  });
}
