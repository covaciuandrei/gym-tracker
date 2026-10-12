import 'package:gym_tracker/model/health_insights/health_characteristics.dart';
import 'package:gym_tracker/model/health_insights/health_metric.dart';
import 'package:gym_tracker/model/health_insights/health_sample.dart';

/// Source of Apple Health data for the Health Insights feature.
///
/// The app binds [AppleHealthRepository] (live HealthKit data); tests use a
/// fixture-backed implementation. Every consumer — analyzers, cubits,
/// widgets — is written against this interface only.
///
/// Health data never leaves the device: it is read, analyzed in memory, and
/// kept in the app's cache folder (excluded from backups), refreshed at most
/// once a day. It is never written to Firestore or any other backend.
abstract class HealthRepository {
  /// Requests permission to read the metrics this feature needs (the system
  /// sheet appears only the first time). iOS never reveals whether read
  /// access was granted, so `true` only means the request completed.
  Future<bool> requestAuthorization();

  /// One-time characteristic data (biological sex, date of birth). These are
  /// queried differently from time-series samples in real HealthKit
  /// (`HKHealthStore.biologicalSex` / `.dateOfBirthComponents`, not a sample
  /// query), which is why they get their own method instead of a
  /// [HealthMetric] case. Null when HealthKit has neither value set (or, for
  /// the mock, if the bundled fixture is unavailable).
  Future<HealthCharacteristics?> characteristics();

  /// Time-series samples for [metric], ascending by [HealthSample.dateFrom].
  /// [from]/[to] bound the range (inclusive) when provided; omitting both
  /// returns everything available.
  Future<List<HealthSample>> samples(HealthMetric metric, {DateTime? from, DateTime? to});

  /// Drops any cached data so the next read queries the source again.
  Future<void> clearCache();
}
