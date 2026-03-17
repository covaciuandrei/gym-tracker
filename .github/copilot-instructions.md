# Copilot Instructions — gym_tracker

> **Rules:** All coding rules and conventions are in `.github/rules.md`.
> This file contains the AI role, reference data, and the Angular architecture map.

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

`gym_tracker` is a **pixel-perfect Flutter migration** of the Angular web app
`gym-presence-tracker` located at `../src/` (relative to this Flutter project).

- Replicate every feature AND the exact visual design of the Angular app.
- The Angular project is the single source of truth for UI layout, colors, and
  interactions.

---

## 4. Mandatory Workflow — Building a Page UI

Whenever you are asked to build or update a page's UI, you **must** follow this
two-source approach before writing any code:

### Step 1 — Read the prep doc

Open `docs/screens/<page_name>.md` (e.g. `docs/screens/login_page.md`).
This file contains:

- Exact widget tree layout (Flutter pseudo-code)
- Color-scheme and text-theme token mappings
- Interaction notes and edge cases

### Step 2 — Cross-reference the Angular source

Open the corresponding Angular feature folder listed in the prep doc's
`## Angular Source` section (e.g. `../src/app/features/auth/login/`).
Read the `.html` and `.css` files to verify:

- Exact spacing values (padding, gaps, margins)
- Border radii, border widths, colors used
- Any details not yet captured in the prep doc

### Step 3 — Make both sources agree before coding

If the prep doc and Angular source conflict, the **Angular source wins**. Note the
discrepancy in your reasoning but do not update the `.md` file unless asked.

---

## 5. Design Token Reference

All design tokens are centralized — never hardcode colors or radius values:

| Flutter constant                | Angular variable           | Value     |
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

**Primary button gradient** (Angular `.btn-primary`):

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

## 6. Controls Inventory

| File                               | What it is                                                                                                                                                                                                                                              |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `gradient_button.dart`             | Full-width indigo-gradient button (Angular `.btn-primary`); shows spinner when `isLoading: true`. **Use for every primary submit action.**                                                                                                              |
| `primary_button.dart`              | Material `ElevatedButton` wrapper; use only for secondary/outline actions that don't need gradient.                                                                                                                                                     |
| `primary_fab.dart`                 | Standard reusable FloatingActionButton wrapper for add/create actions across tabs/pages.                                                                                                                                                                |
| `custom_text_field.dart`           | Styled `TextFormField`; handles password-visibility toggle internally. Use for all form inputs.                                                                                                                                                         |
| `search_input.dart`                | Reusable search field with search icon and clear action; use for searchable list/catalog pages.                                                                                                                                                         |
| `error_banner.dart`                | Inline red pill for form-level server errors. Use below form fields, above the submit button.                                                                                                                                                           |
| `error_state.dart`                 | Full-section error (emoji + title + retry). Use for page-level load failures.                                                                                                                                                                           |
| `empty_state.dart`                 | No-data placeholder (emoji + title + optional CTA). Use when a list/section has zero items.                                                                                                                                                             |
| `confirmation_dialog.dart`         | Generic yes/no destructive confirmation dialog with customizable labels and confirm color.                                                                                                                                                              |
| `action_bottom_sheet.dart`         | Reusable draggable modal-sheet scaffold (handle, title, body, footer). Use for create/edit forms and action sheets.                                                                                                                                     |
| `password_strength_indicator.dart` | Animated strength bar + 4 requirement bullets. Add below every new-password field. Uses `ListenableBuilder` — no setState.                                                                                                                              |
| `password_match_indicator.dart`    | Green/red match label below confirm-password field. Uses `ListenableBuilder.merge` — no setState.                                                                                                                                                       |
| `form_card.dart`                   | Styled card container for auth forms (shadow, rounded corners, `surfaceContainerHigh` bg). Takes `formKey` + `children`; wraps them in `AutofillGroup > Form > Column`. **Use as the base for every form panel instead of duplicating the decoration.** |
| `success_card.dart`                | Green-tinted confirmation card. Takes `title`, `message`, `buttonLabel`, `onAction`, optional `icon` (default `✅`). **Use after any successful async action (sign-up, password reset, etc.).**                                                         |
| `surface_section_card.dart`        | Generic elevated surface card for settings/section blocks with shared styling and rounded corners.                                                                                                                                                      |
| `main_list_item.dart`              | Reusable list item card (title + optional leading/trailing + tap) for simple entity rows.                                                                                                                                                               |
| `summary_action_card.dart`         | Reusable entity summary card (subtitle/title/description + optional action row + optional onTap). Use for catalog and summary lists.                                                                                                                    |
| `labeled_value_tile.dart`          | Reusable list tile for static key-value rows (for example app version/about rows).                                                                                                                                                                      |
| `option_toggle.dart`               | Generic segmented option toggle using chips/buttons for language/view-mode filters.                                                                                                                                                                     |
| `auth_footer_link.dart`            | Divider + centred "prompt + action-link" row. Used at the bottom of every auth screen to switch between pages. Takes `prompt`, `actionLabel`, `onTap`, optional `enabled` (pass `!isLoading` to disable during requests).                               |
| `emoji_text.dart`                  | Shared wrapper for rendering emoji symbols consistently across cards, labels, and icon-like UI elements.                                                                                                                                                |
| `gym_app_bar.dart`                 | Standard app bar wrapper used across feature pages for consistent title/back/action behavior.                                                                                                                                                           |
| `gym_tab_bar.dart`                 | Shared tab-strip control used by pages with segmented content (calendar, stats, health).                                                                                                                                                                |
| `set_password_card.dart`           | Reusable password form card (current/new/confirm variants) used in auth action and change-password flows.                                                                                                                                               |

---

## 7. Key File Locations

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
| Angular source           | `../src/app/features/<feature>/`                             |
| Angular styles           | `../src/styles.css`                                          |

---

## 8. Angular Codebase Architecture Map

> Full inventory of every Angular component, service, guard, and Firestore
> collection. Use this to ensure **zero features are missed** during migration.

### 8.1 Route Tree (Angular → Flutter mapping)

```
/                         → SplashPage (initial)
/login          [guest]   → LoginPage          (lib/presentation/pages/auth/login_page.dart)
/register       [guest]   → RegisterPage       (lib/presentation/pages/auth/register_page.dart)
/forgot-password[guest]   → ForgotPasswordPage (lib/presentation/pages/auth/forgot_password_page.dart)
/auth/action    [public]  → AuthActionPage     (lib/presentation/pages/auth/auth_action_page.dart)
/app                      → MainShellPage      (lib/presentation/pages/main_shell/main_shell_page.dart)
  /app/calendar           → CalendarPage       (tab child)
  /app/stats              → StatsPage          (tab child)
  /app/health             → HealthPage         (tab child)
  /app/profile            → ProfilePage        (tab child)
/workout-types  [auth]    → WorkoutTypesPage   (lib/presentation/pages/workout_types/workout_types_page.dart)
/settings       [auth]    → SettingsPage       (lib/presentation/pages/settings/settings_page.dart)
/change-password[auth]    → ChangePasswordPage (lib/presentation/pages/change_password/change_password_page.dart)
```

**Auth gating in current implementation:**

- No `auto_route` guard classes are registered.
- `SplashPage` redirects to `MainShellRoute` or `LoginRoute` based on `FirebaseAuth.currentUser`.
- Feature pages also self-check auth and redirect to `LoginRoute` when user is missing.

### 8.2 Feature Inventory

#### AUTH FEATURE — `src/app/features/auth/`

| Component                   | Actions / State                                                                                                                                                                                                                                                                                                                                                                                                       |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **LoginComponent**          | `email`, `password` fields; `isLoading`, `errorMessage`; `onSubmit()` → `authService.signIn()` → navigate `MainShell` (`/app/calendar` tab); link to `/register`, `/forgot-password`                                                                                                                                                                                                                                  |
| **RegisterComponent**       | `email`, `password`, `confirmPassword`; validates: email format, password ≥8 chars + uppercase + lowercase + number, passwords match; `onSubmit()` → `authService.signUp()` → shows "verify email" success state; link to `/login`                                                                                                                                                                                    |
| **ForgotPasswordComponent** | `email` field; `isLoading`, `errorMessage`, `successMessage`; `onSubmit()` → `authService.resetPassword(email)` → success message; email validation; link back to `/login`                                                                                                                                                                                                                                            |
| **AuthActionComponent**     | Reads `?mode=` & `?oobCode=` query params from Firebase email links. **Three modes:** `verifyEmail` → `authService.verifyEmail(oobCode)` → success state with "Sign In" button; `resetPassword` → verifies code first (shows email), then password form (new + confirm, strength meter, min 8 chars + uppercase + lowercase + digit, passwords match) → `authService.confirmPasswordReset()`; `unknown` → error state |

**AuthService methods used by auth pages:**
`signIn`, `signUp` (sends verification email), `signOut`, `resetPassword`,
`verifyEmail`, `verifyPasswordResetCode`, `confirmPasswordReset`,
`changePassword`

#### CALENDAR FEATURE — `src/app/features/calendar/`

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

#### STATS FEATURE — `src/app/features/workouts/stats/`

Stats is a **shell with 4 sub-tabs**. The year is shared via query param `?year=`.

| Tab             | Angular Component           | What it shows                                                                                                           |
| --------------- | --------------------------- | ----------------------------------------------------------------------------------------------------------------------- |
| **Attendances** | `AttendancesStatsComponent` | Total workouts (year), current month count, monthly bar chart (12 bars), streak (current + best), days-per-week heatmap |
| **Workouts**    | `WorkoutsStatsComponent`    | Workout type breakdown (year): pie/list of types × count; monthly breakdown: selected month type distribution           |
| **Duration**    | `DurationStatsComponent`    | Total hours (year), avg duration/session, monthly duration bar chart, per-type avg duration list                        |
| **Health**      | `HealthStatsComponent`      | Total supplement servings (year), most-taken product, monthly supplement bar chart, top nutrients breakdown             |

All stats tabs share:

- Year selector (← current year →) — changes `?year=` query param
- Loading skeleton cards
- "No data" empty state when no records

#### HEALTH FEATURE — `src/app/features/health/`

| Aspect                      | Detail                                                                                                                                                                                                       |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **View modes**              | 3 tabs: `today` (default), `my_supplements`, `all_supplements`                                                                                                                                               |
| **Today tab**               | Lists today's supplement logs grouped by product; shows product name + brand + servings taken; delete individual log                                                                                         |
| **My Supplements tab**      | Lists products created by current user; search bar; edit/delete each product; "Add product" FAB                                                                                                              |
| **All Supplements tab**     | Lists all products (global + user-created); search bar; verified badge on global products; add to today's log                                                                                                |
| **SupplementFormComponent** | Create/edit supplement product: `name`, `brand`, ingredient list (autocomplete from Firestore `ingredients` collection with stdId, amount, unit); save → `firebaseService.addProduct()` or `updateProduct()` |
| **Auto-seed**               | On first load, if `ingredients` collection is empty, seeds it from `core/constants/ingredients.ts`                                                                                                           |

#### WORKOUT TYPES FEATURE — `src/app/features/workouts/workout-types/`

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

#### PROFILE FEATURE — `src/app/features/user/profile/`

| Aspect         | Detail                                                          |
| -------------- | --------------------------------------------------------------- |
| **Avatar**     | Circle with user's initial (first char of displayName or email) |
| **Info shown** | displayName (or "User"), email, email-verified badge            |
| **Actions**    | Logout button → `authService.signOut()` → navigate `/login`     |
| **Links**      | → `/settings`, → `/workout-types`                               |

#### SETTINGS FEATURE — `src/app/features/user/settings/`

| Aspect                 | Detail                                                                                                                                           |
| ---------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Appearance section** | Dark/light theme toggle → `themeService.toggleTheme()`                                                                                           |
| **Language section**   | Language picker (EN / RO) → `languageService.setLanguage(lang)`                                                                                  |
| **Security section**   | "Change password" navigates to dedicated `ChangePasswordPage`; form uses reusable `SetPasswordCard`; submit calls `authService.changePassword()` |
| **App version**        | Loaded dynamically via `package_info_plus` in `SettingsCubit.init()`                                                                             |
| **Navigation**         | Back arrow → previous page                                                                                                                       |

### 8.3 Firestore Data Model

```
firestore/
├── users/{userId}/
│   ├── (doc fields)  totalWorkouts, currentYearWorkouts, currentMonthWorkouts
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
```

### 8.4 Angular Services → Flutter Service/Source Mapping

| Angular Service                             | Flutter equivalent                                                                                         |
| ------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| `AuthService`                               | `lib/service/auth/auth_service.dart` + `AuthCubit`                                                         |
| `FirebaseService` (attendance)              | `lib/service/attendance/attendance_service.dart` + `lib/data/remote/attendance/attendance_day_source.dart` |
| `FirebaseService` (training types)          | `lib/service/workout/workout_service.dart` + `lib/data/remote/training_type/training_type_source.dart`     |
| `FirebaseService` (supplements/health logs) | `lib/service/health/health_service.dart` + `lib/data/remote/supplement/health_source.dart`                 |
| `FirebaseService` (stats queries)           | `StatsCubit` composes attendance/workout/health services (no dedicated stats repository)                   |
| `ThemeService`                              | `lib/assets/theme/theme_helper.dart`                                                                       |
| `LanguageService`                           | `lib/presentation/helpers/locale_helper.dart`                                                              |

---

## 9. App Navigation Flowchart

```
App Start
    │
    ▼
SplashPage (2s delay)
    │
    ├─── FirebaseAuth.currentUser == null ──────────► LoginPage
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
    └─── FirebaseAuth.currentUser != null ─────────► MainShell (bottom nav)
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
    └── /auth/action?mode=verifyEmail&oobCode=...  ──────────────────────────────► AuthActionPage
            ├── mode=verifyEmail  → applyActionCode() → success → "Go to Sign In" → LoginPage
            ├── mode=resetPassword
            │       ├── verifyPasswordResetCode() → shows target email
            │       └── [submit new password] → confirmPasswordReset() → success → LoginPage
            └── mode=unknown / missing oobCode → ErrorStateWidget
```

### 9.1 Authentication State Machine

```
State: UNAUTHENTICATED
    ├── signIn(email, pwd)
    │       ├── OK + verified   → AUTHENTICATED
    │       └── OK + unverified → UNAUTHENTICATED (auto sign-out)
    ├── signUp(email, pwd) → sends verification email → UNAUTHENTICATED (must verify)
    └── verifyEmail(oobCode) → AWAITING_LOGIN  (user goes to LoginPage)

State: AUTHENTICATED
    └── signOut() → UNAUTHENTICATED
```

### 9.2 Calendar Day Cell State Machine

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

### 9.3 Stats Data Flow

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

### 9.4 Health Page View Modes

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
