# Settings Page — Screen Doc

> Last updated: 2026-07-22

## Route

`/settings` (pushed from ProfilePage)

## Source

`lib/presentation/pages/settings/settings_page.dart`

## Page Setup

- `@RoutePage()` annotation
- `implements AutoRouteWrapper` → `BlocProvider<SettingsCubit>`
- `StatefulWidget`
- `initState` → `settingsCubit.init()` (loads app version and account currency)
- Direct helper access: `_themeHelper = getIt<ThemeHelper>()`, `_localeHelper = getIt<LocaleHelper>()`, `_versionStatus = getIt<AppVersionStatus>()`

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

          ── LEGAL section ──
          _SectionHeader("LEGAL")
          SurfaceSectionCard [
            ListTile(description_outlined, "Terms of Service",
                     trailing: open_in_new)
              → _openUrl(_versionStatus.termsUrlFor(lang))
            Divider
            ListTile(privacy_tip_outlined, "Privacy Policy",
                     trailing: open_in_new)
              → _openUrl(_versionStatus.privacyUrlFor(lang))
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
            Divider
            ListTile(currency_exchange, "Default currency")
              subtitle: current account currency
              trailing: DropdownButton([EUR, GBP, RON, USD])
              → SettingsCubit.setCurrency() → users/{uid}.currency
          ]
          SizedBox(height: 16)
```

## State → UI Mapping

## Legal links

- URLs resolved per-locale via `AppVersionStatus.termsUrlFor(lang)` / `privacyUrlFor(lang)`.
- 3-tier fallback: `appConfig.termsUrls[lang]` → `appConfig.termsUrls['en']` → hardcoded constants in `lib/core/constants/legal_urls.dart`.
- Opens in the external browser via `launchUrl(uri, mode: LaunchMode.externalApplication)`.

### SettingsCubit (BlocBuilder)

| State                                      | UI                                                    |
| ------------------------------------------ | ----------------------------------------------------- |
| `SettingsReadyState(appVersion, currency)` | Shows version and account currency                    |
| `SettingsCurrencyUpdatedState`             | Updates the selector and shows success feedback       |
| `PendingState`                             | Disables the currency selector while loading/saving   |
| `SomethingWentWrongState`                  | Preserves the last values and shows an error snackbar |

## Controls Used

- `GymAppBar`
- `SurfaceSectionCard`
- `LabeledValueTile` (app version)
- `OptionToggle` (language selector)
- `DropdownButton` (account currency selector)

## Navigation In/Out

- IN: from `ProfilePage` (push)
- OUT: back (pop), → `ChangePasswordRoute` (push)

## Status

✅ **IMPLEMENTED**
