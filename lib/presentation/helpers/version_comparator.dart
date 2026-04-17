/// Minimal semantic-version comparator for plain `MAJOR.MINOR.PATCH` strings.
///
/// Not a full semver implementation — no pre-release / build-metadata support.
/// Designed for the app-version gate which only needs numeric comparison of
/// `pubspec.yaml` version strings.
class VersionComparator {
  const VersionComparator._();

  /// Returns a negative value if [a] < [b], zero if equal, positive if [a] > [b].
  ///
  /// Non-numeric or missing segments are treated as `0`, so `"1.2"` compares
  /// equal to `"1.2.0"` and `"abc"` compares equal to `"0"`.
  static int compare(String a, String b) {
    final aParts = _parse(a);
    final bParts = _parse(b);
    final length = aParts.length > bParts.length ? aParts.length : bParts.length;

    for (var i = 0; i < length; i++) {
      final av = i < aParts.length ? aParts[i] : 0;
      final bv = i < bParts.length ? bParts[i] : 0;
      if (av != bv) return av - bv;
    }
    return 0;
  }

  /// True when [current] is strictly older than [other].
  static bool isBelow(String current, String other) => compare(current, other) < 0;

  static List<int> _parse(String version) {
    // Strip Flutter build number suffix like "+1" if present.
    final base = version.split('+').first;
    return base.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
  }
}
