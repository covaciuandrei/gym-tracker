# Physical Overview Detail Page — Screen Doc

> Last updated: 2026-07-25 (added in the v3 redesign)

## Route

`/health-insights/overview` (guards: `AuthGuard`)

## Origin

New feature — no Angular precursor. Replaces the v2 design where the population/past-you
toggle lived inline on `PhysicalOverviewCard` itself; that toggle (and everything it
drove) moved here so the main Health Insights page's overview card could go back to
being a plain, non-interactive-except-for-navigation snapshot.

## Entry Point

Tapping the **whole** `PhysicalOverviewCard` (not a sub-row) on the main Health Insights
page. Takes no constructor parameters — everything is loaded fresh via its own
`PhysicalOverviewDetailCubit`, since this page opens well after the main page's own load
and a second bounded fetch here is simpler than threading extra state through
`HealthInsightsResult` for a single entry point.

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: 'Physical Overview')
  body: SafeArea
    BlocBuilder<PhysicalOverviewDetailCubit>
      ── Pending ── CircularProgressIndicator (centered)
      ── SomethingWentWrongState ── ErrorStateWidget(message, onRetry: reload)
      ── Ready ──
      ListView(padding: 16/16/16/32)
        OptionToggle(Population / Past you)   ← local widget state, not persisted
        SizedBox(height: 16)
        ── Population mode ──
        [comparison == null] → ErrorStateWidget(emoji: people, healthInsightsNoData)
        [comparison != null] → ComparisonRowsCard(
                                  headerText: "Compared to an average adult in the {cohort}
                                               reference group, at your height.",
                                  rows: [Weight, (Body fat % if available)],
                                )
        ── Past-you mode ──
        [availableRanges empty] → ErrorStateWidget(emoji: chartIncreasing, healthInsightsNoData)
        [otherwise] → Wrap(range chips) → SeriesChartCard(Weight) → [SeriesChartCard(Lean mass) if any data]
```

## Data source (`PhysicalOverviewDetailCubit`)

Loads fresh (bounded to `MetricTimelineBuilder.reportingWindowStart()`, except height):
weight, lean-mass, height samples; resolves sex/birth date/age via the same
profile-then-HealthKit-characteristics fallback order used everywhere else in this
feature. Computes:

- `comparison: PopulationPhysicalComparison?` via `PopulationComparisonAnalyzer.build()`
  (age/sex/height-adjusted — see `docs/features/health_insights.md` §7) — `null` when
  weight, height, or age is missing.
- `weightPoints` / `leanMassPoints: List<MonthlyPoint>` via `MetricTimelineBuilder`, for
  past-you mode's charts.
- `availableRanges: List<TimelineRange>`, resolved from the earliest weight sample.

## Population vs. past-you mode

- **Population mode** shows a static comparison card — no chart, no range chips (an
  average-for-your-age/height comparison has no "time range" concept).
- **Past-you mode** shows the exact same range-chip + `SeriesChartCard` pattern as
  `MetricTimelinePage` (see that screen doc) for weight and lean mass — this page does
  **not** navigate to `MetricTimelinePage` for this; it renders the same widgets inline
  so the toggle switch doesn't require a second page push.

## Design tokens used

Standard app tokens only — `colorScheme.surfaceContainerLow/surfaceContainerHighest`,
`.primary`, `.onSurfaceVariant`; `textTheme` defaults inherited from the shared
`ComparisonRowsCard`/`SeriesChartCard` widgets. No hardcoded colors or hex values.
