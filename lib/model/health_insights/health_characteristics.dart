import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/sex.dart';

/// The subset of HealthKit "characteristic" data (queried once, not a
/// sample stream) the Health Insights feature can use: biological sex and
/// date of birth.
///
/// HealthKit exposes these via characteristic queries
/// (`HKHealthStore.biologicalSex` / `.dateOfBirthComponents`), separate from
/// the time-series `HKSampleQuery` used for [HealthSample]s \u2014 this class
/// mirrors that split (see `HealthKitSource.characteristics`).
class HealthCharacteristics extends Equatable {
  const HealthCharacteristics({this.sex, this.birthDate});

  final Sex? sex;
  final DateTime? birthDate;

  @override
  List<Object?> get props => [sex, birthDate];
}
