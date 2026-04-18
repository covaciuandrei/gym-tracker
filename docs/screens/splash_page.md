# Splash Page — Screen Doc

> Last updated: 2026-04-18

## Route

`/` — initial route (auto_route `initial: true`)

## Purpose

Branded intro screen that doubles as the **cold-launch version gate**. Runs the
animated intro for a guaranteed minimum duration while `SplashCubit` fetches
`appConfig/version` from Firestore, classifies the result, and decides where to
send the user next.

## Layout

```
Scaffold(backgroundColor: cs.surface)
  SafeArea
    Column (animated intro)
      Spacer
      _LogoCard(gradient card + EmojiText(Emojis.biceps))  ← elastic pop-in
      Text('Gym Tracker', tt.displaySmall)                  ← slides up
      Text(tagline, tt.bodyLarge)              ← slides up with delay
      Spacer
      Dots loader (3 pulsing dots)
```

The page contains **no business logic** — it only runs the animation and hosts a
`BlocListener<SplashCubit, BaseState>` that routes with
`replaceAll` / `replace` when a terminal navigation state arrives.

## Cubit contract — `SplashCubit`

- `start({Duration minSplashDuration = 2.8s})` is invoked once from `initState`.
- Emits `PendingState` immediately, then `await Future.wait([Future.delayed(min), _resolveNavigation()])`.
- `_resolveNavigation()` order of precedence:
  1. `PackageInfo` + `AppConfigService.getAppConfig()` — any throw → `SplashNavigateNoConnectionState`.
  2. `config.maintenanceMode` → `SplashNavigateMaintenanceState(message)` using `config.messageFor(locale)` with `en` fallback.
  3. `VersionComparator.isBelow(current, config.minRequiredVersion)` → `SplashNavigateForceUpdateState(current, required, storeUrl)`.
  4. OK path: compute `bigUpdateAvailable = VersionComparator.isBigJump(current, config.latestVersion)`, call `AppVersionStatus.getAppVersionDetails(...)`, then:
     - `OnboardingHelper.isFirstLaunch` → `SplashNavigateOnboardingState`
     - `FirebaseAuth.currentUser != null` → `SplashNavigateMainShellState`
     - else → `SplashNavigateLoginState`
- `storeUrl` is resolved per-platform (`Platform.isAndroid ? androidStoreUrl : iosStoreUrl`) **inside the cubit** so the page never touches `dart:io`.

## Terminal navigation states

| State                             | Handler in page (`replaceAll`)                                |
| --------------------------------- | ------------------------------------------------------------- |
| `SplashNavigateMaintenanceState`  | `MaintenanceRoute(message: state.message)`                    |
| `SplashNavigateForceUpdateState`  | `ForceUpdateRoute(currentVersion, requiredVersion, storeUrl)` |
| `SplashNavigateNoConnectionState` | `NoConnectionRoute()`                                         |
| `SplashNavigateOnboardingState`   | `OnboardingRoute()` via `context.router.replace`              |
| `SplashNavigateMainShellState`    | `MainShellRoute()`                                            |
| `SplashNavigateLoginState`        | `LoginRoute()`                                                |

The page guards against duplicate navigation with a `_navigated` flag.

## Min-splash duration

`defaultMinSplashDuration = 2800ms`. Ensures the intro animation always plays to
completion even when Firestore returns instantly. Tests override it with
`Duration.zero`.

## Data / Dependencies

- `SplashCubit` (`@injectable`, `@factory` via `BaseCubit`)
- `AppConfigService` — reads `appConfig/version`
- `PackageInfo.fromPlatform()` — overridable in tests via `@visibleForTesting packageInfo()`
- `FirebaseAuth.instance.currentUser`
- `OnboardingHelper`, `LocaleHelper`
- `AppVersionStatus` (singleton) — populated on the ok path so `MainShellPage` can decide whether to show the big-update bottom sheet.

## Retry loop

`MaintenancePage` and `NoConnectionPage` both have a **Try again** button that
calls `context.router.replaceAll([const SplashRoute()])`. This rebuilds
`SplashPage`, creates a fresh `SplashCubit` (`@factory`), and re-runs the gate
from scratch — without restarting the process. The Dart VM, `getIt` singletons,
and Firebase connections stay alive.

## Status

✅ **IMPLEMENTED** — `lib/presentation/pages/splash/splash_page.dart` +
`lib/cubit/splash/splash_cubit.dart` + `lib/cubit/splash/splash_states.dart`
