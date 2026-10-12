import 'package:gym_tracker/data/health_insights/health_cache_store.dart';
import 'package:gym_tracker/data/health_insights/health_repository.dart';
import 'package:gym_tracker/data/health_insights/health_snapshot.dart';
import 'package:gym_tracker/data/health_insights/healthkit_source.dart';
import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';
import 'package:gym_tracker/service/health_insights/metric_timeline_builder.dart';
import 'package:injectable/injectable.dart';

/// [HealthRepository] backed by Apple Health. The first read of a calendar day fetches every
/// metric for the reporting window in one go; the rest of that day — every page, every app
/// restart — is served from an on-device [HealthSnapshot].
@LazySingleton(as: HealthRepository)
class AppleHealthRepository implements HealthRepository {
  AppleHealthRepository(this._source, this._store, {@ignoreParam DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final HealthKitSource _source;
  final HealthCacheStore _store;
  final DateTime Function() _clock;

  HealthSnapshot? _snapshot;
  Future<HealthSnapshot>? _pending;

  // Bumped by clearCache so a fetch that started earlier never repopulates the cache.
  int _generation = 0;

  @override
  Future<bool> requestAuthorization() => _source.requestAuthorization();

  @override
  Future<HealthCharacteristics?> characteristics() async => (await _currentSnapshot()).characteristics;

  @override
  Future<List<HealthSample>> samples(HealthMetric metric, {DateTime? from, DateTime? to}) async {
    final samples = (await _currentSnapshot()).samples[metric] ?? const <HealthSample>[];
    return [
      for (final sample in samples)
        if ((from == null || !sample.dateFrom.isBefore(from)) && (to == null || !sample.dateFrom.isAfter(to))) sample,
    ];
  }

  @override
  Future<void> clearCache() async {
    _generation++;
    _snapshot = null;
    _pending = null;
    await _store.delete();
  }

  Future<HealthSnapshot> _currentSnapshot() {
    final snapshot = _snapshot;
    if (snapshot != null && _isFromToday(snapshot)) return Future.value(snapshot);
    return _pending ??= _loadSnapshot();
  }

  Future<HealthSnapshot> _loadSnapshot() async {
    final generation = _generation;
    try {
      final stored = await _store.read();
      final snapshot = stored != null && _isFromToday(stored) ? stored : await _fetch();
      if (generation == _generation) {
        _snapshot = snapshot;
        if (!identical(snapshot, stored)) await _store.write(snapshot);
      }
      return snapshot;
    } finally {
      if (generation == _generation) _pending = null;
    }
  }

  Future<HealthSnapshot> _fetch() async {
    final now = _clock();
    final from = MetricTimelineBuilder.reportingWindowStart(now: now);
    final metrics = HealthKitSource.units.keys.toList();
    final results = await Future.wait([for (final metric in metrics) _source.samples(metric, from: from, to: now)]);
    return HealthSnapshot(
      fetchedAt: now,
      characteristics: await _source.characteristics(),
      samples: {for (var i = 0; i < metrics.length; i++) metrics[i]: results[i]},
    );
  }

  bool _isFromToday(HealthSnapshot snapshot) {
    final now = _clock();
    final fetchedAt = snapshot.fetchedAt;
    return fetchedAt.year == now.year && fetchedAt.month == now.month && fetchedAt.day == now.day;
  }
}
