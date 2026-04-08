# Settings Page — Screen Doc

> Last updated: 2026-04-08

## Route

`/settings` (pushed from ProfilePage)

## Source

`lib/presentation/pages/settings/settings_page.dart`

## Page Setup

- `@RoutePage()` annotation
- `implements AutoRouteWrapper` → `BlocProvider<SettingsCubit>`
- `StatefulWidget`
- `initState` → `settingsCubit.init()` (loads app version)
- Direct helper access: `_themeHelper = getIt<ThemeHelper>()`, `_localeHelper = getIt<LocaleHelper>()`

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: l10n.settingsTitle)
  SafeArea
    SingleChildScrollView(padding: h16+v16)
      Center → ConstrainedBox(maxWidth: 600)
        Column(crossAxisAlignment: start)

          ── ABOUT section ──
          _SectionHeader("ABOUT")
          SurfaceSectionCard [
            LabeledValueTile(info_outline, "App Version", version)
          ]
          SizedBox(height: 24)

          ── ACCOUNT section ──
          _SectionHeader("ACCOUNT")
          SurfaceSectionCard [
            ListTile(lock_outline, "Change Password", chevron)
              → ctx.router.push(ChangePasswordRoute())
          ]
          SizedBox(height: 24)

          ── GENERAL section ──
          _SectionHeader("GENERAL")
          SurfaceSectionCard [
            ListTile(dark_mode/light_mode, "Theme")
              subtitle: "Dark" / "Light"
              trailing: Switch(isDark, onChanged: themeHelper.setDark)
            Divider
            ListTile(language, "Language")
              subtitle: "English" / "Romanian"
              trailing: OptionToggle([EN, RO], onSelect: localeHelper.setLocale)
          ]
          SizedBox(height: 16)
```

## State → UI Mapping

### SettingsCubit (BlocBuilder)

| State | UI |
|---|---|
| `SettingsReadyState(appVersion)` | Shows version string |
| `PendingState` | Shows "-" for version |

## Controls Used

- `GymAppBar`
- `SurfaceSectionCard`
- `LabeledValueTile` (app version)
- `OptionToggle` (language selector)

## Navigation In/Out

- IN: from `ProfilePage` (push)
- OUT: back (pop), → `ChangePasswordRoute` (push)

## Status

✅ **IMPLEMENTED**
