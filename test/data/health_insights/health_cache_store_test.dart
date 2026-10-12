// Unit tests for HealthCacheStore — the JSON file behind the daily Apple
// Health cache.
//
// Run: flutter test test/data/health_insights/health_cache_store_test.dart

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/health_insights/health_cache_store.dart';
import 'package:gym_tracker/data/health_insights/health_snapshot.dart';
import 'package:gym_tracker/data/health_insights/healthkit_source.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';

void main() {
  late Directory directory;
  late HealthCacheStore store;

  final snapshot = HealthSnapshot(
    fetchedAt: DateTime(2026, 10, 9, 9, 30),
    characteristics: HealthCharacteristics(sex: Sex.male, birthDate: DateTime(2000, 1, 1)),
    samples: {
      HealthMetric.bodyMass: [
        HealthSample(
          metric: HealthMetric.bodyMass,
          value: 70.7,
          unit: 'kg',
          dateFrom: DateTime(2026, 10, 1, 8),
          dateTo: DateTime(2026, 10, 1, 8),
          sourceName: HealthKitSource.sourceName,
        ),
      ],
      HealthMetric.activeEnergyBurned: [
        HealthSample(
          metric: HealthMetric.activeEnergyBurned,
          value: 512.5,
          unit: 'Cal',
          dateFrom: DateTime(2026, 10, 1),
          dateTo: DateTime(2026, 10, 2),
          sourceName: HealthKitSource.sourceName,
        ),
      ],
      HealthMetric.vo2Max: const [],
    },
  );

  File cacheFile() => File('${directory.path}/health_insights_cache.json');

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('health_cache_store_test');
    store = HealthCacheStore(directory: () async => directory);
  });

  tearDown(() => directory.delete(recursive: true));

  test('returns null when nothing has been cached yet', () async {
    expect(await store.read(), isNull);
  });

  test('round-trips a snapshot', () async {
    await store.write(snapshot);
    final restored = await store.read();

    expect(restored, isNotNull);
    expect(restored!.fetchedAt, snapshot.fetchedAt);
    expect(restored.characteristics, snapshot.characteristics);
    expect(restored.samples, snapshot.samples);
  });

  test('treats an unreadable file as a miss and deletes it', () async {
    await cacheFile().writeAsString('{not json');

    expect(await store.read(), isNull);
    expect(cacheFile().existsSync(), isFalse);
  });

  test('treats a file written by another cache version as a miss', () async {
    await cacheFile().writeAsString('{"version": 0}');

    expect(await store.read(), isNull);
  });

  test('delete removes the cached file', () async {
    await store.write(snapshot);
    await store.delete();

    expect(cacheFile().existsSync(), isFalse);
  });
}
