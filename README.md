# Gym Tracker

A personal gym attendance and supplement tracking app for Android and iOS, built with Flutter and Firebase.

Track your workouts, log your supplements, monitor your streaks, and visualize your progress month-by-month and year-by-year.

---

## Table of Contents

- [Features](#features)
- [Screens](#screens)
- [Tech Stack](#tech-stack)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Testing](#testing)
- [Code Generation](#code-generation)
- [Localization](#localization)
- [Theming](#theming)
- [App Version Gate](#app-version-gate)
- [Firestore Data Model](#firestore-data-model)
- [Contributing](#contributing)
- [License](#license)

---

## Features

### Calendar — track every workout day

- **Monthly view** with a Mon-first 7-column grid and a **yearly view** with all 12 mini-months at once.
- Tap any day to open the day sheet with two tabs: **Workout** and **Health**.
- On the **Workout** tab you can:
  - Mark the day as attended (or unmark it).
  - Assign one of your custom **workout types** (optional).
  - Record the **duration in minutes** (optional).
  - Edit the type/duration on previously logged days.
- On the **Health** tab you can:
  - See all **supplement logs** for that specific day, paginated 2-per-page.
  - Add a new log by picking a product and the number of servings.
  - Remove individual log entries.
- Days are color-coded by what was logged: workout-only (blue), supplement-only (green), both (cyan), and the workout type's emoji icon is rendered inside the cell.
- The current day is always highlighted; navigation is by ← → arrows.

### Workout Types — your own taxonomy

- Create **fully custom workout types** with:
  - A name (e.g. _Push day_, _Climbing_, _Yoga_).
  - A color picked from 10 preset swatches.
  - An emoji icon picked from 20 presets (🏋️ 🏃 🚴 🧘 🥊 🏊 ⚽ 🎾 🏀 💪 …).
- Edit or delete any type from the management screen.
- Types appear in the calendar dropdown and drive the color-coding throughout the app.

### Supplements — personal + shared catalog

The Health page has **three tabs**:

- **Today** — every supplement you've logged today, grouped by product, with brand, servings count, and per-entry remove.
- **My Supplements** — products you have personally created. Search, edit, or delete them. Tap **+** to add a new one.
- **All Supplements** — the **global catalog** shared by all users (your own products + everyone else's). Verified products show a badge. Search by name/brand and quick-log to today.

When you create a supplement product you provide:

- Name, brand, default servings per day.
- An **ingredient list**, autocompleted from a shared `ingredients` collection (vitamins, minerals, etc. — each with a standardized id, amount, and unit).

Logging a supplement records it against the current day in your `healthLogs`, ready to be visualized in stats.

### Statistics — multi-tab yearly dashboard

The Stats page is a shell with a year selector (← year →) and **four tabs**:

- **Attendances** — total workouts in the year, current month count, monthly bar chart (12 bars), current and best **streaks**, and a days-of-the-week heatmap.
- **Workouts** — yearly **workout-type breakdown** (counts per type) plus a per-month breakdown for the selected month.
- **Duration** — total hours and average session duration for the year, monthly duration bar chart, and average duration per workout type.
- **Health** — total supplement servings for the year, the most-taken product, monthly supplement bar chart, and a **top nutrients** breakdown computed from the ingredient `stdId`s of every product you logged.

All tabs share unified loading skeletons and "no data" empty states.

### Profile

- Avatar with your initial, display name, email, and an **email-verified** badge.
- Quick links to **Settings** and **Workout Types**.
- **Logout** button.

### Settings

- **Appearance** — toggle between **dark and light** Material 3 themes.
- **Language** — switch between **English** and **Romanian** at runtime.
- **Legal** — quick links to the hosted **Terms of Service** and **Privacy Policy** (localized per-language, opened in the external browser).
- **Account** — open the dedicated **Change Password** screen (current password + new + confirm, with strength indicator and live match feedback).
- **Account deletion** — re-authenticates and performs a cascading cleanup of all your Firestore data before deleting your auth account.
- **App version** — shown live, read from the platform via `package_info_plus`.

### Authentication & onboarding

- Email + password sign-in / sign-up via **Firebase Auth**.
- Email verification, password reset, and resend-verification flows (with cooldown tracking).
- **Mandatory legal consent** on Register — user must tick an "I have read and agree to the [Terms of Service] and [Privacy Policy]" checkbox (links open the localized hosted page) before the account is created. Required by GDPR Art. 9(2)(a) since the app collects health-related data.
- First-launch **onboarding** walkthrough.

### App version gate (cold-launch)

- On every cold launch the splash screen reads `appConfig/version` from Firestore and routes the user through:
  - **Maintenance mode** (blocking screen with localized message and retry).
  - **Force update** (blocking screen that opens the platform store).
  - **No connection** (blocking screen with retry, when the config fetch fails).
- After reaching the main shell, a **soft "big update" bottom sheet** can prompt the user when `latestVersion` is a major or ≥2-minor jump, with a 3-day per-version snooze.

### Cross-cutting

- **Material 3** light + dark themes with shared design tokens.
- **Multi-language** (English, Romanian) with in-app switching.
- **Offline-aware** version gate and graceful no-connection handling.
- **Backed by Firebase** Auth + Firestore — your data syncs across your devices.

---

## Screens

Detailed UI specs for every screen live under [`docs/screens/`](docs/screens/):

- Splash, Onboarding, Login, Register, Forgot Password
- Main Shell (Calendar, Stats, Health, Profile tabs)
- Workout Types, Settings, Change Password
- Maintenance, Force Update, No Connection

---

## Tech Stack

| Area             | Choice                                          |
| ---------------- | ----------------------------------------------- |
| Framework        | Flutter **3.41.0** / Dart **^3.11.0**           |
| Platforms        | Android + iOS                                   |
| State management | `flutter_bloc` (Cubits)                         |
| Navigation       | `auto_route`                                    |
| Dependency inj.  | `get_it` + `injectable`                         |
| Backend          | Firebase Auth + Cloud Firestore                 |
| Local storage    | `shared_preferences` + `flutter_secure_storage` |
| Serialization    | `json_serializable` / `json_annotation`         |
| Localization     | `flutter_localizations` + ARB files             |
| Testing          | `flutter_test` + `mocktail`                     |
| Min Java (build) | JDK 17                                          |

See [`pubspec.yaml`](pubspec.yaml) for the full dependency list and pinned versions.

---

## Architecture

Strict layered architecture, enforced top-to-bottom:

```
Page / Widget  →  Cubit  →  Service  →  Source  →  Firestore
```

- **Pages** are mostly stateless and only render the current cubit state.
- **Cubits** (one per page/feature) hold all business state. All mutations go through `BaseCubit.guardedAction()` to prevent duplicate submissions.
- **Services** are thin orchestration layers with business-rule guards.
- **Sources** are the only layer that talks to Firestore (typed via `withConverter<Dto>()`).
- **Mappers** convert between DTOs (Firestore-shaped) and domain models.

Reusable widgets live in `lib/presentation/controls/` and are documented in [`.github/copilot-instructions.md`](.github/copilot-instructions.md).

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Generated by FlutterFire CLI
├── assets/
│   ├── fonts/                   # Raleway font family
│   ├── images/                  # Static images
│   ├── localization/            # ARB files (en, ro) + generated AppLocalizations
│   └── theme/                   # CustomTheme + ThemeHelper
├── core/
│   ├── app_router.dart          # auto_route configuration
│   ├── injection.dart           # get_it / injectable setup
│   └── app_version_status.dart  # Cached app-version gate result
├── cubit/                       # One folder per feature (auth, calendar, stats, ...)
│   ├── base_cubit.dart
│   └── base_state.dart
├── data/
│   ├── mappers/                 # DTO ↔ model
│   └── remote/                  # Firestore sources + DTOs
├── model/                       # Domain models (pure Dart)
├── presentation/
│   ├── controls/                # Reusable widgets
│   ├── helpers/                 # ThemeHelper, LocaleHelper, OnboardingHelper
│   ├── pages/                   # One folder per page
│   └── resources/               # AppColors, Emojis
└── service/                     # One folder per domain
test/                            # Mirrors lib/ structure
docs/screens/                    # Per-screen UI prep docs
android/  ios/                   # Platform projects
firestore.rules                  # Firestore security rules
```

---

## Getting Started

### Prerequisites

- **Flutter SDK** 3.41.0 (`flutter --version`)
- **Dart SDK** ^3.11.0 (bundled with Flutter)
- **JDK 17** (required by the Android Gradle plugin)
- **Android Studio** with Android SDK + emulator, OR a physical Android device
- **Xcode 15+** (macOS only, for iOS builds)
- A **Firebase project** with Authentication (Email/Password) and Cloud Firestore enabled

### Clone and install

```bash
git clone <repo-url>
cd gym-tracker
flutter pub get
```

---

## Configuration

### Firebase

This repo does **not** ship with usable Firebase credentials. To run the app you must wire it to your own Firebase project:

1. Install the FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
2. Create a Firebase project in the [Firebase console](https://console.firebase.google.com/).
3. Enable **Authentication → Email/Password** and **Cloud Firestore** (start in production mode).
4. From the project root run:
   ```bash
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and the platform config files (`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`).
5. Deploy the included Firestore security rules:
   ```bash
   firebase deploy --only firestore:rules
   ```

### Seed `appConfig/version`

The app's [version gate](#app-version-gate) reads a singleton document at `appConfig/version` on every cold launch. Create it manually in the Firebase console:

```jsonc
{
  "minRequiredVersion": "1.0.0",
  "latestVersion": "1.0.0",
  "maintenanceMode": false,
  "maintenanceMessages": {
    "en": "We'll be right back.",
    "ro": "Revenim imediat.",
  },
  "androidStoreUrl": "https://play.google.com/store/apps/details?id=...",
  "iosStoreUrl": "https://apps.apple.com/app/id...",
  "termsUrls": {
    "en": "https://<your-firebase-project>.web.app/terms-en.html",
    "ro": "https://<your-firebase-project>.web.app/terms-ro.html",
  },
  "privacyUrls": {
    "en": "https://<your-firebase-project>.web.app/privacy-en.html",
    "ro": "https://<your-firebase-project>.web.app/privacy-ro.html",
  },
  "termsVersion": "2026-04-18",
  "privacyVersion": "2026-04-18",
  "updatedAt": "<server timestamp>",
}
```

> `termsUrls` and `privacyUrls` are optional at runtime — the app falls back to hardcoded constants in `lib/core/constants/legal_urls.dart` when either is missing. `termsVersion` / `privacyVersion` are short revision ids (free-form strings) persisted alongside the user's consent record so you can tell _which_ legal text each user accepted. The static HTML pages themselves live under `legal/` and are deployed via Firebase Hosting (`firebase deploy --only hosting`).

---

## Running the App

```bash
# List available devices
flutter devices

# Run in debug
flutter run

# Run on a specific device
flutter run -d <device-id>

# Release build
flutter build apk --release       # Android APK
flutter build appbundle --release # Android Play Store bundle
flutter build ios --release       # iOS (requires macOS + Xcode)
```

A convenience clean rebuild script is provided:

```bash
./clean_rebuild.sh
```

---

## Testing

```bash
# Run the entire test suite
flutter test

# Run a single feature slice
flutter test test/cubit/calendar/ test/presentation/pages/calendar/

# With coverage
flutter test --coverage
```

Tests use `mocktail` for mocking — no code generation step needed for mocks. The `test/` tree mirrors `lib/`.

---

## Code Generation

This project uses build_runner for `injectable`, `auto_route`, and `json_serializable`:

```bash
# One-shot
dart run build_runner build --delete-conflicting-outputs

# Watch mode (during active development)
dart run build_runner watch --delete-conflicting-outputs
```

Re-run after:

- Adding/changing `@injectable` services or cubits
- Adding/changing `@RoutePage()` pages or modifying `app_router.dart`
- Adding/changing `@JsonSerializable()` DTOs

---

## Localization

ARB files live in [`lib/assets/localization/`](lib/assets/localization/). Supported locales: `en`, `ro`.

Regenerate the `AppLocalizations` Dart classes after editing ARB files:

```bash
flutter gen-l10n
```

All user-visible strings **must** go through `AppLocalizations.of(context)` — no hardcoded literals in widgets.

---

## Theming

- Material 3 light + dark themes defined in [`lib/assets/theme/custom_theme.dart`](lib/assets/theme/custom_theme.dart).
- Color tokens centralized in [`lib/presentation/resources/app_colors.dart`](lib/presentation/resources/app_colors.dart).
- Widgets read from `Theme.of(context).colorScheme.*` — never hardcoded colors.
- Theme preference is persisted per user via `ThemeHelper`.

---

## App Version Gate

On every cold launch, `SplashCubit` fetches `appConfig/version` and routes the user accordingly:

| Condition                      | Destination        | Behavior                                 |
| ------------------------------ | ------------------ | ---------------------------------------- |
| `maintenanceMode == true`      | `MaintenancePage`  | Blocking, with localized message + retry |
| `currentVersion < minRequired` | `ForceUpdatePage`  | Blocking, opens store URL                |
| Network/config fetch failed    | `NoConnectionPage` | Blocking, with retry                     |
| First launch                   | `OnboardingPage`   | One-time walkthrough                     |
| Signed in                      | `MainShellPage`    | Normal app entry                         |
| Signed out                     | `LoginPage`        | Normal auth entry                        |

After reaching `MainShellPage`, `CheckingUpdateCubit` may also surface a soft `BigUpdateBottomSheet` when `latestVersion` is a "big" jump (major bump, or minor diff ≥ 2). It respects a 3-day per-version snooze stored in `SharedPreferences`.

---

## Firestore Data Model

```
users/{userId}/
├── (profile fields)
├── trainingTypes/{typeId}
├── attendances/{YYYY-MM}/days/{YYYY-MM-DD}
└── healthLogs/{YYYY-MM}/entries/{logId}

supplementProducts/{productId}
ingredients/{stdId}
appConfig/version
```

Full field-level documentation lives in [`.github/copilot-instructions.md`](.github/copilot-instructions.md) under "Firestore Data Model". Security rules are in [`firestore.rules`](firestore.rules).

---

## Contributing

1. Branch from `main` using `feature/<short-description>`.
2. Follow the architecture and naming rules in [`.github/copilot-instructions.md`](.github/copilot-instructions.md) — they are the single source of truth.
3. Run `dart analyze lib/` (zero warnings) and `flutter test` before opening a PR.
4. Use Conventional Commits: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`, `test:`.
5. **Update this README** whenever you ship a notable feature, change a major flow, alter the tech stack, or modify setup/run/test instructions.

---

## License

Private project — all rights reserved unless stated otherwise.
