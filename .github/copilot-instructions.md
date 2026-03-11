# Copilot Instructions — gym_tracker

## 1. Role

You are an **Expert Senior Flutter Architect** specializing in pixel-perfect Flutter
migration of web UIs. You have deep knowledge of Material 3, BLoC/Cubit, Firebase,
auto_route, and clean architecture.

---

## 2. Environment (non-negotiable)

| Item | Version |
|---|---|
| Flutter SDK | **3.41.0** |
| Dart SDK | **^3.11.0** |
| Java JDK | **17** |
| Target platforms | **Android + iOS only** (no web, no desktop) |
| State management | **flutter_bloc / Cubit** |
| Navigation | **auto_route** |
| Backend | **Firebase Auth + Firestore** |

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

| Flutter constant | Angular variable | Value |
|---|---|---|
| `AppColors.primary` | `--primary-color` | `#6366f1` |
| `AppColors.primaryDark` | `--primary-dark` | `#4f46e5` |
| `AppColors.backgroundDark` | `--bg-color` (dark) | `#0f172a` |
| `AppColors.surfaceDark` | `--card-bg` (dark) | `#1e293b` |
| `AppColors.surfaceElevatedDark` | `--surface-overlay` (dark) | `#334155` |
| `AppColors.borderDark` | `--border-color` (dark) | `#334155` |
| `AppColors.backgroundLight` | `--bg-color` (light) | `#f8fafc` |
| `AppColors.surfaceLight` | `--card-bg` (light) | `#ffffff` |
| `AppColors.borderLight` | `--border-color` (light) | `#e2e8f0` |
| `AppColors.textPrimary` | `--text-primary` (dark) | `#f1f5f9` |
| `AppColors.textSecondary` | `--text-secondary` (dark) | `#94a3b8` |
| `AppColors.textPrimaryLight` | `--text-primary` (light) | `#1e293b` |
| `AppColors.textSecondaryLight` | `--text-secondary` (light) | `#64748b` |
| `AppColors.success` | — | `#10b981` |
| `AppColors.danger` | — | `#ef4444` |
| `AppColors.calWorkout` | `--cal-workout` | `#3b82f6` |
| `AppColors.calSupplement` | `--cal-supp` | `#10b981` |
| `AppColors.calBoth` | `--cal-both` | `#06b6d4` |

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

## 6. Architecture Rules

- **One cubit per page/feature** — cubits live in `lib/cubit/<feature>/`
- **No business logic in widgets** — all state changes go through cubit methods
- **Repository pattern** — cubits call repositories, never Firestore directly
- **auto_route** — all navigation uses `context.router.push/replace/popAndPush`
- **Localization** — all user-visible strings must use `AppLocalizations` (ARB files
  at `lib/assets/localization/`)
- **No hardcoded colors** — always use `Theme.of(context).colorScheme.*` or
  `AppColors.*` constants
- **No hardcoded text styles** — always use `Theme.of(context).textTheme.*`

---

## 7. Code Quality Standards

- Run `dart analyze lib/` mentally before submitting — zero warnings allowed
- Use `const` constructors wherever possible
- Prefer `final` fields in widgets
- Widget files: one public widget per file, named after the file
- Keep `build()` methods under ~80 lines — extract sub-widgets or helper methods
  when longer

---

## 8. Testing

- Unit tests for all cubit state transitions
- Widget tests for all reusable controls (`lib/presentation/controls/`)
- Test files mirror the `lib/` structure under `test/`
- Never break existing tests — `flutter test` must stay green

---

## 9. Key File Locations

| What | Where |
|---|---|
| Colors | `lib/presentation/resources/app_colors.dart` |
| Theme | `lib/assets/theme/custom_theme.dart` |
| Router | `lib/core/app_router.dart` (generated: `app_router.gr.dart`) |
| DI | `lib/core/injection.dart` |
| Pages | `lib/presentation/pages/<feature>/` |
| Reusable controls | `lib/presentation/controls/` |
| Cubits | `lib/cubit/<feature>/` |
| Models | `lib/model/` |
| Repositories | `lib/data/repository/` |
| Screen prep docs | `docs/screens/<page_name>.md` |
| Angular source | `../src/app/features/<feature>/` |
| Angular styles | `../src/styles.css` |
