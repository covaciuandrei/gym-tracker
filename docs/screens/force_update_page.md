# Force Update Page — Screen Doc

> Last updated: 2026-04-18

## Route

`/force-update` — guest route (full-screen blocker)

## Purpose

Blocks app usage when the installed version is below
`appConfig.minRequiredVersion`.

Users cannot continue until they update from the platform store.

## Layout

```
Scaffold(backgroundColor: cs.surface)
  SafeArea
    Center
      SingleChildScrollView(padding: horizontal 32, vertical 32)
        Column(mainAxisSize: min)
          EmojiText(Emojis.rocket)
          Title (l10n.forceUpdateTitle)
          Body copy (l10n.forceUpdateBody)
          Version row (current)
          Version row (required, highlighted)
          GradientButton(l10n.forceUpdateButton)
```

## Inputs

- `currentVersion` (required): installed app version from `PackageInfo`.
- `requiredVersion` (required): minimum required version from remote config.
- `storeUrl` (required): platform-specific store URL resolved by splash.

## Behavior

- Back navigation is blocked via `PopScope(canPop: false)`.
- Update button attempts to open `storeUrl` externally:
  - parses URL with `Uri.tryParse`
  - checks `canLaunchUrl`
  - launches via `launchUrl(..., mode: LaunchMode.externalApplication)`
  - no-op on invalid/unlaunchable URL.

## Theming / Localization

- Colors and typography come from theme (`colorScheme`, `textTheme`).
- Required version value is highlighted using `cs.primary`.
- All displayed strings are sourced from `AppLocalizations`.

## Navigation

- IN: emitted by splash as `SplashNavigateForceUpdateState`.
- OUT: no in-app route transition from this page; user is expected to update
  and relaunch.

## Status

✅ **IMPLEMENTED** — `lib/presentation/pages/force_update/force_update_page.dart`
