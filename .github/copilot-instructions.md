# Copilot Instructions — gym_tracker

For now these copilot-instructions are not really up to date, but almost up to date. dont really follow exactly everything. everything you read heare must be treated more like a suggestion. if you have any question or are not sure about something, ask me. also, if you have any suggestion on how to improve the instructions, please let me know.

> **Single source of truth** for AI role, reference data, architecture map,
> and all coding rules/conventions.

## 1. Role

You are an **Expert Senior Flutter Architect** specializing in pixel-perfect Flutter
migration of web UIs. You have deep knowledge of Material 3, BLoC/Cubit, Firebase,
auto_route, and clean architecture.

---

## 2. Environment (quick reference)

| Item             | Version                                     |
| ---------------- | ------------------------------------------- |
| Flutter SDK      | **3.41.0**                                  |
| Dart SDK         | **^3.11.0**                                 |
| Java JDK         | **17**                                      |
| Target platforms | **Android + iOS only** (no web, no desktop) |
| State management | **flutter_bloc / Cubit**                    |
| Navigation       | **auto_route**                              |
| Backend          | **Firebase Auth + Firestore**               |

**Every dependency version, API call, and code pattern you suggest must be
compatible with Flutter 3.41.0 / Dart ^3.11.0.** Do not suggest packages or
APIs that require a newer Flutter version.

---

## 3. Project Purpose

`gym_tracker` is a gym attendance and health tracking app for Android and iOS.
It tracks workouts, supplement intake, and provides statistics — all backed by
Firebase Auth + Firestore.

---

## 4. Design Token Reference

All design tokens are centralized — never hardcode colors or radius values:

| Flutter constant                | CSS variable               | Value     |
| ------------------------------- | -------------------------- | --------- |
| `AppColors.primary`             | `--primary-color`          | `#6366f1` |
| `AppColors.primaryDark`         | `--primary-dark`           | `#4f46e5` |
| `AppColors.backgroundDark`      | `--bg-color` (dark)        | `#0f172a` |
| `AppColors.surfaceDark`         | `--card-bg` (dark)         | `#1e293b` |
| `AppColors.surfaceElevatedDark` | `--surface-overlay` (dark) | `#334155` |
| `AppColors.borderDark`          | `--border-color` (dark)    | `#334155` |
| `AppColors.backgroundLight`     | `--bg-color` (light)       | `#f8fafc` |
| `AppColors.surfaceLight`        | `--card-bg` (light)        | `#ffffff` |
| `AppColors.borderLight`         | `--border-color` (light)   | `#e2e8f0` |
| `AppColors.textPrimary`         | `--text-primary` (dark)    | `#f1f5f9` |
| `AppColors.textSecondary`       | `--text-secondary` (dark)  | `#94a3b8` |
| `AppColors.textPrimaryLight`    | `--text-primary` (light)   | `#1e293b` |
| `AppColors.textSecondaryLight`  | `--text-secondary` (light) | `#64748b` |
| `AppColors.success`             | —                          | `#10b981` |
| `AppColors.danger`              | —                          | `#ef4444` |
| `AppColors.calWorkout`          | `--cal-workout`            | `#3b82f6` |
| `AppColors.calSupplement`       | `--cal-supp`               | `#10b981` |
| `AppColors.calBoth`             | `--cal-both`               | `#06b6d4` |

**Border radii:**

- Auth page cards: `24px` (1.5rem)
- Section/stat/health cards: `16px`
- List item cards (type tiles, setting rows): `12px`
- Primary buttons: `12px`
- Input fields: `12px`
- Icon-grid buttons: `8px`

**Input fields:** Always `border-width: 2`, `fillColor: AppColors.backgroundDark/Light`
(inputs look recessed inside cards — darker than the card surface).

**Primary button gradient:**

```dart
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  ),
  borderRadius: BorderRadius.circular(12),
),
```

---

## 5. Controls Inventory

| File                               | What it is                                                                                                                                                                                                                                                                                                                             |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `gradient_button.dart`             | Full-width indigo-gradient button; shows spinner when `isLoading: true`. **Use for every primary submit action.**                                                                                                                                                                                                                      |
| `primary_button.dart`              | Material `ElevatedButton` wrapper; use only for secondary/outline actions that don't need gradient.                                                                                                                                                                                                                                    |
| `primary_fab.dart`                 | Standard reusable FloatingActionButton wrapper for add/create actions across tabs/pages.                                                                                                                                                                                                                                               |
| `custom_text_field.dart`           | Styled `TextFormField`; handles password-visibility toggle internally. Use for all form inputs.                                                                                                                                                                                                                                        |
| `search_input.dart`                | Reusable search field with search icon and clear action; use for searchable list/catalog pages.                                                                                                                                                                                                                                        |
| `error_banner.dart`                | Inline red pill for form-level server errors. Use below form fields, above the submit button.                                                                                                                                                                                                                                          |
| `error_state.dart`                 | Full-section error (emoji + title + retry). Use for page-level load failures.                                                                                                                                                                                                                                                          |
| `empty_state.dart`                 | No-data placeholder (emoji + title + optional CTA). Use when a list/section has zero items.                                                                                                                                                                                                                                            |
| `confirmation_dialog.dart`         | Generic yes/no destructive confirmation dialog with customizable labels and confirm color.                                                                                                                                                                                                                                             |
| `action_bottom_sheet.dart`         | Reusable draggable modal-sheet scaffold (handle, title, body, footer). Use for create/edit forms and action sheets.                                                                                                                                                                                                                    |
| `password_strength_indicator.dart` | Animated strength bar + 4 requirement bullets. Add below every new-password field. Uses `ListenableBuilder` — no setState.                                                                                                                                                                                                             |
| `password_match_indicator.dart`    | Green/red match label below confirm-password field. Uses `ListenableBuilder.merge` — no setState.                                                                                                                                                                                                                                      |
| `form_card.dart`                   | Styled card container for auth forms (shadow, rounded corners, `surfaceContainerHigh` bg). Takes `formKey` + `children`; wraps them in `AutofillGroup > Form > Column`. **Use as the base for every form panel instead of duplicating the decoration.**                                                                                |
| `success_card.dart`                | Green-tinted confirmation card. Takes `title`, `message`, `buttonLabel`, `onAction`, optional `icon` (default `✅`). **Use after any successful async action (sign-up, password reset, etc.).**                                                                                                                                        |
| `surface_section_card.dart`        | Generic elevated surface card for settings/section blocks with shared styling and rounded corners.                                                                                                                                                                                                                                     |
| `main_list_item.dart`              | Reusable list item card (title + optional leading/trailing + tap) for simple entity rows.                                                                                                                                                                                                                                              |
| `summary_action_card.dart`         | Reusable entity summary card (subtitle/title/description + optional action row + optional onTap). Use for catalog and summary lists.                                                                                                                                                                                                   |
| `labeled_value_tile.dart`          | Reusable list tile for static key-value rows (for example app version/about rows).                                                                                                                                                                                                                                                     |
| `option_toggle.dart`               | Generic segmented option toggle using chips/buttons for language/view-mode filters.                                                                                                                                                                                                                                                    |
| `auth_footer_link.dart`            | Divider + centred "prompt + action-link" row. Used at the bottom of every auth screen to switch between pages. Takes `prompt`, `actionLabel`, `onTap`, optional `enabled` (pass `!isLoading` to disable during requests).                                                                                                              |
| `emoji_text.dart`                  | Shared wrapper for rendering emoji symbols consistently across cards, labels, and icon-like UI elements.                                                                                                                                                                                                                               |
| `gym_app_bar.dart`                 | Standard app bar wrapper used across feature pages for consistent title/back/action behavior.                                                                                                                                                                                                                                          |
| `gym_tab_bar.dart`                 | Shared tab-strip control used by pages with segmented content (calendar, stats, health).                                                                                                                                                                                                                                               |
| `set_password_card.dart`           | Reusable password form card (current/new/confirm variants) used in auth action and change-password flows.                                                                                                                                                                                                                              |
| `big_update_bottom_sheet.dart`     | Modal bottom-sheet content announcing a "big" version bump (major jump or minor ≥2). Presented from `MainShellPage` when `CheckingUpdateCubit` emits `CheckingUpdateShowSheetState`. Exposes `latestVersion`, `onUpdate`, `onLater` callbacks; the caller pops the sheet and delegates to cubit actions (`updateNow` / `remindLater`). |

---

## 6. Key File Locations

| What                     | Where                                                        |
| ------------------------ | ------------------------------------------------------------ |
| Colors                   | `lib/presentation/resources/app_colors.dart`                 |
| Theme                    | `lib/assets/theme/custom_theme.dart`                         |
| Router                   | `lib/core/app_router.dart` (generated: `app_router.gr.dart`) |
| DI                       | `lib/core/injection.dart`                                    |
| Pages                    | `lib/presentation/pages/<feature>/`                          |
| Reusable controls        | `lib/presentation/controls/`                                 |
| Cubits                   | `lib/cubit/<feature>/`                                       |
| Models                   | `lib/model/`                                                 |
| Services                 | `lib/service/<feature>/`                                     |
| Firestore sources + DTOs | `lib/data/remote/<feature>/`                                 |
| Mappers                  | `lib/data/mappers/`                                          |
| Screen prep docs         | `docs/screens/<page_name>.md`                                |
| App version status cache | `lib/core/app_version_status.dart`                           |
| App version gate docs    | `docs/app_version_gate/`                                     |

---

## 7. Feature & Route Map

> Full inventory of every feature, route, and Firestore collection.

### 7.1 Route Tree

```
/                         → SplashPage (initial)
/login          [guest]   → LoginPage          (lib/presentation/pages/auth/login_page.dart)
/register       [guest]   → RegisterPage       (lib/presentation/pages/auth/register_page.dart)
/forgot-password[guest]   → ForgotPasswordPage (lib/presentation/pages/auth/forgot_password_page.dart)
/app                      → MainShellPage      (lib/presentation/pages/main_shell/main_shell_page.dart)
  /app/calendar           → CalendarPage       (tab child)
  /app/stats              → StatsPage          (tab child)
  /app/health             → HealthPage         (tab child)
  /app/profile            → ProfilePage        (tab child)
/workout-types  [auth]    → WorkoutTypesPage   (lib/presentation/pages/workout_types/workout_types_page.dart)
/settings       [auth]    → SettingsPage       (lib/presentation/pages/settings/settings_page.dart)
/change-password[auth]    → ChangePasswordPage (lib/presentation/pages/change_password/change_password_page.dart)
/maintenance    [guest]   → MaintenancePage    (lib/presentation/pages/maintenance/maintenance_page.dart)
/force-update   [guest]   → ForceUpdatePage    (lib/presentation/pages/force_update/force_update_page.dart)
/no-connection  [guest]   → NoConnectionPage   (lib/presentation/pages/no_connection/no_connection_page.dart)
```

**Auth gating in current implementation:**

- No `auto_route` guard classes are registered.
- `SplashPage` runs the `SplashCubit` version gate **before** evaluating auth; it then `replaceAll`s with one of the terminal routes: `MaintenanceRoute`, `ForceUpdateRoute`, `NoConnectionRoute`, `OnboardingRoute`, `MainShellRoute`, or `LoginRoute`.
- Feature pages also self-check auth and redirect to `LoginRoute` when user is missing.

### 7.2 Feature Inventory

#### AUTH FEATURE

| Component                   | Actions / State                                                                                                                                                                                                                    |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **LoginComponent**          | `email`, `password` fields; `isLoading`, `errorMessage`; `onSubmit()` → `authService.signIn()` → navigate `MainShell` (`/app/calendar` tab); link to `/register`, `/forgot-password`                                               |
| **RegisterComponent**       | `email`, `password`, `confirmPassword`; validates: email format, password ≥8 chars + uppercase + lowercase + number, passwords match; `onSubmit()` → `authService.signUp()` → shows "verify email" success state; link to `/login` |
| **ForgotPasswordComponent** | `email` field; `isLoading`, `errorMessage`, `successMessage`; `onSubmit()` → `authService.resetPassword(email)` → success message; email validation; link back to `/login`                                                         |

#### CALENDAR FEATURE

| Aspect                     | Detail                                                                                                                                      |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| **View modes**             | `monthly` (default) and `yearly` toggle                                                                                                     |
| **Monthly grid**           | 7-col Mon-first grid, 42 cells (prev/current/next month days), today highlighted                                                            |
| **Yearly grid**            | 12 mini-month grids side by side, same Mon-first layout                                                                                     |
| **Day cell states**        | `attended` (workout only), `supplement` only, `both`, plain/today                                                                           |
| **Day cell colours**       | workout=`calWorkout` (#3b82f6), supplement=`calSupplement` (#10b981), both=`calBoth` (#06b6d4)                                              |
| **Day cell icon**          | Shows workout-type emoji icon if a type was assigned                                                                                        |
| **Navigation**             | ← → arrows (prev/next month or prev/next year); year shown in header                                                                        |
| **Day tap → popup**        | Bottom sheet / dialog with two tabs: **Workout** tab and **Health** tab                                                                     |
| **Workout tab actions**    | Toggle attendance (mark/unmark); select workout type from dropdown; select duration (optional); edit type/duration on already-attended days |
| **Health tab actions**     | Show today's supplement logs (carousel with pages of 2); log a supplement (product dropdown); remove individual supplement log              |
| **Data loading**           | Monthly view pre-loads 3 months (prev + current + next) in parallel; yearly loads full year                                                 |
| **Workout types dropdown** | Custom dropdown (not native select); shows emoji + name + colour dot                                                                        |
| **Products dropdown**      | Custom dropdown for supplement selection                                                                                                    |
| **Skeleton loading**       | Array(42) skeleton cells during load                                                                                                        |

#### STATS FEATURE

Stats is a **shell with 4 sub-tabs**. The year is shared via query param `?year=`.

| Tab             | What it shows                                                                                                           |
| --------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Attendances** | Total workouts (year), current month count, monthly bar chart (12 bars), streak (current + best), days-per-week heatmap |
| **Workouts**    | Workout type breakdown (year): pie/list of types × count; monthly breakdown: selected month type distribution           |
| **Duration**    | Total hours (year), avg duration/session, monthly duration bar chart, per-type avg duration list                        |
| **Health**      | Total supplement servings (year), most-taken product, monthly supplement bar chart, top nutrients breakdown             |

All stats tabs share:

- Year selector (← current year →) — changes `?year=` query param
- Loading skeleton cards
- "No data" empty state when no records

#### HEALTH FEATURE

| Aspect                      | Detail                                                                                                                                                                                                       |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **View modes**              | 3 tabs: `today` (default), `my_supplements`, `all_supplements`                                                                                                                                               |
| **Today tab**               | Lists today's supplement logs grouped by product; shows product name + brand + servings taken; delete individual log                                                                                         |
| **My Supplements tab**      | Lists products created by current user; search bar; edit/delete each product; "Add product" FAB                                                                                                              |
| **All Supplements tab**     | Lists all products (global + user-created); search bar; verified badge on global products; add to today's log                                                                                                |
| **SupplementFormComponent** | Create/edit supplement product: `name`, `brand`, ingredient list (autocomplete from Firestore `ingredients` collection with stdId, amount, unit); save → `firebaseService.addProduct()` or `updateProduct()` |
| **Auto-seed**               | On first load, if `ingredients` collection is empty, seeds it from `core/constants/ingredients.ts`                                                                                                           |

#### WORKOUT TYPES FEATURE

| Aspect                 | Detail                                                                                  |
| ---------------------- | --------------------------------------------------------------------------------------- |
| **List view**          | Grid/list of cards; each card: emoji icon + name + colour dot + edit/delete buttons     |
| **Empty state**        | "No workout types yet" with create button                                               |
| **Create modal**       | Fields: name (text), colour picker (10 preset swatches), icon picker (20 preset emojis) |
| **Edit modal**         | Same form, pre-populated                                                                |
| **Delete**             | Confirmation dialog before delete                                                       |
| **Predefined colours** | `#6366f1 #8b5cf6 #ec4899 #ef4444 #097853 #eab308 #22c55e #14b8a6 #0ea5e9 #3b82f6`       |
| **Predefined icons**   | 🏋️ 🏃 🚴 🧘 🥊 🏊 ⚽ 🎾 🏀 💪 🤸 🚣 ⛹️ 🤾 🌏 🧗 🎯 🔥 ⭐ 🌟                             |
| **Navigation**         | Accessed from profile/manage area; back button returns to previous route                |

#### PROFILE FEATURE

| Aspect         | Detail                                                          |
| -------------- | --------------------------------------------------------------- |
| **Avatar**     | Circle with user's initial (first char of displayName or email) |
| **Info shown** | displayName (or "User"), email, email-verified badge            |
| **Actions**    | Logout button → `authService.signOut()` → navigate `/login`     |
| **Links**      | → `/settings`, → `/workout-types`                               |

#### SETTINGS FEATURE

| Aspect                 | Detail                                                                                              |
| ---------------------- | --------------------------------------------------------------------------------------------------- |
| **Appearance section** | Dark/light theme toggle → `themeService.toggleTheme()`                                              |
| **Language section**   | Language picker (EN / RO) → `languageService.setLanguage(lang)`                                     |
| **Account section**    | "Change password" navigates to dedicated `ChangePasswordPage`; form uses reusable `SetPasswordCard` |
| **App version**        | Loaded dynamically via `package_info_plus` in `SettingsCubit.init()`                                |
| **Navigation**         | Back arrow → previous page                                                                          |

#### APP VERSION GATE FEATURE

| Component                 | Actions / State                                                                                                                                                                                                                                   |
| ------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **SplashCubit**           | Reads current version via `PackageInfo`, fetches `appConfig/version`, classifies result, waits for min-splash duration (2.8s), populates `AppVersionStatus` on the ok path, and emits a terminal navigation state.                                |
| **States**                | `SplashNavigateMaintenanceState`, `SplashNavigateForceUpdateState`, `SplashNavigateNoConnectionState`, `SplashNavigateOnboardingState`, `SplashNavigateMainShellState`, `SplashNavigateLoginState`.                                               |
| **MaintenancePage**       | Blocker; shows maintenance illustration from `lib/assets/images/maintenance.png` plus localized message from `appConfig.maintenanceMessages[lang]` with `en` fallback. "Try again" button `replaceAll`s back to `SplashRoute` to re-run the gate. |
| **ForceUpdatePage**       | Blocker; shows current vs required version; "Update now" opens `storeUrl` (already resolved per-platform by the cubit).                                                                                                                           |
| **NoConnectionPage**      | Shown when the config fetch throws. "Try again" button `replaceAll`s back to `SplashRoute`.                                                                                                                                                       |
| **CheckingUpdateCubit**   | Main-shell cubit that runs `evaluate()` after shell mount, applies a 2-second presentation delay, emits `CheckingUpdateShowSheetState` when eligible, and handles `updateNow()` / `remindLater()` actions from the sheet.                         |
| **CheckingUpdateService** | Service used by `CheckingUpdateCubit`; checks `AppVersionStatus` + 3-day per-version cool-down in `SharedPreferences`, and opens store URLs with `url_launcher`.                                                                                  |
| **BigUpdateBottomSheet**  | Presented by `MainShellPage` when `CheckingUpdateShowSheetState` is emitted. Displays `latestVersion` and delegates CTA taps back to the cubit callbacks.                                                                                         |
| **Version classifier**    | `VersionComparator.isBigJump(from, to)` — true iff major increased OR minor diff ≥ 2. Single-step minor / patch bumps are silent.                                                                                                                 |
| **Dismissal cool-down**   | `SharedPreferences` keys `big_update_dismissed_version` + `big_update_dismissed_at_ms`. Sheet re-appears when `latestVersion` changes OR 3 days have elapsed.                                                                                     |

### 7.3 Firestore Data Model

```
firestore/
├── users/{userId}/
│   ├── (profile fields)
│   │   ├── email                        String   ← always mirrors Firebase Auth (source of truth)
│   │   ├── displayName                  String   ← set on first-login bootstrap (nickname)
│   │   ├── lastVerificationEmailSentAt  Timestamp? ← cooldown tracking for resend buttons; cleared on login
│   │   ├── theme                        String   ← 'dark' | 'light'
│   │   ├── language                     String   ← 'en' | 'ro'
│   │   ├── lastLoginAt                  Timestamp
│   │   ├── createdAt                    Timestamp
│   │   └── stats.totalAttendances       Number
│   │
│   ├── trainingTypes/{typeId}
│   │   └── { name, color, icon, createdAt }
│   ├── attendances/{YYYY-MM}/days/{YYYY-MM-DD}
│   │   └── { date, timestamp, trainingTypeId?, durationMinutes?, notes? }
│   └── healthLogs/{YYYY-MM}/entries/{logId}
│       └── { date, productId, productName?, productBrand?, servingsTaken, timestamp? }
│
├── supplementProducts/{productId}
│   └── { name, brand, ingredients:[{stdId,name,amount,unit}],
│          servingsPerDayDefault, createdBy?, verified? }
│
└── ingredients/{stdId}
    └── { name, aliases?, category, defaultUnit, safeUpperLimit?, rda? }

appConfig/
└── version                     ← public-read singleton, fetched on every cold-launch
    ├── minRequiredVersion      String   ← below this = force update
    ├── latestVersion           String   ← used by BigUpdateBottomSheet when diff is "big"
    ├── maintenanceMode         Bool
    ├── maintenanceMessages     Map<String,String>  ← { en, ro } with 'en' fallback
    ├── androidStoreUrl         String
    ├── iosStoreUrl             String
    └── updatedAt               Timestamp?
```

**Key Firestore patterns:**

- All `UserSource` writes use `SetOptions(merge: true)` — safe for concurrent updates, preserves subcollections and existing fields.
- `lastVerificationEmailSentAt` uses `Timestamp.now()` (device time) — avoids server/device clock skew in cooldown computation.
- `lastVerificationEmailSentAt` is cleared on successful login via `_initializeProfileOnFirstLogin()`.
- Reads on `appConfig/version` are **public** (anyone, including signed-out users) and happen on every cold-launch before any auth flow. Writes are blocked — only the Firebase Console can update it.

### 7.4 Service / Source Map

| Domain                 | Service                                                                   | Source                                                                  |
| ---------------------- | ------------------------------------------------------------------------- | ----------------------------------------------------------------------- |
| Auth                   | `lib/service/auth/auth_service.dart`                                      | — (Firebase Auth SDK directly)                                          |
| Auth (cubit)           | `lib/cubit/auth/auth_cubit.dart`                                          |                                                                         |
| User profile           | `lib/service/user/user_service.dart`                                      | `lib/data/remote/user/user_source.dart`                                 |
| Attendance             | `lib/service/attendance/attendance_service.dart`                          | `lib/data/remote/attendance/attendance_day_source.dart`                 |
| Workout types          | `lib/service/workout/workout_service.dart`                                | `lib/data/remote/training_type/training_type_source.dart`               |
| Health / Supplements   | `lib/service/health/health_service.dart`                                  | `lib/data/remote/supplement/health_source.dart`                         |
| Stats                  | `StatsCubit` composes attendance/workout/health services                  | —                                                                       |
| App config             | `lib/service/app_config/app_config_service.dart`                          | `lib/data/remote/app_config/app_config_source.dart`                     |
| App version gate       | `lib/cubit/splash/splash_cubit.dart` + `lib/core/app_version_status.dart` | — (reads `AppConfigService`)                                            |
| Checking update prompt | `lib/service/checking_update/checking_update_service.dart`                | — (uses `SharedPreferences` + `url_launcher`, reads `AppVersionStatus`) |
| Theme                  | `lib/assets/theme/theme_helper.dart`                                      | —                                                                       |
| Language               | `lib/presentation/helpers/locale_helper.dart`                             | —                                                                       |

---

## 8. App Navigation Flowchart

```
App Start
    │
    ▼
SplashPage (SplashCubit: min 2.8s animation + appConfig/version fetch)
    │
    ├── maintenanceMode == true ─────────────────────► MaintenancePage   (replaceAll)
    │                                                      └── [Try again] → SplashRoute (re-runs gate)
    │
    ├── current < minRequiredVersion ────────────────► ForceUpdatePage   (replaceAll)
    │                                                      └── [Update now] → launchUrl(storeUrl)
    │
    ├── config fetch threw ──────────────────────────► NoConnectionPage  (replaceAll)
    │                                                      └── [Try again] → SplashRoute
    │
    └── OK path (optionally bigUpdateAvailable)
          │
          ├── OnboardingHelper.isFirstLaunch ────────► OnboardingPage
          │
          ├── FirebaseAuth.currentUser == null ──────► LoginPage
    │                                                      │
    │                                                      ├── [submit] signIn()
    │                                                      │       ├── success + verified ──► MainShell
    │                                                      │       ├── success + unverified ► LoginPage (verify-email message)
    │                                                      │       └── error ───────────────► ErrorBanner (inline)
    │                                                      │
    │                                                      ├── [tap "Register"] ──────────── RegisterPage
    │                                                      │       ├── [submit] signUp()
    │                                                      │       │       ├── success ──────► LoginPage (check-email state)
    │                                                      │       │       └── error ────────► ErrorBanner (inline)
    │                                                      │       └── [tap "Login"] ─────── LoginPage
    │                                                      │
    │                                                      └── [tap "Forgot password"] ───── ForgotPasswordPage
    │                                                              ├── [submit] resetPassword()
    │                                                              │       ├── success ──────► success message (stay on page)
    │                                                              │       └── error ────────► ErrorBanner (inline)
    │                                                              └── [tap "Back to login"] LoginPage
    │
          └── FirebaseAuth.currentUser != null ────────► MainShell (bottom nav)
                                                         │
                                                         ├── post-frame → CheckingUpdateCubit.evaluate()
                                                         │     (2s delay + eligibility checks in CheckingUpdateService)
                                                         │        └── emits ShowSheet → BigUpdateBottomSheet
                                                         │              ├── [Update now] → CheckingUpdateCubit.updateNow() → launchUrl(storeUrl)
                                                         │              └── [Remind me later] → CheckingUpdateCubit.remindLater() → persist 3-day snooze
                                                         │
                              ┌──────────────────────────┼──────────────────────────┐
                              ▼                          ▼                          ▼ (+ more tabs)
                        CalendarPage               StatsPage                  ProfilePage
                              │                          │                          │
                              │             ┌────────────┼──────────────┐           ├── [tap Settings link] ──► SettingsPage
                              │             ▼            ▼              ▼           │       ├── Toggle theme
                              │        Attendances   Workouts        Duration       │       ├── Change language
                              │           tab          tab             tab          │       └── Change password
                              │                         │                           │             └── changePassword(currentPassword, newPassword)
                              │                    HealthTab                        │
                              │                                                     └── [tap Workout Types link] ► WorkoutTypesPage
                              │                                                             ├── [+ FAB] ───► Create modal
                              │                                                             ├── [edit]  ───► Edit modal
                              │                                                             └── [delete] ──► Confirm dialog → delete
                              │
                              ├── [tap day cell] ──────────────────────────────────────────── Day Popup
                              │       ├── Workout tab
                              │       │       ├── [unattended] → select type (optional) + duration (optional) → Mark as attended
                              │       │       └── [attended]   → Edit type/duration  OR  Remove attendance
                              │       └── Health tab
                              │               ├── Show supplement logs (carousel, 2 per page)
                              │               ├── [+ add] → select product from dropdown → Log supplement
                              │               └── [remove] → remove individual log entry
                              │
                              └── [Monthly/Yearly toggle] ──────────────────────────────────► Switch calendar view


Firebase email links (out-of-app):
    │
    └── Email verification & password reset are handled by Firebase's default
        hosted action page (https://<project>.firebaseapp.com/__/auth/action).
        No in-app deep-link handling — users complete the action in the browser
        and then return to the app to sign in.
```

### 8.1 Authentication State Machine

> On cold-launch, the `SplashCubit` version gate runs **before** any auth state
> is evaluated. Maintenance / force-update / no-connection states short-circuit
> the auth flow entirely — the user never reaches `UNAUTHENTICATED` or
> `AUTHENTICATED` in those cases.

```
State: UNAUTHENTICATED
    ├── signIn(email, pwd)
    │       ├── OK + verified   → AUTHENTICATED  (bootstrapOnSignIn writes profile)
    │       └── OK + unverified → UNAUTHENTICATED (auto sign-out)
    ├── signUp(email, pwd) → sends verification email → UNAUTHENTICATED (must verify)
    └── (email verification & password reset handled by Firebase hosted page)

State: AUTHENTICATED
    ├── signOut()
    │       → authService.signOut()
    │       → UNAUTHENTICATED
    │
    ├── changePassword(currentPassword, newPassword)
    │       → reauthenticate + updatePassword()
    │       → stays AUTHENTICATED
    │
    └── deleteAccount(currentPassword)
            → reauthenticate
            → AccountCleanupService.deleteAllUserData()  [Firestore first]
            → authService.deleteAccount()                [Auth second]
            → UNAUTHENTICATED
```

### 8.1.4 First-Login Bootstrap

```
signIn() / signUp() success
    │
    └── _initializeProfileOnFirstLogin() [best-effort]
            │
            └── UserSource.bootstrapOnSignIn(userId, email, displayName?)
                    │
                    └── Firestore merge write:
                            {
                              email: authEmail,         ← always synced from Auth
                              displayName: nickname,    ← from signUp, or preserved on signIn
                              theme: 'dark',            ← default (only on first create)
                              language: 'en',           ← default (only on first create)
                              lastLoginAt: serverTime,
                              createdAt: serverTime,    ← only on first create
                            }
                            SetOptions(merge: true) — safe for existing docs
```

### 8.2 Calendar Day Cell State Machine

```
Day cell in initial state (no attendance, no supplement)
    │
    ├── tap → Popup opens (Workout tab default)
    │       │
    │       ├── [Workout tab]
    │       │       ├── Select workout type (optional custom dropdown)
    │       │       ├── Select duration (optional number input, minutes)
    │       │       └── Tap "Mark as attended" → firestore markAttendance()
    │       │                └── cell turns blue/coloured with type icon
    │       │
    │       └── [Health tab]
    │               ├── (shows empty — no logs yet for this day)
    │               ├── Select product from dropdown
    │               └── Tap "Log" → firestore logSupplement()
    │                        └── cell gets green dot
    │
    └── If already attended:
            Popup opens showing existing data
            ├── [Workout tab] → shows current type/duration
            │       ├── "Edit" → dropdown + duration editable → "Save"
            │       └── "Remove attendance" → firestore removeAttendance()
            └── [Health tab] → shows supplement log carousel
                    ├── Each log: product name + servings + remove button
                    └── Add more supplement logs same as above
```

### 8.3 Stats Data Flow

```
StatsPage (shell)
    │  reads ?year= query param
    │
    ├── AttendancesTab
    │   ├── getYearAttendance(userId, year) → 12×MonthStat[]
    │   ├── totals: sum of all months
    │   ├── streak: consecutive attended days algorithm
    │   └── heatmap: group by weekday
    │
    ├── WorkoutsTab
    │   ├── getWorkoutTypeStats(userId, year) → WorkoutTypeStat[] (year totals)
    │   └── getMonthlyWorkoutTypeStats(userId, year, selectedMonth) → WorkoutTypeStat[]
    │
    ├── DurationTab
    │   ├── getYearDurationStats(userId, year) → { totalMinutes, avgMinutes, monthlyData[] }
    │   └── getWorkoutTypeDurationStats(userId, year) → WorkoutTypeDurationStat[]
    │
    └── HealthTab
        ├── getSupplementLogs(userId, year, month) → SupplementLog[]
        └── derives: totalServings, mostTakenProduct, topNutrients (from ingredient stdIds)
```

### 8.4 Health Page View Modes

```
HealthPage
    │
    ├── Tab: Today
    │   ├── getSupplementLogs(userId, thisYear, thisMonth) → filter by today
    │   ├── group by productId → GroupedLog[]
    │   └── each group: productName + brand + totalServings for today
    │           └── [remove] → removes individual SupplementLog entry
    │
    ├── Tab: My Supplements
    │   ├── getProducts() → filter by createdBy == userId
    │   ├── search bar (client-side filter by name/brand)
    │   ├── [edit card] → opens SupplementForm (pre-populated)
    │   ├── [delete card] → deleteProduct()
    │   └── [+ FAB] → opens empty SupplementForm
    │           SupplementForm:
    │               name + brand fields
    │               ingredient list: autocomplete from Firestore `ingredients`
    │               each ingredient: stdId (hidden) + name + amount + unit
    │               [save] → addProduct() or updateProduct()
    │
    └── Tab: All Supplements
        ├── getProducts() → all (global + user-created)
        ├── search bar (client-side filter)
        ├── verified badge on products where verified==true
        └── [Log today] → logSupplement(userId, today, productId, servingsTaken)
```

---

## 9. Architecture Rules

- **Layering:** `Page/Control → Cubit → Service → Source → Firestore`. Never skip a layer.
- **One cubit per page/feature** — cubits live in `lib/cubit/<feature>/`.
- **No business logic in widgets** — all state changes go through cubit methods.
- **Service + source pattern** — cubits call services (`lib/service/*`), services call Firestore sources (`lib/data/remote/*`). Cubits never touch Firestore directly.
- **Services are thin orchestration layers** — they delegate to sources and add only business-rule checks (existence guards). No Firestore logic in services.
- **auto_route** — all navigation uses `context.router.push/replace/popAndPush`.
- **Every page implements `AutoRouteWrapper`** with `wrappedRoute` creating its `BlocProvider`.
- **`@RoutePage()` annotation required** on every page widget.
- **ThemeHelper / LocaleHelper usage scope**: do NOT inject into every page. Most pages read through inherited context (`Theme.of(context)`, `AppLocalizations.of(context)`). Use helpers directly only in Settings page and root app wiring.
- **Widgets must be as stateless as possible.** If a widget only renders state and has no local UI state, it must be a `StatelessWidget`. Use `StatefulWidget` only when local UI state is truly required (e.g. `TextEditingController`, animations, focus nodes).

---

## 10. Cubit Rules

- Every cubit: `@injectable`, extends `BaseCubit`.
- **Before creating a new cubit**, check whether an existing cubit already manages that domain. Reuse the existing cubit if it covers the same data/feature — do not duplicate cubit responsibilities.
- **`BaseCubit` default state is `const InitialState()`**, not a parameterized substate.
- **Mutation methods** (Firestore writes, auth actions) **must use `guardedAction()`** from `BaseCubit`.
  - `guardedAction()` checks `state is PendingState` → returns immediately if true (no-op), otherwise emits `PendingState` and runs the callback.
  - This guarantees that rapid duplicate taps, UI lag, or overlapping requests cannot produce duplicate Firestore documents or conflicting backend calls.
  - The callback handles its own try/catch and emits the final state (success or error).
- **Load / stream / subscription methods do NOT use `guardedAction()`** — they manage their own subscriptions.
- **`StatsCubit` exception:** uses its own token-based guard system with `_activeYearToken` and `StatsLoadStatus` checks. Do not refactor to `guardedAction()`.
- **`SomethingWentWrongState` is the uniform catch-all** — all `catch (_)` blocks emit it. Specific typed exceptions are mapped to specific states before the catch-all.
- **Never use `late` or `late final` in app code.** Prefer eagerly initialized `final` fields, nullable fields with explicit guards, or cubit-emitted state values read in `BlocBuilder`.
- **`@factory` (not `@singleton`)** — each page gets its own fresh cubit instance.

---

## 11. State Management Rules

- **Bloc/Cubit is the single source of truth** for application state.
- **Correct pattern:** `Cubit → BlocBuilder → UI`.
- **Incorrect pattern:** `Cubit → BlocConsumer listener → ValueNotifier → UI`.

### When to use `setState`

`setState` is acceptable **only** for trivial, self-contained visual state that:

- Has **no data / backend involvement** — purely cosmetic.
- Lives and dies inside a single widget — nothing else needs to know about it.
- Does not result from a user action that triggers a side effect (API call, Firestore write, navigation).

**Acceptable examples:** toggling an expand/collapse arrow, running a local animation, showing/hiding a tooltip.

### When NOT to use `setState`

If any of these are true, the state **must** go through a cubit (emit state → `BlocBuilder`/`BlocConsumer`):

- The action calls a service or writes to Firestore.
- The action changes data that another widget, page, or test might need.
- The user taps a button that has a meaningful outcome (submit, delete, toggle attendance, log supplement, etc.).
- You need loading / success / error feedback in the UI.
- The state should survive widget rebuilds or be testable.

**Rule of thumb:** if you hesitate, use a cubit. It's always safer and more testable.

### ValueNotifier scope

- **Do NOT use `ValueNotifier` for backend/domain data** — no `List<SupplementLog>`, no user data, no health logs in ValueNotifier.
- **ValueNotifier IS OK for local ephemeral UI state only**: selected tab index, search query, form drafts, dropdown selections — things that exist only inside a widget, don't come from backend, don't persist.

### Other state rules

- **Never use `setState` to store cubit state** (errors, loading, success). Derive directly in `builder:` from the current bloc state.
- **Use `buildWhen`** to restrict rebuilds to states that affect UI.
- **Use `listenWhen` + `listener`** only for side effects (navigation, snackbars) not reflected in the widget tree.
- **For local live-feedback widgets** (password strength, match indicator): use `ListenableBuilder` or `ValueListenableBuilder` on `TextEditingController` — not `setState`.
- **For page initialization data** (app version, profile bootstrap): create an `init()` method in the cubit, call from `initState()`, emit a dedicated state, read in `BlocBuilder`.
- **No `copyWith` on `BaseState` subclasses** — always replace entirely. Exception: `StatsLoadedState` uses `copyWith` for its multi-tab independent loading pattern.

---

## 12. Design & Theming Rules

- **No hardcoded colors** — always use `Theme.of(context).colorScheme.*`.
- **No hardcoded text styles** — always use `Theme.of(context).textTheme.*`, with `.copyWith()` only for single-property overrides.
- **No hex `Color(0xFF…)` values inside widgets.**
- **`AppColors` is only used inside `CustomTheme`** — never reference `AppColors.*` directly in widget `build()` methods.
- **M3 color scheme mappings:**
  - `colorScheme.primary` → accent / brand
  - `colorScheme.error` → danger / destructive
  - `colorScheme.onSurface` → primary text
  - `colorScheme.onSurfaceVariant` → secondary / helper text
  - `colorScheme.outline` → muted text, borders, disabled icons
  - `colorScheme.surface` → card / panel backgrounds
  - `scaffoldBackgroundColor` → page background

---

## 13. Firestore Rules

- **Paths are sacred** — never flatten nested collections:
  - Attendance: `users/{uid}/attendances/{YYYY-MM}/days/{YYYY-MM-DD}`
  - Health logs: `users/{uid}/healthLogs/{YYYY-MM}/entries/{logId}`
- **`yearMonth` format = `"YYYY-MM"`** (zero-padded month). **`date` format = `"YYYY-MM-DD"`**.
- **yearMonth derivation:** services always derive from the date string via `date.substring(0, 7)`. Callers never pass yearMonth separately.
- **No SQLite / Drift** — Firestore + SharedPreferences + FlutterSecureStorage only.

---

## 14. Localization Rules

- **All user-visible strings must use `AppLocalizations`** — ARB files at `lib/assets/localization/`.
- Supported languages: English (`en`), Romanian (`ro`).
- **Every widget and page** must use `AppLocalizations.of(context)` for all displayed text — no hardcoded English strings in `build()` methods. This includes labels, headers, placeholders, button text, and preview/mock data labels.
- **All emoji references must use `Emojis.*` constants** from `lib/presentation/resources/emojis.dart` — never use raw Unicode escapes (`\u{...}`) or literal emoji characters in widget code.

---

## 15. Code Quality Rules

- **`dart analyze lib/` must produce zero warnings** before submitting.
- Use `const` constructors wherever possible.
- Prefer `final` fields in widgets.
- **One public widget per file**, named after the file.
- Keep `build()` methods under **~80 lines** — extract sub-widgets or helper methods when longer.
- **Mobile-only** — project was created with `--platforms=android,ios`. Do not add web support.

### Dart / Flutter Parameter Convention

- Prefer **named parameters** (`{}`) for functions and methods.
- Use `required` for all mandatory inputs.
- Use nullable types (`Type?`) only for truly optional values.

**Recommended pattern:**

```dart
Future<void> initializeProfileOnFirstLogin({
  required String userId,
  required String email,
  String? displayName,
})
```

---

## 16. Reusable Controls Rules

- If a widget is likely reused across the app, place it in `lib/presentation/controls/` as a public widget (one per file).
- **Always add a matching widget test** under `test/presentation/controls/`.
- Prefer extraction into `controls/` over duplicating similar widgets across pages.
- Expose the **inner view widget as a public class** (e.g. `RegisterView`) so tests can inject a mock cubit via `BlocProvider.value` without `getIt`.

---

## 17. Testing Rules

- **Unit tests required** for all cubit state transitions.
- **Widget test required** for every file in `lib/presentation/controls/`.
- Widget tests for pages go under `test/presentation/pages/<feature>/`.
- **Test files mirror the `lib/` structure** under `test/`.
- **Never break existing tests** — `flutter test` must stay green.
- **Use `mocktail`** for mocking — no code generation needed.
- **For page tests**: `BlocProvider<MyCubit>.value(value: mockCubit, child: const MyView())`.
- **Minimum widget test coverage**: renders content, loading/spinner state, disabled/null-tap state, reactive updates if using `ListenableBuilder`.
- **No `bloc_test`** — incompatible with `auto_route_generator ^9.x`. Use plain `mocktail` + `flutter_test` with `expectLater(sut.stream, emitsInOrder([...]))`.
- **Run only relevant tests per task** — when working on a feature, run only the tests for that feature slice (e.g. `flutter test test/cubit/calendar/ test/presentation/pages/calendar/`). Do **not** run the full test suite unless explicitly asked.

---

## 18. DTOs & Serialization Rules

- DTOs use `@JsonSerializable()` + `json_annotation`.
- **ID fields excluded from JSON**: `@JsonKey(includeFromJson: false, includeToJson: false)` for IDs from Firestore doc ID (not stored as field).
- **`explicitToJson: true`** when DTO has nested lists (e.g. `SupplementProductDto`).
- **Timestamp fields typed as `Object` or `Object?`** — allows unit tests to pass plain `String`; production uses actual `Timestamp`.

---

## 19. Sources & Mappers Rules

- **Every source:** `@injectable`, `const` constructor, receives mapper via injection, accesses `FirebaseFirestore.instance` directly (not injected).
- **Every mapper:** `@injectable`, no state, pure mapping functions. Handles `Timestamp.toDate()` and `Timestamp.fromDate()`.
- All sources use `.withConverter<Dto>()` on collection references. The `id` field is populated from `snap.id` inside the `fromFirestore` closure.

---

## 20. Existence Guard Pattern

Used in `WorkoutService.update` and `HealthService.updateProduct`:

```dart
final existing = await _source.getById(userId, model.id);
if (existing == null) throw const TrainingTypeNotFoundException();
return _source.update(userId, model);
```

---

## 21. Page UI Workflow

When building or updating a page's UI, **always** follow this sequence:

1. **Read the prep doc** → `docs/screens/<page_name>.md` (widget tree, token mappings, interaction notes).
2. **Implement** using the prep doc as the single source of truth for layout, spacing, colours, and interactions.
3. **Do NOT copy from external projects.** Follow only the architecture, patterns, and conventions defined in this file.

---

Every AI session must start with these files loaded, regardless of feature:

- `.github/copilot-instructions.md` — architecture map, design tokens, controls inventory, rules
- `lib/presentation/resources/app_colors.dart` + `lib/assets/theme/custom_theme.dart` — design tokens
- `lib/model/` — all shared domain models
- `lib/cubit/base_cubit.dart` + `lib/cubit/base_state.dart` — base classes
- The relevant `docs/screens/<page>.md` prep doc
- The relevant reusable controls from `lib/presentation/controls/`

### Feature-slice approach (default)

For any task, load **only** the relevant vertical slice on top of the foundations:

| Feature          | Slice to load                                                        | ~Tokens |
| ---------------- | -------------------------------------------------------------------- | ------- |
| Auth             | auth pages + auth cubit/states + auth service                        | ~25k    |
| Calendar         | calendar page + calendar cubit + attendance service/data + mappers   | ~50k    |
| Stats            | stats page + stats cubit + relevant services                         | ~40k    |
| Health           | health page + health cubit + health service/data + supplement models | ~35k    |
| Workout Types    | workout_types page + workout cubit + workout service/data            | ~20k    |
| Profile/Settings | profile + settings pages + settings cubit                            | ~15k    |

This approach works within any 200k context window, leaving room for conversation and output.

### Full-project load (complex cross-cutting tasks only)

The entire Flutter project (lib + test + docs + config, no generated files) fits in ~186k tokens. Loading everything is acceptable **only** for:

- Cross-cutting refactors that touch 3+ features
- Architecture changes (DI, routing, base classes)
- Full audit / review tasks

### Never load

- Generated files (`.g.dart`, `.gr.dart`, `.config.dart`, generated localizations, `firebase_options.dart`) — ~29k tokens of noise
- Binary assets (fonts, images)

---

## 23. Git Conventions

- Default branch: `main`.
- Feature branches: `feature/<phase>-<description>`.
- Commit message style: `feat: <description>` / `chore: <description>` / `fix: <description>`.

At every prompt, if there is something needed to be updated in copilot-instructions.md tell me to update it and wait for my confirmation before proceeding. Always ask if you are unsure about any aspect of the instructions or the project structure.
