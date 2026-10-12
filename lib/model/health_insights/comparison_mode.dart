/// Which baseline the Health Insights page compares the user's current
/// numbers against.
enum ComparisonMode { population, pastSelf }

/// How far back a "past self" comparison looks. Capped at one year since
/// Health Insights only ever loads the last 24 months of data (see
/// `MetricTimelineBuilder.reportingWindowStart`) \u2014 a longer window would
/// rarely have data to compare against.
enum ComparisonWindow {
  threeMonths(90),
  sixMonths(182),
  oneYear(365);

  const ComparisonWindow(this.days);

  final int days;
}
