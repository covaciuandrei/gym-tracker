import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/model/sex.dart';

import 'fixture_loader.dart';

/// Test-only [HealthRepository] backed by anonymized fixture JSON extracted
/// from a sample Apple Health export (Jan 2022 → mid 2026), so analyzer and
/// service tests run against realistically shaped data.
class MockHealthRepository implements HealthRepository {
  MockHealthRepository(this._loader);

  final HealthInsightsFixtureLoader _loader;

  static const Map<HealthMetric, String> _fileNames = {
    HealthMetric.bodyMass: 'body_mass',
    HealthMetric.leanBodyMass: 'lean_body_mass',
    HealthMetric.height: 'height',
    HealthMetric.vo2Max: 'vo2_max',
    HealthMetric.heartRateVariabilitySdnn: 'heart_rate_variability_sdnn',
    HealthMetric.heartRateRecovery: 'heart_rate_recovery',
    HealthMetric.basalEnergyBurned: 'basal_energy_daily',
    HealthMetric.activeEnergyBurned: 'active_energy_daily',
  };

  final Map<HealthMetric, List<HealthSample>> _cache = {};
  HealthCharacteristics? _characteristicsCache;

  @override
  Future<bool> requestAuthorization() async => true;

  @override
  Future<HealthCharacteristics> characteristics() async {
    final cached = _characteristicsCache;
    if (cached != null) return cached;

    final json = await _loader.loadObject('characteristics');
    final birthDateRaw = json['birthDate'] as String?;
    final result = HealthCharacteristics(
      sex: Sex.fromStorage(json['sex'] as String?),
      birthDate: birthDateRaw != null ? DateTime.tryParse(birthDateRaw) : null,
    );
    _characteristicsCache = result;
    return result;
  }

  @override
  Future<List<HealthSample>> samples(HealthMetric metric, {DateTime? from, DateTime? to}) async {
    final all = await _samplesFor(metric);
    return all.where((s) {
      if (from != null && s.dateFrom.isBefore(from)) return false;
      if (to != null && s.dateFrom.isAfter(to)) return false;
      return true;
    }).toList();
  }

  @override
  Future<void> clearCache() async {
    _cache.clear();
    _characteristicsCache = null;
  }

  Future<List<HealthSample>> _samplesFor(HealthMetric metric) async {
    final cached = _cache[metric];
    if (cached != null) return cached;

    final fileName = _fileNames[metric];
    if (fileName == null) return const [];

    final json = await _loader.loadList(fileName);
    final samples = json
        .cast<Map<String, dynamic>>()
        .map(
          (entry) => HealthSample(
            metric: metric,
            value: (entry['value'] as num).toDouble(),
            unit: entry['unit'] as String? ?? '',
            dateFrom: DateTime.parse(entry['dateFrom'] as String),
            dateTo: DateTime.parse(entry['dateTo'] as String),
            sourceName: entry['sourceName'] as String? ?? 'Unknown',
          ),
        )
        .toList();
    _cache[metric] = samples;
    return samples;
  }
}
