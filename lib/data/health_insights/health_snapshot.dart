import 'package:gym_tracker/data/health_insights/healthkit_source.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';

/// Everything Health Insights read from Apple Health in one go — what the daily cache stores.
class HealthSnapshot {
  const HealthSnapshot({required this.fetchedAt, required this.characteristics, required this.samples});

  /// Bump when the stored shape changes; files written by another version are a cache miss.
  static const version = 1;

  final DateTime fetchedAt;
  final HealthCharacteristics characteristics;
  final Map<HealthMetric, List<HealthSample>> samples;

  Map<String, Object?> toJson() => {
    'version': version,
    'fetchedAt': fetchedAt.toIso8601String(),
    'sex': characteristics.sex?.storageValue,
    'birthDate': characteristics.birthDate?.toIso8601String(),
    'samples': {
      for (final entry in samples.entries) entry.key.name: [for (final sample in entry.value) HealthKitSource.pointFromSample(sample)],
    },
  };

  /// Throws a [FormatException] for a file written by another [version].
  factory HealthSnapshot.fromJson(Map<String, Object?> json) {
    if (json['version'] != version) throw const FormatException('Unsupported Health Insights cache version');

    final samples = <HealthMetric, List<HealthSample>>{};
    for (final entry in (json['samples']! as Map<String, Object?>).entries) {
      final metric = HealthMetric.values.byName(entry.key);
      samples[metric] = [for (final point in entry.value! as List<Object?>) HealthKitSource.sampleFromPoint(metric, point! as List<Object?>)];
    }

    final birthDate = json['birthDate'] as String?;
    return HealthSnapshot(
      fetchedAt: DateTime.parse(json['fetchedAt']! as String),
      characteristics: HealthCharacteristics(
        sex: Sex.fromStorage(json['sex'] as String?),
        birthDate: birthDate != null ? DateTime.parse(birthDate) : null,
      ),
      samples: samples,
    );
  }
}
