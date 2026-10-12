/// Self-reported body composition category, captured optionally at
/// registration to seed the Health Insights body-recomposition card before
/// any Apple Health data has been analyzed.
enum BodyType {
  lean('lean'),
  athletic('athletic'),
  average('average'),
  skinnyFat('skinnyFat'),
  higherBodyFat('higherBodyFat');

  const BodyType(this.storageValue);

  /// Canonical value persisted on `users/{uid}.bodyType`.
  final String storageValue;

  /// Parses a stored value back into a [BodyType], or `null` when absent/unrecognized.
  static BodyType? fromStorage(String? value) {
    for (final type in BodyType.values) {
      if (type.storageValue == value) return type;
    }
    return null;
  }
}
