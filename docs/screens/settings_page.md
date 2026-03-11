# Settings Page — Prep Notes

## Route
`/settings` (pushed from ProfilePage, full-screen)

## Angular Source
`src/app/features/user/settings/`

## Layout
```
Scaffold
  AppBar(
    leading: BackButton → context.router.pop()
    title: Text('Settings', style: tt.titleLarge)
    elevation: 0
  )
  SingleChildScrollView
    Column(padding: 24)

      ── About section ──
      _SectionHeader('ABOUT')
      Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 16)
        Column
          _InfoTile(icon: Icons.info_outline, label: 'App Version', value: packageVersion)
          Divider(indent: 16, endIndent: 16, height: 1)
          _InfoTile(icon: Icons.code, label: 'Built With', value: 'Flutter + Firebase')
      SizedBox(height: 24)

      ── Security section ──
      _SectionHeader('SECURITY')
      Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 16)
        Column
          ── Collapsed state ──
          ListTile(
            leading: Icon(Icons.lock_outline, color: cs.primary)
            title: Text('Password', style: tt.titleMedium)
            subtitle: Text('••••••••', style: tt.bodySmall)
            trailing: TextButton('Change', onPressed: _toggleChangePasswordForm)
          )
          ── Expanded: inline change-password form ──
          if (_showChangePasswordForm):
            Padding(16)
              Column
                CustomTextField(label: 'Current Password', type: password toggle)
                SizedBox(height: 12)
                CustomTextField(label: 'New Password', type: password toggle)
                SizedBox(height: 12)
                CustomTextField(label: 'Confirm New Password', type: password toggle)
                SizedBox(height: 16)
                if (changePasswordError != null):
                  Text(changePasswordError!, color: cs.error, style: tt.bodySmall)
                if (changePasswordSuccess):
                  Row [Icon(Icons.check_circle, color: cs.primary), Text('Password updated!', color: cs.primary)]
                SizedBox(height: 8)
                Row [
                  Expanded(OutlinedButton('Cancel', onPressed: _toggleChangePasswordForm))
                  SizedBox(width: 12)
                  Expanded(PrimaryButton('Update Password', isLoading: pending))
                ]
      SizedBox(height: 24)

      ── General section ──
      _SectionHeader('GENERAL')
      Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 16)
        Column
          ── Theme toggle ──
          ListTile(
            leading: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: cs.primary)
            title: Text('Theme', style: tt.titleMedium)
            trailing: Switch(
              value: isDark,
              onChanged: (v) => themeHelper.toggleTheme(),
              activeColor: cs.primary,
            )
          )
          Divider(indent: 16, endIndent: 16, height: 1)

          ── Language toggle ──
          ListTile(
            leading: Icon(Icons.language, color: cs.primary)
            title: Text('Language', style: tt.titleMedium)
            trailing: _LanguageToggle(current: locale.languageCode)
              ── two-button row: [EN | RO] ——
              Row
                _LangButton('EN', selected: locale == 'en')
                _LangButton('RO', selected: locale == 'ro')
          )
          Divider(indent: 16, endIndent: 16, height: 1)

          ── Export data (disabled) ──
          ListTile(
            leading: Icon(Icons.download_outlined, color: cs.outline)
            title: Text('Export Data', style: tt.titleMedium.copyWith(color: cs.outline))
            trailing: Container(
              padding: h8+v4, decoration: BoxDecoration(cs.surfaceContainerHighest, borderRadius: 8)
              child: Text('Not available', style: tt.labelSmall, color: cs.onSurfaceVariant)
            )
            enabled: false
          )
      SizedBox(height: 32)

      ── Logout button ──
      Center(
        TextButton(
          'Log Out',
          style: TextButton.styleFrom(foregroundColor: cs.error)
          onPressed: _onSignOut
        )
      )
      SizedBox(height: 16)
```

## _SectionHeader widget
```dart
Padding(
  padding: const EdgeInsets.only(bottom: 8),
  child: Text(title,
    style: tt.labelSmall.copyWith(
      color: cs.onSurfaceVariant,
      letterSpacing: 1.2,
    )),
)
```

## _InfoTile widget
```dart
ListTile(
  leading: Icon(icon, color: cs.onSurfaceVariant),
  title: Text(label, style: tt.bodyMedium),
  trailing: Text(value, style: tt.bodyMedium, color: cs.onSurfaceVariant),
)
```

## Language Toggle Button
```dart
Container(
  decoration: BoxDecoration(
    color: selected ? cs.primaryContainer : cs.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(8),
  ),
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  child: Text(lang,
    style: tt.labelLarge.copyWith(
      color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
    )),
)
```

## State → UI Mapping (AuthCubit for change password)
| State | Behavior |
|---|---|
| `PendingState` | Update Password button loading |
| `AuthPasswordChangedState` | show success row, hide form after 2s |
| `AuthInvalidCredentialsState` | show "Current password is incorrect." |
| `SomethingWentWrongState` | show generic error |

## Cubit / Helper Methods
```dart
// Change password:
context.read<AuthCubit>().changePassword(
  currentPassword: currentPw,
  newPassword: newPw,
);

// Theme:
getIt<ThemeHelper>().toggleTheme();
// Read: context.watch<ThemeMode>() or use StatefulWidget + listen to ThemeHelper

// Language:
getIt<LocaleHelper>().setLocale(const Locale('en'));
getIt<LocaleHelper>().setLocale(const Locale('ro'));

// Version:
final info = await PackageInfo.fromPlatform();
info.version; // e.g. '1.0.0'
```

## Package Info
Requires `package_info_plus` (already in pubspec.yaml):
```dart
import 'package:package_info_plus/package_info_plus.dart';
```
Load in initState and store in state.

## Colors / Styles
- Section headers: `tt.labelSmall`, `cs.onSurfaceVariant`, `letterSpacing: 1.2`
- Cards: `cs.surfaceContainerHigh`, `borderRadius: 16`, elevation: 0
- Enabled icons: `cs.primary`
- Disabled: `cs.outline`, `cs.onSurfaceVariant`
- Language active: `cs.primaryContainer` fill, `cs.onPrimaryContainer` text
- Log out: `cs.error`

## Navigation In/Out
- IN: from `ProfilePage` (push)
- OUT: back to Profile (pop), → `LoginRoute` (replace on sign out)
