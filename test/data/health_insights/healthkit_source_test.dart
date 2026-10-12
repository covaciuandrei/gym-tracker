// Unit tests for HealthKitSource — the Dart side of the iOS HealthKitBridge
// method channel.
//
// Run: flutter test test/data/health_insights/healthkit_source_test.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/health_insights/healthkit_source.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/sex.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const source = HealthKitSource();
  final from = DateTime(2024, 10, 9);
  final to = DateTime(2026, 10, 9, 9, 30);
  final calls = <MethodCall>[];
  Object? Function(MethodCall call) reply = (_) => null;

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(HealthKitSource.channel, (call) async {
      calls.add(call);
      return reply(call);
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(HealthKitSource.channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('reads weight as raw samples and maps the points to kg samples', () async {
    final measuredAt = DateTime(2026, 10, 1, 8);
    reply = (_) => [
      [measuredAt.millisecondsSinceEpoch.toDouble(), measuredAt.millisecondsSinceEpoch.toDouble(), 70.7],
    ];

    final samples = await source.samples(HealthMetric.bodyMass, from: from, to: to);

    expect(calls.single.method, 'samples');
    expect(calls.single.arguments, {'metric': 'bodyMass', 'startMs': from.millisecondsSinceEpoch, 'endMs': to.millisecondsSinceEpoch});
    expect(samples.single.value, 70.7);
    expect(samples.single.unit, 'kg');
    expect(samples.single.dateFrom, measuredAt);
  });

  test('reads energy as HealthKit daily totals', () async {
    reply = (_) => <Object?>[];

    await source.samples(HealthMetric.activeEnergyBurned, from: from, to: to);

    expect(calls.single.method, 'dailySums');
  });

  test('reads only the latest height reading', () async {
    reply = (_) => <Object?>[];

    await source.samples(HealthMetric.height, from: from, to: to);

    expect(calls.single.method, 'latestSample');
  });

  test('never asks Apple Health for metrics no card uses', () async {
    final samples = await source.samples(HealthMetric.sleepDeep, from: from, to: to);

    expect(samples, isEmpty);
    expect(calls, isEmpty);
  });

  test('maps characteristics and tolerates missing values', () async {
    reply = (_) => {'sex': 'female', 'birthDate': '1990-05-17'};
    final characteristics = await source.characteristics();
    expect(characteristics.sex, Sex.female);
    expect(characteristics.birthDate, DateTime(1990, 5, 17));

    reply = (_) => <String, Object?>{};
    final unset = await source.characteristics();
    expect(unset.sex, isNull);
    expect(unset.birthDate, isNull);
  });

  test('requestAuthorization is false off iOS without touching the bridge', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;

    expect(await source.requestAuthorization(), isFalse);
    expect(calls, isEmpty);
  });

  test('requestAuthorization asks the bridge on iOS when Health data is available', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    reply = (_) => true;

    expect(await source.requestAuthorization(), isTrue);
    expect(calls.map((c) => c.method), ['isAvailable', 'requestAuthorization']);
  });

  test('requestAuthorization is false on iOS devices without Apple Health', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    reply = (call) => call.method != 'isAvailable';

    expect(await source.requestAuthorization(), isFalse);
    expect(calls.map((c) => c.method), ['isAvailable']);
  });
}
