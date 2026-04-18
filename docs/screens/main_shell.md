# Main Shell Page — Screen Doc

> Last updated: 2026-04-18

## Route

`/app` (authenticated shell route — hosts bottom navigation with 4 tabs)

## Purpose

Persistent bottom-navigation wrapper for the 4 main app sections.

Also owns two cross-cutting flows:

- Auth session watching + redirect to login on sign-out/expiry.
- "Big update available" bottom-sheet presentation through `CheckingUpdateCubit`.

## Providers (`AutoRouteWrapper`)

`MainShellPage` wraps itself in `MultiBlocProvider` with:

- `AuthCubit`
- `CheckingUpdateCubit`

## Layout

```
AutoTabsScaffold(
  routes: [CalendarRoute(), StatsRoute(), HealthRoute(), ProfileRoute()],
  bottomNavigationBuilder: (_, tabsRouter) => custom row nav
    (Material + InkWell + AnimatedContainer per tab),
)
```

## Tab Order

| Index | Label    | Route           | Inactive Icon             | Active Icon      |
| ----- | -------- | --------------- | ------------------------- | ---------------- |
| 0     | Calendar | `CalendarRoute` | `calendar_month_outlined` | `calendar_month` |
| 1     | Stats    | `StatsRoute`    | `bar_chart_outlined`      | `bar_chart`      |
| 2     | Health   | `HealthRoute`   | `medication_outlined`     | `medication`     |
| 3     | Profile  | `ProfileRoute`  | `person_outline`          | `person`         |

## Colors / Styles

- Bottom nav is a custom `Row` (not `NavigationBar`):
  - Container background: `Theme.of(context).cardColor`
  - Top border: `cs.outlineVariant.withValues(alpha: 0.5)`
  - Selected tab background: `cs.primaryContainer.withValues(alpha: 0.45)`
  - Selected border: `cs.primary`
  - Selected label/icon: `cs.primary`
  - Unselected label/icon: `cs.onSurfaceVariant`

## Navigation In/Out

- IN: from `SplashPage` (`SplashNavigateMainShellState`) and `LoginPage`
- Child routes handle their own sub-navigation
- `WorkoutTypesRoute` and `SettingsRoute` push on top of the shell (full-screen)

## Notes

- `AutoTabsScaffold` handles lazy loading of tab content
- Each tab maintains its own navigation stack

## Lifecycle hooks

- `initState()` calls `context.read<AuthCubit>().watchAuthState()`.
- `initState()` also schedules post-frame `context.read<CheckingUpdateCubit>().evaluate()`.

## Listeners

- `BlocListener<AuthCubit, BaseState>`:
  - On `AuthSignOutSuccessState` or `AuthUnauthenticatedState`, route to `LoginRoute`.
- `BlocListener<CheckingUpdateCubit, BaseState>`:
  - On `CheckingUpdateShowSheetState`, opens `BigUpdateBottomSheet`.

## Big-update bottom sheet

Main shell delegates the eligibility logic to `CheckingUpdateCubit` +
`CheckingUpdateService`:

1. `CheckingUpdateCubit.evaluate()` is called post-frame.
2. Cubit waits `defaultPresentationDelay = 2s`.
3. Cubit asks service `shouldShowBigUpdate()`:
   - requires `AppVersionStatus.bigUpdateAvailable == true`
   - requires non-empty `latestVersion`
   - requires no active 3-day snooze for the same version.
4. On success, cubit emits `CheckingUpdateShowSheetState(latestVersion)` and the
   page presents `BigUpdateBottomSheet`.

**SharedPreferences keys:**

- `big_update_dismissed_version` — last `latestVersion` the user snoozed.
- `big_update_dismissed_at_ms` — UTC epoch millis at snooze time.

**Sheet actions:**

- **Update now** → pops the sheet, calls `CheckingUpdateCubit.updateNow()`
  (service launches `storeUrl` externally).
- **Remind me later** → pops the sheet, calls `CheckingUpdateCubit.remindLater()`
  (service writes snooze keys).

Swipe-down / barrier-tap dismissal does **not** write the prefs keys, so the
sheet may reappear on the next cold launch. Only "Remind me later" persists the
snooze.

The sheet content widget lives in
`lib/presentation/controls/big_update_bottom_sheet.dart`.

## Status

✅ **IMPLEMENTED**
