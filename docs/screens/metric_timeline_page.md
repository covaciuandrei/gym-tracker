# Metric Timeline Page — Screen Doc

> Last updated: 2026-10-08 (short-month OX labels, header period, zoomed baseline)

## Route

`/health-insights/timeline` (guards: `AuthGuard`)

## Origin

New feature — no Angular precursor. Shared/generic detail page used by Body
Recomposition and Cardio Fitness.

## Entry Point

Pushed from `BodyRecompositionCard` (specs: `[bodyMass]` + `derivedBodyFatLabel` set —
adds a computed monthly body-fat % series) and `CardioFitnessCard` (specs: `[vo2Max]`).
The caller supplies:

- `title` / `emoji` — shown in the app bar / used for the empty state.
- `specs: List<MetricTimelineSeriesSpec>` — which `HealthMetric`(s) to load, each with a
  display `label` + `unit`.
- `derivedBodyFatLabel` — when set, an extra series is computed by pairing each month's
  average weight with that month's average lean mass
  (`(weight - lean) / weight * 100`) — Body Recomposition shows weight + derived body-fat
  % rather than weight + lean mass, matching what the summary card itself displays.

Every fetch is bounded to `MetricTimelineBuilder.reportingWindowStart()` (the last 24
months) and served from the day's cached Apple Health snapshot.

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: widget.title)
  body: SafeArea
    BlocBuilder<MetricTimelineCubit>
      ── Pending ── CircularProgressIndicator (centered)
      ── SomethingWentWrongState ── ErrorStateWidget(message, onRetry: reload)
      ── Ready, no ranges available ── ErrorStateWidget(emoji, title, healthInsightsNoData)
      ── Ready ──
      ListView(padding: 16/16/16/32)
        Wrap(ChoiceChip per available TimelineRange)
        SizedBox(height: 16)
        [SeriesChartCard per series]   ← always visible, no expand/collapse
```

Body Recomposition's page shows **2** `SeriesChartCard`s (Weight, Body fat %); Cardio
Fitness's shows **1** (VO2 Max) — this is a direct consequence of how many specs (+ the
derived series) each caller passes, not special-cased in the page itself.

## `SeriesChartCard` (one per series, always visible)

Title + period + latest value + change-over-selected-range text on top, then a
`MonthlyBarChart` underneath — no tap-to-expand interaction anymore (the v2 design's
collapsed/expandable row was replaced with this always-visible card per explicit feedback
that the charts should just be there, not hidden behind a tap).

The period sits on the title line in muted `bodySmall` (it wraps below the title when
space is short): just the year when every plotted month shares one (`2026`), otherwise
`MMM yyyy – MMM yyyy` via `healthInsightsChartPeriod` (`Oct 2025 – May 2026`). It is
derived from the first/last plotted month, not the selected range's nominal start.

## `MonthlyBarChart`

Rewritten in v3 to match the Stats page's own bar-chart style
(`_VerticalBar`/`_ChartSection` in `stats_page.dart`) instead of a `CustomPaint` line/bar
hybrid: one bar per month, the value labeled **above** the bar (OY) and the short month
name **below** it (OX — first 3 letters of the localized `months*` string, like the Stats
charts, via `MonthNames.monthShort` in `lib/presentation/helpers/month_names.dart`; the
year lives in the card header's period). Both labels scale down instead of wrapping, and
the bar area flexes so the labels always fit the chart height.
The value axis starts at `max(0, min − (max − min))` instead of zero, so small relative
changes (e.g. 70–73 kg) stay visible — the smallest bar is then about half the tallest;
series whose values vary widely keep a zero baseline.
Horizontally scrollable with a fixed bar width (28px) rather than stretching to fit,
since a series can have anywhere from a couple of months up to ~19 months of history —
a fixed width keeps bars readable at any count (the Stats page's own charts don't scroll
because they always show exactly 7 or 12 bars).

## Range selection

`TimelineRangeKind` chips are filtered (via `MetricTimelineBuilder.availableRanges`) to
only what the combined series history actually supports. Default selection prefers
1Y → 6M → YTD → 3M → whatever's available, falling back to "Max". Selecting a chip only
changes local `_selectedKind` state (`setState`) — no reload; every series'
`monthlyPoints` (the full unfiltered — but reporting-window-bounded — history) is
filtered client-side per selection.

## Design tokens used

Standard app tokens only — `colorScheme.surfaceContainerLow/surfaceContainerHighest`,
`.primary`, `.onSurfaceVariant`, `.outlineVariant`; `textTheme.bodyMedium/bodySmall/
titleMedium/labelSmall`. No hardcoded colors or hex values.
