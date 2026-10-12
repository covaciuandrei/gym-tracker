/// The Apple Health / HealthKit quantity and category types the Health
/// Insights feature reads.
///
/// Enum names double as the keys the iOS `HealthKitBridge` maps to
/// HealthKit types, so renaming a value means updating the Swift side too.
enum HealthMetric {
  bodyMass,
  leanBodyMass,
  height,
  vo2Max,
  restingHeartRate,
  heartRateVariabilitySdnn,

  /// Computed natively by Apple post-workout (drop in bpm from peak effort
  /// to one minute of recovery) — read directly, never derived from raw
  /// continuous heart-rate streams.
  heartRateRecovery,

  /// One total per calendar day, from HealthKit's own daily statistics \u2014
  /// HealthKit records this as many small interval samples per day, which
  /// is not a useful shape for the metabolic estimate this feature needs.
  basalEnergyBurned,

  /// Same daily aggregation as [basalEnergyBurned].
  activeEnergyBurned,

  /// Sleep stages are pre-aggregated to one total-minutes value per stage
  /// per night (see `tools/extract_health_fixtures.mjs`).
  sleepAwake,
  sleepCore,
  sleepDeep,
  sleepRem,
}
