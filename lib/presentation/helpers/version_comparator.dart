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

  /// True when moving from [from] to [to] is a "big" version jump:
  ///   * the major segment increased (e.g. `2.9.9` → `3.0.0`), **or**
  ///   * the major is unchanged but the minor increased by at least 2
  ///     (e.g. `2.1.0` → `2.4.0`).
  ///
  /// Patch-only bumps and single-step minor bumps are considered small and
  /// return `false`.
  static bool isBigJump(String from, String to) {
    if (!isBelow(from, to)) return false;
    final fromParts = _parse(from);
    final toParts = _parse(to);
    final fromMajor = fromParts.isNotEmpty ? fromParts[0] : 0;
    final toMajor = toParts.isNotEmpty ? toParts[0] : 0;
    if (toMajor > fromMajor) return true;
    if (toMajor < fromMajor) return false;
    final fromMinor = fromParts.length > 1 ? fromParts[1] : 0;
    final toMinor = toParts.length > 1 ? toParts[1] : 0;
    return (toMinor - fromMinor) >= 2;
  }

  static List<int> _parse(String version) {
    // Strip Flutter build number suffix like "+1" if present.
    final base = version.split('+').first;
    return base.split('.').map((s) => int.tryParse(s.trim()) ?? 0).toList();
  }
}
