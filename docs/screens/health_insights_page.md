# Health Insights Page — Screen Doc

> Last updated: 2026-10-09 (live Apple Health: direct entry, no-data state, refresh re-reads Apple Health)

## Route

`/health-insights` (guards: `AuthGuard`)

## Origin

New feature — no Angular precursor (this is a native addition to the Flutter app).

## Entry Point

An icon action (`Icons.insights`) on the Health tab's `GymAppBar`, rendered only when
`Platform.isIOS` is true (hidden entirely on Android). Tapping it pushes this route
directly. The first visit shows the system Apple Health permission sheet.

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: 'Health Insights')
  body: SafeArea
    BlocBuilder<HealthInsightsCubit>
      ── Pending ──
      _HealthInsightsSkeleton: ListView.separated of 5 placeholder blocks (140px, surfaceContainerHigh, radius 16)

      ── HealthInsightsPermissionDeniedState ("No Apple Health data") ──
      ErrorStateWidget(emoji: locked, title, message with the Health app path, onRetry: cubit.refresh)

      ── SomethingWentWrongState ──
      ErrorStateWidget(message, onRetry: cubit.load)

      ── HealthInsightsReadyState ──
      PullToRefresh(onRefresh: cubit.refresh)   ← re-reads Apple Health, bypassing today's cache
        ListView(padding: 16/16/16/32)
          PhysicalOverviewCard          ← whole card tappable → PhysicalOverviewDetailRoute
          SizedBox(height: 16)
          BodyRecompositionCard         ← tappable → MetricTimelineRoute (weight + derived body-fat %)
          SizedBox(height: 16)
          CardioFitnessCard             ← tappable → MetricTimelineRoute (VO2Max)
          SizedBox(height: 16)
          HeartRateRecoveryCard         ← tappable → TwoColumnComparisonRoute (HRR vs. healthy reference)
          SizedBox(height: 16)
          MetabolicCard                 ← not tappable (kept as-is per explicit instruction)
```

## Shared card frame

Every card is built on `InsightCardFrame` (`SurfaceSectionCard` + header row). Passing
`onTap` (all cards except `MetabolicCard`) wraps the whole card in an `InkWell` and adds
a trailing chevron next to the (i) button. **Every card's `onTap` is conditional on its
data being non-null** — a card with no data at all is not tappable (no dead/crashing tap
target):

```
SurfaceSectionCard
  Padding(16,16,16,12)
    Row
      EmojiText(cardEmoji, 22)
      SizedBox(width: 10)
      Expanded(Text(title, titleMedium/w700))
      InsightInfoButton(title, message)   ← (i) icon → AlertDialog with the card's explanation
      [Icon(Icons.chevron_right)]         ← only when onTap is provided (i.e. data exists)
  Padding(16,0,16,16)
    <card-specific body>
```

`InsightInfoButton` shows a short `AlertDialog` per card explaining what it means and
what data it shows (all copy lives in the `healthInsights*Info` ARB keys).

## Card bodies

- **PhysicalOverviewCard** (🧍, tappable → `PhysicalOverviewDetailRoute`): row 1 — 3
  metric tiles (Weight / Age / Height), always shown. Row 2 — 2 metric tiles (Body fat /
  Stress), shown only when `overview.row2Visible` (a lean-body-mass reading within the
  last 90 days) — the stress tile also shows a band caption under the number. **No
  toggle, no compare row anymore** — the population/past-you choice moved entirely to
  the detail page (see `docs/screens/physical_overview_detail_page.md`).
- **BodyRecompositionCard** (⚖️, tappable → `MetricTimelineRoute` with `specs: [bodyMass]`
  + `derivedBodyFatLabel`): direction headline (Cutting/Bulking/Recomposition/Stable) →
  `InsightStatRow`s (weight, body fat, change-vs-comparison) → `TrendSparkline` (weight
  history, with OX/OY) → `BenchmarkRow` showing band **and** the actual average value
  (population mode only), e.g. "Average (avg 18.0%) · Men, all adults".
- **CardioFitnessCard** (❤️, tappable → `MetricTimelineRoute` with a VO2Max spec):
  `InsightStatRow`s (current VO2Max, comparison VO2Max, "at your past weight") →
  `TrendSparkline` (VO2Max history, with OX/OY) → `BenchmarkRow` with the average value.
- **HeartRateRecoveryCard** (💓, tappable → `TwoColumnComparisonRoute` with a single HRR
  row): current bpm headline → `InsightStatRow` (band) → `TrendSparkline` (with OX/OY).
  The comparison row's "average" is a fixed 12 bpm, captioned "Healthy reference" (Cole
  et al. 1999), never presented as a population average.
- **MetabolicCard** (🔥, not tappable — kept as-is per explicit instruction): TDEE
  headline → `InsightStatRow`s (resting-rate estimate, Watch basal/active averages).

Every card's `child` is `Text(l10n.healthInsightsNoData, ...)` when its model is `null`.

## `TrendSparkline` (inline cards' line chart)

Now takes `List<MapEntry<DateTime, double>> points` (was a bare `List<double>`). Renders,
top to bottom: the peak value right-aligned above the chart ("max 74.2"), the line chart
itself, then the first/last month labels (`MM/yy`) below — OY and OX respectively. Since
every fetch is already bounded to the last 24 months, this naturally shows
"the last ~2 years, or less if that's all there is" without any extra filtering here.

## Related screen docs

- `docs/screens/metric_timeline_page.md` — Body Recomposition / Cardio Fitness's shared
  monthly-chart detail page.
- `docs/screens/two_column_comparison_page.md` — Heart Rate Recovery's shared "you vs.
  reference" detail page.
- `docs/screens/physical_overview_detail_page.md` — the Physical Overview card's own
  dedicated detail page (population/past-you toggle).
