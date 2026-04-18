# Maintenance Page — Screen Doc

> Last updated: 2026-04-18

## Route

`/maintenance` — guest route (full-screen blocker)

## Purpose

Blocks normal app usage when remote config enables maintenance mode.

The screen is reached from the splash version gate and keeps users out of the
main flows until maintenance is disabled.

## Layout

```
Scaffold(backgroundColor: cs.surface)
  SafeArea
    Center
      SingleChildScrollView(padding: horizontal 32, vertical 32)
        Column(mainAxisSize: min)
          Image.asset('lib/assets/images/maintenance.png', 200x200)
          Title text (l10n.maintenanceTitle)
          Optional remote message (when message.isNotEmpty)
          GradientButton(l10n.maintenanceRetry)
```

## Inputs

- `message` (required): localized maintenance message resolved by
  `SplashCubit` from `appConfig.maintenanceMessages` (with `en` fallback).

## Behavior

- Back navigation is blocked via `PopScope(canPop: false)`.
- If `message` is empty, only the title is shown.
- "Try again" button replaces the full stack with `SplashRoute` so the
  version gate is re-evaluated immediately.

## Assets

- Uses PNG illustration: `lib/assets/images/maintenance.png`.
- Semantic label is `l10n.maintenanceTitle` for accessibility.

## Theming / Localization

- Colors and text styles are read from the active Material theme.
- All user-visible copy comes from `AppLocalizations`.

## Navigation

- IN: emitted by splash as `SplashNavigateMaintenanceState`.
- OUT: retry action routes to `SplashRoute`.

## Status

✅ **IMPLEMENTED** — `lib/presentation/pages/maintenance/maintenance_page.dart`
