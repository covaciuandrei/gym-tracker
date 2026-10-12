import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:injectable/injectable.dart';

/// Reads Apple Health through the app's own `HealthKitBridge`
/// (`ios/Runner/HealthKitBridge.swift`). iOS only.
@lazySingleton
class HealthKitSource {
  const HealthKitSource();

  static const channel = MethodChannel('gym_tracker/healthkit');
  static const sourceName = 'Apple Health';

  /// Every metric a Health Insights card reads, with the unit the bridge converts it to.
  static const units = <HealthMetric, String>{
    HealthMetric.bodyMass: 'kg',
    HealthMetric.leanBodyMass: 'kg',
    HealthMetric.height: 'cm',
    HealthMetric.vo2Max: 'mL/min·kg',
    HealthMetric.heartRateVariabilitySdnn: 'ms',
    HealthMetric.heartRateRecovery: 'count/min',
    HealthMetric.basalEnergyBurned: 'Cal',
    HealthMetric.activeEnergyBurned: 'Cal',
  };

  /// `true` only means the request completed — iOS never reveals whether read access was granted.
  Future<bool> requestAuthorization() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return false;
    if (await channel.invokeMethod<bool>('isAvailable') != true) return false;
    return await channel.invokeMethod<bool>('requestAuthorization') ?? false;
  }

  Future<HealthCharacteristics> characteristics() async {
    final payload = await channel.invokeMapMethod<String, Object?>('characteristics') ?? const <String, Object?>{};
    final birthDate = payload['birthDate'] as String?;
    return HealthCharacteristics(sex: Sex.fromStorage(payload['sex'] as String?), birthDate: birthDate != null ? DateTime.tryParse(birthDate) : null);
  }

  /// Ascending samples for [metric] between [from] and [to]. Energy comes back as one total
  /// per day (the analyzers' expected shape); height as only the latest reading ever, since
  /// it's rarely re-logged.
  Future<List<HealthSample>> samples(HealthMetric metric, {required DateTime from, required DateTime to}) async {
    if (!units.containsKey(metric)) return const [];
    final method = switch (metric) {
      HealthMetric.height => 'latestSample',
      HealthMetric.basalEnergyBurned || HealthMetric.activeEnergyBurned => 'dailySums',
      _ => 'samples',
    };
    final points = await channel.invokeListMethod<Object?>(method, {
      'metric': metric.name,
      'startMs': from.millisecondsSinceEpoch,
      'endMs': to.millisecondsSinceEpoch,
    });
    return [for (final point in points ?? const <Object?>[]) sampleFromPoint(metric, point! as List<Object?>)];
  }

  /// Decodes a `[startMs, endMs, value]` point — the shape the bridge returns and the cache stores.
  static HealthSample sampleFromPoint(HealthMetric metric, List<Object?> point) => HealthSample(
    metric: metric,
    value: (point[2]! as num).toDouble(),
    unit: units[metric] ?? '',
    dateFrom: DateTime.fromMillisecondsSinceEpoch((point[0]! as num).round()),
    dateTo: DateTime.fromMillisecondsSinceEpoch((point[1]! as num).round()),
    sourceName: sourceName,
  );

  static List<num> pointFromSample(HealthSample sample) => [
    sample.dateFrom.millisecondsSinceEpoch,
    sample.dateTo.millisecondsSinceEpoch,
    sample.value,
  ];
}
