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
| State | UI Response |
|---|---|
| `PendingState` | show spinner in content area |
| `StatsLoadedState(data)` | render all 4 tabs from data |
| `SomethingWentWrongState` | show error message |

## StatsLoadedState data fields (approximate)
- `attendedPerMonth: List<int>` (12 values)
- `currentWeekStreak: int`
- `bestStreak: int`
- `attendanceByWeekday: List<int>` (7 values, Mon=0)
- `workoutTypeCounts: Map<WorkoutType, int>`
- `workoutTypeByMonth: Map<String, Map<WorkoutType, int>>`
- `avgDurationByType: Map<WorkoutType, double>`
- `avgDurationByMonth: List<double>`
- `supplementConsistencyPct: double`
- `mostTakenSupplement: SupplementProduct?`
- `topNutrients: List<{name, total, unit}>`

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
