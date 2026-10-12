# Two Column Comparison Page — Screen Doc

> Last updated: 2026-10-08 (Cardio Fitness Age removed; HRR-only)

## Route

`/health-insights/compare` (guards: `AuthGuard`)

## Origin

New feature — no Angular precursor. Shared/generic detail page used by Heart Rate
Recovery — it replaced its v2 chart-based detail page with this simpler "you vs. a
reference value" card, since there's no well-verified age-banded population table to
chart a trend against in a way that would add much over a single comparison number.

## Entry Point

- **Heart Rate Recovery card** → one row: `{label: "Heart Rate Recovery", yourValue:
  recovery.currentBpm, averageValue: 12.0, averageCaption: "Healthy reference", unit:
  "bpm"}`. The 12 bpm figure is Cole et al.'s (NEJM, 1999) cutoff below which the study
  found an association with higher all-cause mortality — presented explicitly as a
  reference/threshold, **never** labeled "average", since there's no verified age-banded
  HRR population table to draw a true average from.

Both cards only set `onTap` when their underlying data is non-null.

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: title)
  body: SafeArea
    ListView(padding: 16)
      ComparisonRowsCard(rows: rows)
```

## `ComparisonRowsCard` (reusable widget, not route-specific)

Also used inline by `PhysicalOverviewDetailPage`'s population mode (see that screen
doc) — a `Container` with one or more rows, each row showing:

```
Text(row.label)
Row
  Expanded: _ValueTile("You", row.yourValue, emphasized/primary color)
  Expanded: _ValueTile(row.averageCaption, row.averageValue)
```

Multiple rows are separated by a `Divider`. `averageCaption` is per-row (not a single
global label) specifically so this one widget can honestly describe very different kinds
of "reference" values — a true age/sex-banded population average (Cardio Fitness Age,
Physical Overview) vs. a clinical threshold (Heart Rate Recovery) — without ever
mislabeling the latter as an "average".

## Design tokens used

Standard app tokens only — `colorScheme.surfaceContainerLow/surfaceContainerHigh`,
`.primary`, `.onSurfaceVariant`; `textTheme.bodyMedium/bodySmall/titleMedium`. No
hardcoded colors or hex values.
