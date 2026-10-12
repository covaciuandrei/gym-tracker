import Flutter
import HealthKit

/// Read-only Apple Health access for Health Insights on the `gym_tracker/healthkit` channel.
/// Every series is returned as `[startMs, endMs, value]` points, ascending by start date.
final class HealthKitBridge: NSObject, FlutterPlugin {
  private struct Metric {
    let type: HKQuantityType
    let unit: HKUnit
  }

  private let store = HKHealthStore()

  // Keys match the Dart `HealthMetric` enum names; units match what the analyzers expect.
  private static let metrics: [String: Metric] = {
    var metrics: [String: Metric] = [:]
    func add(_ key: String, _ identifier: HKQuantityTypeIdentifier, _ unit: HKUnit) {
      if let type = HKQuantityType.quantityType(forIdentifier: identifier) {
        metrics[key] = Metric(type: type, unit: unit)
      }
    }
    add("bodyMass", .bodyMass, .gramUnit(with: .kilo))
    add("leanBodyMass", .leanBodyMass, .gramUnit(with: .kilo))
    add("height", .height, .meterUnit(with: .centi))
    add("vo2Max", .vo2Max, HKUnit(from: "ml/kg*min"))
    add("heartRateVariabilitySdnn", .heartRateVariabilitySDNN, .secondUnit(with: .milli))
    add("basalEnergyBurned", .basalEnergyBurned, .kilocalorie())
    add("activeEnergyBurned", .activeEnergyBurned, .kilocalorie())
    if #available(iOS 16.0, *) {
      add("heartRateRecovery", .heartRateRecoveryOneMinute, HKUnit.count().unitDivided(by: .minute()))
    }
    return metrics
  }()

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "gym_tracker/healthkit", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(HealthKitBridge(), channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]
    switch call.method {
    case "isAvailable":
      result(HKHealthStore.isHealthDataAvailable())
    case "requestAuthorization":
      requestAuthorization(result: result)
    case "characteristics":
      result(characteristics())
    case "samples", "latestSample", "dailySums":
      // Metrics this iOS version can't provide (HRR needs iOS 16) read as empty.
      guard let key = args["metric"] as? String, let metric = Self.metrics[key] else {
        result([])
        return
      }
      let start = Self.date(args["startMs"])
      let end = Self.date(args["endMs"]) ?? Date()
      switch call.method {
      case "samples":
        samples(metric, start: start, end: end, latestOnly: false, result: result)
      case "latestSample":
        samples(metric, start: nil, end: nil, latestOnly: true, result: result)
      default:
        dailySums(metric, start: start, end: end, result: result)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func requestAuthorization(result: @escaping FlutterResult) {
    guard HKHealthStore.isHealthDataAvailable() else {
      result(false)
      return
    }
    var readTypes = Set(Self.metrics.values.map { $0.type as HKObjectType })
    for identifier in [HKCharacteristicTypeIdentifier.biologicalSex, .dateOfBirth] {
      if let type = HKObjectType.characteristicType(forIdentifier: identifier) {
        readTypes.insert(type)
      }
    }
    store.requestAuthorization(toShare: nil, read: readTypes) { success, _ in
      DispatchQueue.main.async { result(success) }
    }
  }

  private func characteristics() -> [String: Any] {
    var payload: [String: Any] = [:]
    if let sex = try? store.biologicalSex().biologicalSex {
      switch sex {
      case .male: payload["sex"] = "male"
      case .female: payload["sex"] = "female"
      default: break
      }
    }
    if let birth = try? store.dateOfBirthComponents(), let year = birth.year, let month = birth.month, let day = birth.day {
      payload["birthDate"] = String(format: "%04d-%02d-%02d", year, month, day)
    }
    return payload
  }

  private func samples(_ metric: Metric, start: Date?, end: Date?, latestOnly: Bool, result: @escaping FlutterResult) {
    let query = HKSampleQuery(
      sampleType: metric.type,
      predicate: HKQuery.predicateForSamples(withStart: start, end: end, options: []),
      limit: latestOnly ? 1 : HKObjectQueryNoLimit,
      sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: !latestOnly)]
    ) { _, samples, error in
      let points = (samples as? [HKQuantitySample] ?? []).map { sample in
        [Self.millis(sample.startDate), Self.millis(sample.endDate), sample.quantity.doubleValue(for: metric.unit)]
      }
      Self.finish(result, points: points, error: error)
    }
    store.execute(query)
  }

  // HealthKit's own daily statistics also merge overlapping iPhone + Watch readings.
  private func dailySums(_ metric: Metric, start: Date?, end: Date, result: @escaping FlutterResult) {
    guard let start = start else {
      result(FlutterError(code: "bad_args", message: "dailySums requires startMs", details: nil))
      return
    }
    let anchor = Calendar.current.startOfDay(for: start)
    let query = HKStatisticsCollectionQuery(
      quantityType: metric.type,
      quantitySamplePredicate: HKQuery.predicateForSamples(withStart: anchor, end: end, options: []),
      options: .cumulativeSum,
      anchorDate: anchor,
      intervalComponents: DateComponents(day: 1)
    )
    query.initialResultsHandler = { _, collection, error in
      var points: [[Double]] = []
      collection?.enumerateStatistics(from: anchor, to: end) { statistics, _ in
        if let sum = statistics.sumQuantity() {
          points.append([Self.millis(statistics.startDate), Self.millis(statistics.endDate), sum.doubleValue(for: metric.unit)])
        }
      }
      Self.finish(result, points: points, error: error)
    }
    store.execute(query)
  }

  private static func finish(_ result: @escaping FlutterResult, points: [[Double]], error: Error?) {
    DispatchQueue.main.async {
      if let error = error, !isEmptyResult(error) {
        result(FlutterError(code: "healthkit_error", message: error.localizedDescription, details: nil))
      } else {
        result(points)
      }
    }
  }

  // HealthKit reports "no data" and missing authorization as errors; both just mean nothing to show.
  private static func isEmptyResult(_ error: Error) -> Bool {
    guard let healthKitError = error as? HKError else { return false }
    if healthKitError.code == .errorAuthorizationDenied || healthKitError.code == .errorAuthorizationNotDetermined {
      return true
    }
    if #available(iOS 14.0, *) {
      return healthKitError.code == .errorNoData
    }
    return false
  }

  private static func date(_ value: Any?) -> Date? {
    guard let millis = value as? NSNumber else { return nil }
    return Date(timeIntervalSince1970: millis.doubleValue / 1000)
  }

  private static func millis(_ date: Date) -> Double {
    date.timeIntervalSince1970 * 1000
  }
}
