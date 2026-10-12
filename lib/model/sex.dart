/// Biological sex, self-reported optionally at registration.
///
/// Used only to personalize population-benchmark lookups in the Health
/// Insights feature (VO2Max / body-fat / HRV / RMR reference tables are
/// commonly published separately by sex). Never required and never used to
/// gate any feature.
enum Sex {
  male('male'),
  female('female');

  const Sex(this.storageValue);

  /// Canonical lowercase value persisted on `users/{uid}.sex`.
  final String storageValue;

  /// Parses a stored value back into a [Sex], or `null` when absent/unrecognized.
  static Sex? fromStorage(String? value) {
    switch (value) {
      case 'male':
        return Sex.male;
      case 'female':
        return Sex.female;
      default:
        return null;
    }
  }
}
