# Calendar Page — Prep Notes

## Route
`/calendar` (child of MainShell, tab index 0)

## Angular Source
`src/app/features/calendar/`

## Top-Level Layout
```
Scaffold
  Column
    ── Header row ──
    Row(spaceBetween)
      IconButton(Icons.chevron_left)  ← prev month / prev year
      Text('Month YYYY' / 'YYYY', style: tt.titleLarge)
      IconButton(Icons.chevron_right) ← next month / next year

    ── Toggle row ──
    Row(center)
      _ToggleButton('Monthly', selected: !yearlyView)
      _ToggleButton('Yearly', selected: yearlyView)

    ── Content ──
    Expanded(
      child: yearlyView ? _YearlyGrid() : _MonthlyGrid()
    )
```

## Monthly View — Grid
```
Column
  ── Weekday header row ──
  Row: [Mon, Tue, Wed, Thu, Fri, Sat, Sun]  ← style: tt.labelSmall, color: cs.onSurfaceVariant

  ── Day grid ──
  GridView(7 columns, fixed aspect ratio)
    for each day cell:
      GestureDetector(onTap: _onDayTap)
        Container(
          decoration: BoxDecoration(
            color: isToday ? cs.primaryContainer : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(cs.primary) : null,
          )
          Column(center)
            Text(dayNum, style: tt.bodyMedium,
                 color: isOtherMonth ? cs.outline : cs.onSurface)
            Row(center, spacing: 2)
              if (hasWorkout) Text(workoutTypeIcon, fontSize: 12)
                else if (hasAttendance) Container(4x4 circle, color: cs.primary)
              if (hasSupplements) Text('💊', fontSize: 10)
        )
```

## Yearly View — Grid
```
GridView(3 columns — portrait, 4 columns — landscape)
  for each month (1–12):
    GestureDetector(onTap: () => switchToMonthlyView(month))
      Card
        Column
          Text('Jan' / 'Feb' etc., style: tt.labelMedium)
          SizedBox(height: 4)
          _MiniMonthGrid(month)   ← small version of month grid
          ── attendance count ──
          Text('X days attended', style: tt.bodySmall)
```

## Day Popup (bottom sheet / modal)
Opens when user taps a day cell in monthly view.
```
DraggableScrollableSheet or showModalBottomSheet
  Column
    ── Title ──
    Text('Mon, Jan 15', style: tt.headlineSmall)
    Divider
    ── Tab bar ──
    TabBar(tabs: [Tab(text: 'Workout'), Tab(text: 'Health')])
    TabBarView(
      ── Workout Tab ──
      if (!attended):
        Column(center)
          Text('Did you go to the gym?', style: tt.bodyLarge)
          SizedBox(height: 16)
          PrimaryButton('Mark Attended', onPressed: _markAttended)
      else:
        Column
          Row
            Text('You went to the gym! 💪', style: tt.bodyLarge)
          SizedBox(height: 16)
          ── Workout type card (tappable → expand dropdown) ──
          Card
            Row(spaceBetween)
              Row [Text(workoutType.icon), Text(workoutType.name)]
              Icon(Icons.expand_more)
          ── expanded: dropdown of workout types ──
          SizedBox(height: 12)
          CustomTextField(label: 'Duration (minutes)', type: number)
          SizedBox(height: 16)
          Row(spaceBetween)
            OutlinedButton('Remove', color: cs.error)
            PrimaryButton('Save')

      ── Health Tab ──
      Column
        if (dayLogs.isEmpty):
          Text('No supplements logged', color: cs.onSurfaceVariant)
        else:
          PageView (each page = one log entry)
            for each log:
              Card
                Row(spaceBetween)
                  Column
                    Text(productName, style: tt.titleMedium)
                    Text(brandName, style: tt.bodySmall)
                  IconButton(Icons.delete_outline, onPressed: _deleteLog)
          DotsIndicator(count: logs.length, activeIndex: currentPage)
        SizedBox(height: 16)
        ── Add supplement ──
        Row
          Expanded(DropdownButton of user's products)
          IconButton(Icons.add, onPressed: _logSupplement)
    )
```

## Cubit Methods Used
```dart
// CalendarCubit:
calendarCubit.loadMonth(year, month);        // on init and month change
calendarCubit.loadYear(year);                // when switching to yearly view
calendarCubit.markDay(date, workoutTypeId, durationMinutes);  // mark attended
calendarCubit.clearDay(date);                // remove attendance

// HealthCubit:
healthCubit.loadMonthEntries(year, month);   // supplement dots on calendar
healthCubit.loadDayEntries(date);            // health tab in popup
healthCubit.logSupplement(date, productId);  // add log
healthCubit.deleteEntry(entryId);            // delete log from health tab
```

## CalendarCubit States
| State | Trigger | UI Response |
|---|---|---|
| `CalendarLoadedState(days, month, year)` | loadMonth | render grid |
| `CalendarYearLoadedState(months, year)` | loadYear | render yearly grid |
| `PendingState` | any load | show spinner |
| `SomethingWentWrongState` | error | show error snackbar |

## Day Cell Data Model
Each day cell in `CalendarLoadedState` includes:
- `date: DateTime`
- `attended: bool`
- `workoutType: WorkoutType?` (has `icon: String`, `name: String`, `color: String`)
- `durationMinutes: int?`
- `isToday: bool`
- `isCurrentMonth: bool`

## Colors / Styles
- Today highlight: `cs.primaryContainer`
- Other month text: `cs.outline`
- Attendance dot: `cs.primary` (4×4 circle)
- Workout icon: workoutType.color (hex) tinted background
- Supplement dot: `💊` emoji (fontSize: 10)
- Toggle selected: `cs.primaryContainer` text=`cs.onPrimaryContainer`
- Toggle unselected: transparent text=`cs.onSurfaceVariant`

## Navigation In/Out
- IN: MainShell tab 0 (initial tab)
- OUT: no navigation; popup is in-page modal
