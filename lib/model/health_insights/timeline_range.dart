/// A selectable range for the "metric timeline" detail pages (body
/// composition / VO2Max / heart-rate-recovery history charts).
///
/// [Max] always has a dynamic [label] reflecting the actual span of
/// available data (e.g. "1.5Y") when it doesn't cleanly match a round unit,
/// falling back to "Max" otherwise \u2014 see `TimelineRangeResolver`.
enum TimelineRangeKind { threeMonths, sixMonths, ytd, oneYear, twoYears, threeYears, max }

class TimelineRange {
  const TimelineRange({required this.kind, required this.label});

  final TimelineRangeKind kind;
  final String label;

  /// The inclusive start date for this range, given [now] and (for [max])
  /// the earliest date any relevant series actually has data.
  DateTime startDate({required DateTime now, required DateTime earliestDataDate}) {
    switch (kind) {
      case TimelineRangeKind.threeMonths:
        return DateTime(now.year, now.month - 3, now.day);
      case TimelineRangeKind.sixMonths:
        return DateTime(now.year, now.month - 6, now.day);
      case TimelineRangeKind.ytd:
        return DateTime(now.year, 1, 1);
      case TimelineRangeKind.oneYear:
        return DateTime(now.year - 1, now.month, now.day);
      case TimelineRangeKind.twoYears:
        return DateTime(now.year - 2, now.month, now.day);
      case TimelineRangeKind.threeYears:
        return DateTime(now.year - 3, now.month, now.day);
      case TimelineRangeKind.max:
        return earliestDataDate;
    }
  }
}
