# Splash Page — Screen Doc

> Last updated: 2026-04-08

## Route
`/splash` — initial route (auto_route `initial: true`)

## Purpose
Brief branded intro screen shown at app launch. Auto-navigates based on auth state.

## Layout
```
Scaffold(backgroundColor: cs.surface)
  SafeArea
    Column
      Spacer
      Text('💪', fontSize: 80)          ← logo emoji
      SizedBox(height: 24)
      Text('Gym Tracker', style: tt.displayMedium)
      SizedBox(height: 8)
      Text('Track your gym journey', style: tt.bodyLarge, color: cs.onSurfaceVariant)
      Spacer
      CircularProgressIndicator(color: cs.primary)
      SizedBox(height: 48)
```

## Navigation Logic
- Delay: `Future.delayed(Duration(seconds: 2))`
- Check: `FirebaseAuth.instance.currentUser != null`
- If authenticated → `context.router.replace(MainShellRoute())`
- If unauthenticated → `context.router.replace(LoginRoute())`

## Data / Dependencies
- `firebase_auth` — `FirebaseAuth.instance.currentUser`
- `auto_route` — `context.router.replace`
- No cubit needed

## Status
✅ **IMPLEMENTED** — `lib/presentation/pages/splash/splash_page.dart`
