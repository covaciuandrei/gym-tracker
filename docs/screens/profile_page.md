# Profile Page — Screen Doc

> Last updated: 2026-05-11

## Route

`/profile` (child of MainShell, tab index 4)

## Source

`lib/presentation/pages/profile/profile_page.dart`

## Page Setup

- `@RoutePage()` annotation
- `implements AutoRouteWrapper` → `BlocProvider<AuthCubit>`
- `StatefulWidget`
- `initState` → `authCubit.watchAuthState()`

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: l10n.profileTitle, showBackButton: false)
  SafeArea
    SingleChildScrollView(padding: h16+v16)
      Center → ConstrainedBox(maxWidth: 600)
        Column(crossAxisAlignment: start)

          ── User Card ──
          _UserCard(user)
            Card(surfaceContainerHigh, borderRadius: 16)
              Padding(16)
                Row
                  CircleAvatar(radius: 32, bg: cs.primaryContainer)
                    Text(initial, headlineSmall, w700)
                  SizedBox(width: 16)
                  Expanded Column
                    Text(displayName, titleLarge, w600)
                    Text(email, bodyMedium, cs.onSurfaceVariant)
                    if (emailVerified):
                      verified icon + "Verified" (cs.primary)

          SizedBox(height: 24)

          ── MANAGE section ──
          _SectionHeader("MANAGE")
          Card(surfaceContainerHigh, borderRadius: 16) [
            ListTile(settings, "Settings", chevron) → SettingsRoute
          ]

          SizedBox(height: 24)

          ── ACCOUNT section ──
          _SectionHeader("ACCOUNT")
          Card(surfaceContainerHigh, borderRadius: 16) [
            ListTile(logout, "Sign Out", color: cs.error, spinner when signing out)
              → authCubit.signOut()
          ]
```

## State → UI Mapping

### AuthCubit (BlocConsumer)

**listenWhen:**

| State | Side Effect |
|---|---|
| `AuthSignOutSuccessState` / `AuthUnauthenticatedState` | `ctx.router.replace(LoginRoute())` |
| `SomethingWentWrongState` | SnackBar |

**builder:**

| State | UI |
|---|---|
| `AuthAuthenticatedState(user)` | Render user card with user data |
| `PendingState` | Show sign-out spinner |

## Controls Used

- `GymAppBar`

## Navigation In/Out

- IN: MainShell tab 4
- OUT: → `SettingsRoute` (push), → `LoginRoute` (replace on sign out)

## Status

✅ **IMPLEMENTED**
# Profile Page — Prep Notes

## Route
`/profile` (child of MainShell, tab index 3)

## Angular Source
`src/app/features/user/profile/`

## Layout
```
Scaffold
  SafeArea
    SingleChildScrollView
      Column(padding: 24)
        SizedBox(height: 16)
        Text('Profile', style: tt.displaySmall)
        SizedBox(height: 32)

        ── User card ──
        Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 16)
          Padding(16)
            Row
              ── Avatar ──
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.primaryContainer,
                child: Text(
                  user.email[0].toUpperCase(),
                  style: tt.displaySmall.copyWith(color: cs.onPrimaryContainer)
                )
              )
              SizedBox(width: 16)
              ── Info ──
              Expanded(Column(crossAxisAlignment: start))
                Text(user.displayName ?? 'Gym Tracker User', style: tt.headlineSmall)
                SizedBox(height: 4)
                Text(user.email, style: tt.bodyMedium, color: cs.onSurfaceVariant)
                if (user.emailVerified):
                  SizedBox(height: 4)
                  Row
                    Icon(Icons.verified, color: cs.primary, size: 16)
                    SizedBox(width: 4)
                    Text('Verified', style: tt.labelSmall, color: cs.primary)
        SizedBox(height: 24)

        ── Manage section ──
        Text('MANAGE', style: tt.labelSmall.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2))
        SizedBox(height: 8)
        Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 16)
          Column
            ListTile(
              leading: Icon(Icons.fitness_center, color: cs.primary),
              title: Text('Workout Types', style: tt.titleMedium),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.router.push(const WorkoutTypesRoute()),
            )
            Divider(indent: 16, endIndent: 16, height: 1)
            ListTile(
              leading: Icon(Icons.settings, color: cs.primary),
              title: Text('Settings', style: tt.titleMedium),
              trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
              onTap: () => context.router.push(const SettingsRoute()),
            )
        SizedBox(height: 24)

        ── Account section ──
        Text('ACCOUNT', style: tt.labelSmall.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2))
        SizedBox(height: 8)
        Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 16)
          ListTile(
            leading: Icon(Icons.logout, color: cs.error),
            title: Text('Sign Out', style: tt.titleMedium.copyWith(color: cs.error)),
            trailing: isSigningOut
              ? SizedBox(16, 16, child: CircularProgressIndicator(strokeWidth: 2))
              : null,
            onTap: _onSignOut,
          )
```

## Interactions
| Element | Action |
|---|---|
| "Workout Types" tile | `context.router.push(WorkoutTypesRoute())` |
| "Settings" tile | `context.router.push(SettingsRoute())` |
| "Sign Out" tile | `context.read<AuthCubit>().signOut()` |

## State → UI Mapping (AuthCubit)
| State | Behavior |
|---|---|
| `PendingState` | show spinner in Sign Out trailing |
| `AuthSignOutSuccessState` | `context.router.replace(LoginRoute())` |
| `SomethingWentWrongState` | show error snackbar |
| `AuthAuthenticatedState(user)` | render user info (displayName, email, verified) |

## Getting Current User
```dart
// Option A: use AuthCubit state (user already in state)
final state = context.read<AuthCubit>().state;
if (state is AuthAuthenticatedState) { ... state.user ... }

// Option B: directly
final user = FirebaseAuth.instance.currentUser;
```
`AuthUser` model fields:
- `email: String`
- `displayName: String?`
- `emailVerified: bool`

## Colors / Styles
- Section headers: `tt.labelSmall`, `cs.onSurfaceVariant`, `letterSpacing: 1.2`
- Cards: `cs.surfaceContainerHigh`, `borderRadius: 16`, elevation: 0
- Avatar: `cs.primaryContainer` / `cs.onPrimaryContainer`
- Primary icon: `cs.primary`
- Verified badge: `cs.primary`
- Sign Out: `cs.error`
- Chevron: `cs.onSurfaceVariant`

## Navigation In/Out
- IN: MainShell tab 3
- OUT: → `WorkoutTypesRoute` (push), → `SettingsRoute` (push), → `LoginRoute` (replace on sign out)
