# Stats Page — Screen Doc

> Last updated: 2026-04-08

## Route

`/stats` (child of MainShell, tab index 1)

## Angular Source

`src/app/features/health/stats/` (stats sub-components)

## Top-Level Layout

```
Scaffold
  Column
    ── Year navigation header ──
    Row(spaceBetween, padding: h16)
      IconButton(Icons.chevron_left) ← prev year
      Text('Stats $year', style: tt.titleLarge)
      IconButton(Icons.chevron_right) → next year

    ── Sub-tab bar ──
    TabBar(
      tabs: [
        Tab(text: 'Attendances'),
        Tab(text: 'Workouts'),
        Tab(text: 'Duration'),
        Tab(text: 'Health'),
      ],
      labelStyle: tt.labelLarge,
      indicatorColor: cs.primary,
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
    )

    ── Tab content ──
    Expanded(TabBarView([...]))
```

---

## Tab 0 — Attendances

```
SingleChildScrollView → Column(padding: 16)
  ── Monthly bar chart ──
  SectionTitle('Monthly Attendance')
  BarChart(
    months: Jan–Dec,
    values: attendedDaysPerMonth[],
    barColor: cs.primary,
    maxY: 31,
    xLabels: ['J','F','M','A','M','J','J','A','S','O','N','D'],
  )
  SizedBox(height: 24)

  ── Streak cards ──
  SectionTitle('Streaks')
  Row(
    _StatCard('Current Week Streak', value: '$n weeks', icon: 🔥),
    SizedBox(width: 12),
    _StatCard('Best Streak', value: '$n weeks', icon: 🏆,
              subtitle: motivationalMessage(n))
  )
  SizedBox(height: 24)

  ── Favorite day ──
  SectionTitle('Favorite Day')
  Row of 7 day bars (Mon–Sun), each bar height proportional to attendance count
  Text(favoriteDayName + ' is your most active day', style: tt.bodyMedium)
```

### Motivational Messages (best streak)

- < 4 weeks: "Keep going!"
- 4–7: "Great consistency!"
- 8–12: "Impressive streak!"
- ≥ 13: "Unstoppable! 🔥"

---

## Tab 1 — Workouts

```
SingleChildScrollView → Column(padding: 16)
  ── Breakdown by type ──
  SectionTitle('Workout Types This Year')
  for each type:
    Row(spaceBetween)
      Row [Container(type.color, icon, 32×32 rounded), SizedBox(8), Text(type.name)]
      Text('$count sessions', style: tt.bodyMedium)
  SizedBox(height: 24)

  ── Monthly by category ──
  SectionTitle('Monthly by Category')
  Grouped/stacked bar chart per month, each bar segment colored by workout type
```

---

## Tab 2 — Duration

```
SingleChildScrollView → Column(padding: 16)
  ── Average per type ──
  SectionTitle('Avg Duration by Type')
  for each type:
    Row(spaceBetween)
      Row [type icon+name]
      Text('$avgMins min avg', style: tt.bodyMedium)
  SizedBox(height: 24)

  ── Monthly average chart ──
  SectionTitle('Monthly Avg Duration')
  LineChart or BarChart(months Jan–Dec, values: avgMinutesPerMonth[], color: cs.secondary)
```

---

## Tab 3 — Health

```
SingleChildScrollView → Column(padding: 16)
  ── Consistency card ──
  _StatCard(
    title: 'Supplement Consistency',
    value: '$consistencyPct%',
    subtitle: 'Days with supplements / days elapsed',
    icon: 💊,
  )
  SizedBox(height: 16)

  ── Most taken supplement ──
  SectionTitle('Most Taken')
  Card
    Row
      Column
        Text(supplement.name, style: tt.titleMedium)
        Text(supplement.brand, style: tt.bodySmall, color: cs.onSurfaceVariant)
      Text('$count times', style: tt.headlineSmall, color: cs.primary)
  SizedBox(height: 16)

  ── Top nutrients ──
  SectionTitle('Top Nutrients')
  for each nutrient:
    Row(spaceBetween)
      Text(nutrient.name, style: tt.bodyMedium)
      Text('$total $unit', style: tt.bodyMedium, color: cs.primary)
```

---

## Cubit Methods Used

```dart
// StatsCubit:
statsCubit.loadYear(year);
// Provides all stats data needed for all 4 tabs

// Triggered on:
// - initState (load current year)
// - year prev/next button taps
```

## StatsCubit States

Stats uses **per-slice state classes** — one distinct, immutable class per logical event
per tab (no aggregate `StatsLoadedState` container, no `copyWith`, no status enums in state).

| State                                                                                                                        | UI Response                                     |
| ---------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------- |
| `StatsYearInitializedState(year)`                                                                                            | year just changed; all 4 tabs reset to skeleton |
| `StatsAttendancesLoadingState(year)` / `StatsWorkoutsLoadingState` / `StatsDurationLoadingState` / `StatsHealthLoadingState` | that tab shows its skeleton                     |
| `StatsAttendancesLoadedState(year, stats)`                                                                                   | render Attendances tab                          |
| `StatsWorkoutsLoadedState(year, stats, types)`                                                                               | render Workouts tab                             |
| `StatsDurationLoadedState(year, stats, types)`                                                                               | render Duration tab                             |
| `StatsHealthLoadedState(year, stats)`                                                                                        | render Health tab                               |
| `StatsXErrorState(year)` (one per slice)                                                                                     | error widget with retry for that tab            |

Each tab uses its own `BlocBuilder<StatsCubit, BaseState>` filtered to its slice's
states plus `StatsYearInitializedState`, then checks `state.year == _selectedYear.value`
before rendering data — stale emissions are ignored.

## AttendanceStats fields (carried inside per-slice Loaded states)

- `monthlyAttendanceCounts: List<int>` (12 values)
- `currentWeekStreak: int` / `bestWeekStreak: int`
- `currentStreakInfo` / `bestStreakInfo`
- `weekdayAttendanceCounts: List<int>` (7 values)
- `typeDistribution: Map<typeId, int>`
- `monthlyTypeDistribution: Map<month, Map<typeId, int>>`
- `perTypeDurationAverages: Map<typeId, double>`
- `monthlyDurationAverages: Map<month, double>`
- `healthConsistencyPct: double`
- `mostTakenSupplementName: String?`
- `topNutrients: List<NutrientTotal>`

## Colors / Styles

- Bar chart bars: `cs.primary`
- Line chart: `cs.secondary`
- Streak 🔥 icon
- Trophy 🏆 icon
- Section titles: `tt.titleSmall` + left border accent `cs.primary`

## Navigation In/Out

- IN: MainShell tab 1
- OUT: no navigation

## Status

✅ **IMPLEMENTED**
