# Main Shell Page — Prep Notes

## Route
`/` (shell route — hosts bottom navigation with 4 tabs)

## Purpose
Persistent bottom navigation wrapper for the 4 main app sections.

## Layout
```
AutoTabsScaffold(
  routes: [CalendarRoute(), StatsRoute(), HealthRoute(), ProfileRoute()],
  bottomNavigationBuilder: (_, tabsRouter) => NavigationBar(
    selectedIndex: tabsRouter.activeIndex,
    onDestinationSelected: tabsRouter.setActiveIndex,
    destinations: [
      NavigationDestination(icon: Icons.calendar_month_outlined,
                            selectedIcon: Icons.calendar_month,
                            label: 'Calendar'),
      NavigationDestination(icon: Icons.bar_chart_outlined,
                            selectedIcon: Icons.bar_chart,
                            label: 'Stats'),
      NavigationDestination(icon: Icons.health_and_safety_outlined,
                            selectedIcon: Icons.health_and_safety,
                            label: 'Health'),
      NavigationDestination(icon: Icons.person_outline,
                            selectedIcon: Icons.person,
                            label: 'Profile'),
    ],
  ),
)
```

## Tab Order
| Index | Label | Route | Icon |
|---|---|---|---|
| 0 | Calendar | `CalendarRoute` | `calendar_month` |
| 1 | Stats | `StatsRoute` | `bar_chart` |
| 2 | Health | `HealthRoute` | `health_and_safety` |
| 3 | Profile | `ProfileRoute` | `person` |

## Angular Equivalent
Angular used a bottom tab bar component with the same 4 tabs in the same order.
Active tab uses filled icon, inactive tab uses outlined variant.

## Colors / Styles
- `NavigationBar` uses M3 defaults:
  - Background: `cs.surfaceContainerLow`
  - Indicator (selected): `cs.secondaryContainer`
  - Selected icon: `cs.onSecondaryContainer`
  - Unselected icon: `cs.onSurfaceVariant`
  - Label: `tt.labelSmall`

## Navigation In/Out
- IN: from `SplashPage` (replace), `LoginPage` (replace)
- Child routes handle their own sub-navigation
- `WorkoutTypesRoute` and `SettingsRoute` push on top of the shell (full-screen)

## Notes
- `AutoTabsScaffold` handles lazy loading of tab content
- Back button on Android does not exit the app from this shell; it navigates back through tabs
- Each tab maintains its own navigation stack
