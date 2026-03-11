# gym_tracker — Complete Project Context

> **Purpose of this file:** A self-contained reference for any AI agent working on this project.
> Read this file *instead of* re-analyzing all three source projects from scratch.
> Last updated: Phase 0 (Project Initialization).

---

## 1. What This Project Is

**gym_tracker** is a Flutter mobile app (iOS + Android only) that is a pixel-perfect migration of an existing Angular web application called `gym-presence-tracker`.

- **Goal:** Replicate every feature and the exact UI design of the Angular app as a native mobile app.
- **Tech stack:** Flutter 3.41.0, Dart SDK ^3.11.0, Java JDK 17, Firebase (Auth + Firestore).
- **Platforms:** iOS + Android only. No web. Created with `--platforms=android,ios`.
- **Location:** `c:\cov\gym-tracker\gym_tracker`

---

## 2. Flutter Architecture Rules (from `flutter starting project` + `teamlyst`)

### 2.1 Project Folder Structure

```
lib/
  main.dart
  assets/
    localization/          ← ARB files + generated AppLocalizations
    theme/                 ← CustomTheme (light/dark)
  core/
    app_router.dart        ← @lazySingleton AppRouter extends RootStackRouter
    app_router.gr.dart     ← GENERATED — do not edit
    injection.dart         ← GetIt setup + configureDependencies()
    injection.config.dart  ← GENERATED — do not edit
  cubit/
    base_cubit.dart
    base_state.dart
    <feature>/
      <feature>_cubit.dart
      <feature>_states.dart
  data/
    constants/
    exceptions/
    mappers/
    preferences/
      preferences_source.dart
      preferences_keys.dart
    remote/
      <feature>/
        <feature>_dto.dart
        <feature>_source.dart
    secure_storage/
      secure_storage_source.dart
      secure_storage_keys.dart
  model/
    <model>.dart
    enum/
  presentation/
    pages/
      <feature>/
        <feature>_page.dart
    controls/              ← reusable widgets
    helpers/
    resources/
      app_colors.dart
      app_images.dart
  service/
    <feature>/
      <feature>_service.dart
      <feature>_service_exceptions.dart  ← part of service file
  utils/
```

### 2.2 Dependency Injection (`get_it` + `injectable`)

```dart
// lib/core/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() => $initGetIt(getIt);
```

- `configureDependencies()` is called first in `main()`, before `runApp()`.
- `await getIt.allReady()` is called after `configureDependencies()`.
- All services use `@injectable` or `@singleton`/`@lazySingleton`.
- `AppRouter` is `@lazySingleton`.
- `PreferencesSource` and `SecureStorageSource` use `@injectable`.

### 2.3 Routing (`auto_route`)

```dart
@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = <AutoRoute>[
    AutoRoute(path: '/splash', page: SplashRoute.page, initial: true, maintainState: false),
    // ... more routes
  ];
}
```

- ALL pages must be annotated with `@RoutePage()`.
- All non-nested routes use `maintainState: false` by default.
- Guards: inline (`DebugGuard()`) or injectable (`getIt<LoggedInGuard>()`).
- Generated file is `app_router.gr.dart` — never edit by hand.

### 2.4 Page Pattern (BlocProvider + AutoRouteWrapper)

```dart
@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<LoginCubit>(
      create: (context) => getIt<LoginCubit>(),
      child: this,
    );
  }
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, BaseState>(
      listener: (context, state) { /* handle navigation/dialogs */ },
      builder: (context, state) {
        return Scaffold( /* ... */ );
      },
    );
  }
}
```

### 2.5 State Management (`flutter_bloc`, `BaseCubit`)

**base_cubit.dart:**
```dart
class BaseCubit extends Cubit<BaseState> {
  BaseCubit() : super(const InitialState());

  void safeEmit(BaseState state) {
    if (!isClosed) emit(state);
  }
}
```

**base_state.dart:**
```dart
@immutable
class BaseState extends Equatable {
  const BaseState();
  @override
  List<Object?> get props => [];
}

class InitialState extends BaseState { const InitialState(); }
class PendingState extends BaseState { const PendingState(); }
class SomethingWentWrongState extends BaseState { const SomethingWentWrongState(); }
```

**Feature Cubit pattern:**
```dart
// login_cubit.dart
part 'login_states.dart';

@injectable
class LoginCubit extends BaseCubit {
  LoginCubit(this._accountService);
  final AccountService _accountService;

  Future<void> login({required String email, required String password}) async {
    safeEmit(const PendingState());
    try {
      await _accountService.login(email: email, password: password);
      safeEmit(const LoginSuccessfullyState());
    } on EmailNotVerifiedException {
      safeEmit(const AccountNotYetVerifiedState());
    } catch (e) {
      safeEmit(const SomethingWentWrongState());
    }
  }
}

// login_states.dart
part of 'login_cubit.dart';

class LoginSuccessfullyState extends BaseState {
  const LoginSuccessfullyState();
}
class AccountNotYetVerifiedState extends BaseState {
  const AccountNotYetVerifiedState();
}
```

**Rules:**
- Always `safeEmit(PendingState())` at the start of async operations.
- Use `try/catch` with typed custom exceptions.
- States are `@immutable`, `extends Equatable`, `const` constructors.
- State files use `part`/`part of` linked to their cubit file.
- No `copyWith`. Replace state entirely.

### 2.6 Models

```dart
class AttendanceRecord extends Equatable {
  const AttendanceRecord({
    required this.date,
    required this.timestamp,
    this.trainingTypeId,
    this.durationMinutes,
    this.notes,
  });

  final String date;         // YYYY-MM-DD
  final DateTime timestamp;
  final String? trainingTypeId;
  final int? durationMinutes;
  final String? notes;

  @override
  List<Object?> get props => [date, timestamp, trainingTypeId, durationMinutes, notes];
}
```

- All models: `extends Equatable`, `const` constructors, immutable fields.
- Override `props` for equality.
- No `copyWith`. Mutations create new instances.
- Enums in `model/enum/`.

### 2.7 Data Layer (Firestore only, NO SQLite/Drift)

**DTO pattern (json_annotation):**
```dart
@JsonSerializable()
class AttendanceRecordDto {
  AttendanceRecordDto({ required this.date, required this.timestamp, ... });

  factory AttendanceRecordDto.fromJson(Map<String, dynamic> json) => _$AttendanceRecordDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceRecordDtoToJson(this);

  @JsonKey(name: 'date', defaultValue: '')
  final String date;
  // ...
}
```

**Remote source pattern:**
```dart
@injectable
class AttendanceSource {
  const AttendanceSource(this._attendanceMapper);
  final AttendanceMapper _attendanceMapper;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // Strict path: users/{userId}/attendances/{yearMonth}/days/{date}
  CollectionReference<AttendanceRecordDto> _daysRef(String userId, String yearMonth) =>
      _db.collection('users').doc(userId)
         .collection('attendances').doc(yearMonth)
         .collection('days')
         .withConverter<AttendanceRecordDto>(
           fromFirestore: (snap, _) => AttendanceRecordDto.fromJson(snap.data()!),
           toFirestore: (dto, _) => dto.toJson(),
         );
}
```

**Mapper pattern:**
```dart
@injectable
class AttendanceMapper {
  AttendanceRecord mapDto(AttendanceRecordDto dto) => AttendanceRecord(
    date: dto.date,
    timestamp: dto.timestamp.toDate(),
    trainingTypeId: dto.trainingTypeId,
    durationMinutes: dto.durationMinutes,
    notes: dto.notes,
  );

  AttendanceRecordDto mapModel(AttendanceRecord model) => AttendanceRecordDto(
    date: model.date,
    timestamp: Timestamp.fromDate(model.timestamp),
    trainingTypeId: model.trainingTypeId,
    durationMinutes: model.durationMinutes,
    notes: model.notes,
  );
}
```

### 2.8 Service Pattern

```dart
// attendance_service.dart
part 'attendance_service_exceptions.dart';

@injectable
class AttendanceService {
  const AttendanceService(this._attendanceSource);
  final AttendanceSource _attendanceSource;

  Future<List<AttendanceRecord>> getMonthAttendance({
    required String userId,
    required int year,
    required int month,
  }) async {
    return _attendanceSource.getMonth(userId: userId, year: year, month: month);
  }
}

// attendance_service_exceptions.dart
part of 'attendance_service.dart';

class AttendanceNotFoundException implements Exception {}
```

### 2.9 Preferences & Secure Storage

```dart
// PreferencesSource (shared_preferences) — lightweight string/list storage
// Keys defined in preferences_keys.dart as static const String values

// SecureStorageSource (flutter_secure_storage) — sensitive data (userId, tokens)
// Keys defined in secure_storage_keys.dart
```

### 2.10 `main.dart` Pattern

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt.allReady();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),
      title: 'Gym Tracker',
      // localization + theme delegates
    );
  }
}
```

### 2.11 Localization

- ARB files in `lib/assets/localization/` (e.g., `app_en.arb`, `app_ro.arb`).
- Generated via `flutter gen-l10n`.
- `AppLocalizations.delegate` registered in `MaterialApp.router`.
- `Intl.defaultLocale` set in `localeResolutionCallback`.
- `localeResolutionCallback` uses `firstWhereOrNull` on languageCode.

---

## 3. Firestore Data Schema

### CRITICAL RULE: Never flatten or simplify paths. Preserve exactly as designed.

```
// ─── GLOBAL COLLECTIONS ───────────────────────────────────────────────────
ingredients/{ingredientId}
  Fields:
    id: String              // e.g. "vitamin_c"
    name: String            // e.g. "Vitamin C"
    aliases: List<String>?  // e.g. ["Ascorbic Acid"]
    category: String        // "Vitamin" | "Mineral" | "Performance" | "Amino Acid" | "Fatty Acid" | "Hormone" | "Herbal" | "Other"
    defaultUnit: String     // "mg" | "mcg" | "IU" | "g" | "servings" | "CFU"
    safeUpperLimit: number?
    rda: number?

supplementProducts/{productId}
  Fields:
    id: String
    name: String
    brand: String
    ingredients: List<{stdId: String, name: String, amount: number, unit: String}>
    servingsPerDayDefault: number
    createdBy: String?      // userId who created it
    verified: boolean?

// ─── USER ROOT ────────────────────────────────────────────────────────────
users/{userId}
  Fields:
    email: String
    displayName: String?
    createdAt: Timestamp
    lastLoginAt: Timestamp?
    preferences: {
      defaultTrainingType: String?
    }?
    stats: {
      totalAttendances: number  // denormalized counter, incremented atomically
    }?

// ─── USER SUBCOLLECTIONS ──────────────────────────────────────────────────
users/{userId}/trainingTypes/{typeId}
  Fields:
    name: String                // e.g. "Chest Day"
    color: String               // hex e.g. "#FF5733"
    icon: String?               // emoji e.g. "💪"
    createdAt: Timestamp

users/{userId}/attendances/{yearMonth}/days/{date}
  ⚠️  yearMonth = "YYYY-MM"  (e.g. "2025-03")
  ⚠️  date     = "YYYY-MM-DD" (e.g. "2025-03-15")
  Fields:
    date: String                // "YYYY-MM-DD"
    timestamp: Timestamp
    trainingTypeId: String?     // null if no type selected
    durationMinutes: number?    // null if not tracked
    notes: String?

users/{userId}/healthLogs/{yearMonth}/entries/{logId}
  ⚠️  yearMonth = "YYYY-MM"
  ⚠️  logId    = auto-generated random ID
  Fields:
    date: String                // "YYYY-MM-DD"
    productId: String           // references supplementProducts/{productId}
    productName: String?        // snapshot of name at time of logging
    productBrand: String?       // snapshot of brand at time of logging
    servingsTaken: number
    timestamp: Timestamp?
```

---

## 4. App Features (Full List)

### 4.1 Navigation Structure

The app uses a bottom navigation bar with 5 main tabs:

| Tab | Route | Icon |
|-----|-------|------|
| Calendar | `/calendar` | 📅 |
| Stats | `/stats` | 📊 |
| Health | `/health` | 💊 |
| Profile | `/profile` | 👤 |

Plus additional screens accessible from tabs:
- `/workout-types` — accessible from Profile
- `/settings` — accessible from Profile
- `/stats/attendances`, `/stats/workouts`, `/stats/duration`, `/stats/health` — sub-tabs of Stats

Auth screens (public, no bottom nav):
- `/login`
- `/register`
- `/forgot-password`
- `/auth/action` — email verification + password reset handler (OOB codes)

---

### 4.2 Feature: Auth

**Pages:** Login, Register, ForgotPassword, AuthAction (handles email verification + password reset OOB codes)

**Auth flows:**
- Email + password signup → sends verification email → user must verify before using app
- Email + password login → check `emailVerified`, show error if not verified
- Forgot password → sends reset email
- AuthAction: handles Firebase action codes (`oobCode` param) for email verification and password reset

**AuthService operations:**
- `signUp(email, password)` → creates account + sends verification email
- `signIn(email, password)` → signs in, returns `AuthUser`
- `signOut()`
- `resetPassword(email)` → sends reset email
- `verifyEmail(oobCode)` → applies action code
- `confirmPasswordReset(oobCode, newPassword)`
- `changePassword(currentPassword, newPassword)` → reauthenticate + updatePassword
- `currentUser$` → stream of `AuthUser?`

**AuthUser model:**
```dart
class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;
}
```

---

### 4.3 Feature: Calendar

**Views:**
1. **Monthly view** — 7-column grid (Mon–Sun), current month days + padding days from prev/next month
2. **Yearly view** — 12 mini-month cards in a grid (2-column on mobile)

**Day cell indicators:**
- `.attended` — blue/accent background on attended days
- `.today` — special border/highlight for today
- `.other-month` — dimmed for days outside current month (monthly view only)
- `workout-icon` — emoji icon of the training type (if type has icon)
- `attendance-dot` — simple dot if attended but no icon
- `supplement-dot` — 💊 indicator if health log exists for that date

**Day popup (bottom sheet on tap):**
- Header: "Day Month Year" (e.g., "15 March 2025")
- Two tabs: "Workout" | "Health 💊"

**Workout tab:**
- If not attended: show "Mark as attended" button
- If attended: show "Went to gym ✓" + workout type (tappable to edit)
  - Edit mode: dropdown to select training type + duration field (minutes)
  - Save / Clear (remove attendance) buttons

**Health tab:**
- Lists supplement logs for that date, grouped by product
- "Add supplement" inline form: select product from dropdown + servings count

**Navigation:** previous/next month arrows in header, toggle Monthly/Yearly buttons

**Year display:** shows current year in header when in yearly mode

---

### 4.4 Feature: Stats

**Shell:** Year navigator (prev/next year arrows), 4 tab buttons (sub-navigation):

**Tab 1: Attendances**
- Summary cards row 1: This Month count, This Year count, All Time count
- Summary cards row 2: Current Weekly Streak 🔥, Best Streak 🏆, Favorite Day 📅
- Bar chart: Monthly breakdown (12 bars, one per month)
- Bar chart: Day-of-week breakdown (7 bars, Mon–Sun)

**Streak logic:**
- A "week streak" is consecutive calendar weeks (Mon–Sun) with at least 1 attendance
- `currentStreak` = number of consecutive weeks ending this week
- `bestStreak` = max streak ever
- Streak messages (localized): 0→"Start your journey!", 1→"First week down!", etc.

**Tab 2: Workouts**
- Summary cards: Total tracked workouts this year, most-used type
- List: workout types ranked by count (color-coded with icon)
- Bar chart: monthly breakdown by workout type (stacked or grouped)

**Tab 3: Duration**
- Summary cards: Avg this month (minutes), Avg this year (minutes), Untracked count
- Per-type avg duration list (sorted by avg desc)
- Bar chart: Monthly avg duration (12 bars)

**Tab 4: Health** (supplement stats)
- Summary: total supplement logs this month, this year
- Per-product log counts for the selected year

---

### 4.5 Feature: Workout Types

**Screen:** List of user's custom training types
- Each card: emoji icon + colored background, type name, color dot, delete (🗑️) button

**Create/Edit modal (bottom sheet):**
- Name text field (max 30 chars)
- Icon picker: grid of ~30 emojis (🏋️ 🤸 🚴 🏊 🥊 🧘 🏃 ⚽ 🎾 🏀 🏐 🤼 🤺 🎿 ⛷️ 🏂 🤾 🏇 🧗 🛹 🚣 🎱 🏌️ 🏒 🎳 🏹 ⚔️ 🥋 🤸‍♂️ 🏋️‍♀️)
- Color picker: grid of ~20 hex colors
- Save / Cancel buttons

**Delete:** confirmation dialog before deleting

---

### 4.6 Feature: Health / Supplements

**Views:**
1. **Today** (default) — logs for today, grouped by product
2. **My Supplements** — products created by me (searchable)
3. **All Supplements** — all products in global catalog (searchable)

**Today view:**
- Group logs by productId, show productName + brand, total servings taken
- "Add" button opens inline form (product dropdown + servings)
- Tap each log group to remove/adjust

**My/All Supplements view:**
- Search bar (filters by name or brand)
- Each card: product name, brand, ingredient list preview
- Edit button (opens product form) — only owner can edit
- "Log Today" button (opens servings dialog)

**Create/Edit Product form:**
- Name + Brand text fields
- Ingredient picker: search from global `ingredients` catalog, add amount + unit
- Servings per day default
- Save / Delete (edit only)

---

### 4.7 Feature: Profile

**Screen layout:**
- User avatar (initial letter in circle)
- Display name + email
- Email verified badge (✓ Verified)
- Menu section "Manage": → Workout Types, → Settings
- Menu section "Account": → Sign Out button

---

### 4.8 Feature: Settings

**Sections:**
1. **About:** App version, "Built with Flutter + Firebase"
2. **Security:** Change Password inline form (current pw → new pw → confirm)
3. **General:**
   - Theme toggle (dark/light, sliding toggle)
   - Language picker (English / Romanian)
4. **Data Migration:** "Run Migration" button (adds `durationMinutes` field to existing records)

---

## 5. Localization

**Supported languages:** English (`en`), Romanian (`ro`)

**Key namespaces (from Angular i18n):**
- `SETTINGS.*` — settings page
- `STATS.*` — all stats
- `CALENDAR.*` — calendar page
- `MONTHS.*` — JANUARY…DECEMBER
- `WEEKDAYS.*` — MON…SUN
- `WEEKDAYS_MINI.*` — M…S (single/double letter)
- `PROFILE.*` — profile page
- `WORKOUT_TYPES.*` — workout types CRUD
- `HEALTH.*` — health/supplement page
- `AUTH.*` — login/register/forgot
- `NAV.*` — bottom nav labels
- `ERRORS.*` — error messages

These will be translated into ARB files (`app_en.arb`, `app_ro.arb`).

---

## 6. UI/Theme Design

### Colors (dark mode default - matching Angular app)

```
Primary accent:     #6C63FF  (purple-blue)
Background:         #0F0F0F  (near-black)
Surface/Card:       #1A1A1A
Surface elevated:   #252525
Border:             #333333
Text primary:       #FFFFFF
Text secondary:     #888888
Text muted:         #555555
Attended/success:   #6C63FF  (same as accent)
Danger/delete:      #FF4444
Warning:            #FF9800
```

### Typography
- Uses system fonts / inter-style sans-serif
- Title: 20px bold
- Body: 14px regular
- Caption: 12px

### Layout patterns
- Bottom navigation bar (5 items, but current app has 4 main tabs)
- Cards with rounded corners (8–12px radius)
- Full-width content with horizontal padding (16px)
- Day cells: square grid, 42 cells (6×7)
- Mini-month mini-day cells: ~32px×32px

---

## 7. Shell Scripts

### `clean_rebuild.sh`
```sh
flutter clean
rm ios/Podfile.lock pubspec.lock
rm -rf ios/Pods ios/Runner.xcworkspace
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```
Use when: switching branches, after adding new injectable/json-serializable/auto_route annotations.

### `generate_assets.sh`
```sh
# Runs spider (asset code generator) + gen-l10n + build_runner incrementally
spider build
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```
Use when: adding new assets, updating ARB files, or regenerating DI/routing code without full clean.

---

## 8. Key Packages to Add (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2

  # Firebase
  firebase_core: ^3.x
  firebase_auth: ^5.x
  cloud_firestore: ^5.x

  # State management
  flutter_bloc: ^9.x
  equatable: ^2.x

  # DI
  get_it: ^8.x
  injectable: ^2.x

  # Routing
  auto_route: ^9.x

  # Storage
  shared_preferences: ^2.x
  flutter_secure_storage: ^9.x

  # Utils
  collection: ^1.x

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.x
  injectable_generator: ^2.x
  auto_route_generator: ^9.x
  json_serializable: ^6.x
  json_annotation: ^4.x
```

---

## 9. Git Workflow

- Default branch: `master`
- Feature branches named `feature/<phase>-<description>`
- One branch per Phase or major feature
- Commit message style: `feat: <description>` / `chore: <description>`

---

## 10. Important Rules (ALWAYS Follow)

1. **Firestore paths are sacred.** Never flatten `users/{uid}/attendances/{yearMonth}/days/{date}`. Never flatten `users/{uid}/healthLogs/{yearMonth}/entries/{logId}`. Keep exactly as designed.
2. **No SQLite/Drift.** gym_tracker uses Firestore + SharedPreferences + FlutterSecureStorage only.
3. **No dev environment.** Only `prod` Firestore config. No environment switching logic.
4. **No copyWith on states/models.** Always replace entirely.
5. **Always `safeEmit(PendingState())` before async ops in cubits.**
6. **BaseCubit default state is `const InitialState()`**, not a parameterized substate.
7. **Every page implements `AutoRouteWrapper`** with `wrappedRoute` creating its `BlocProvider`.
8. **`@RoutePage()` annotation required** on every page widget.
9. **DTOs use `@JsonSerializable()` + `json_annotation`**, with `@JsonKey(name: '...', defaultValue: ...)`.
10. **All model IDs excluded from `toJson()**: `@JsonKey(includeFromJson: false, includeToJson: false)` for IDs that come from Firestore doc ID (not stored in fields).
11. **Mobile-only:** The project was created with `--platforms=android,ios`. Do not add web support.
12. **`yearMonth` key format = "YYYY-MM"** (zero-padded month). `date` format = "YYYY-MM-DD".


# gym_tracker — Project Context after Phase 1

> **Purpose:** Drop-in context for any AI agent picking up this project.
> Read `project_context.md` for the full feature spec and architecture rules.
> This file records what **already exists**, what still needs to be built, and
> every decision / gotcha discovered during Phase 1.
> Last updated: Phase 1 complete (2 commits on `master`).

---

## 0. Quick-start for a new agent

1. Read `project_context.md` first — it contains the full feature spec, Firestore
   schema, UI design, and architecture rules.
2. Read this file to know what is already done and what the next phases are.
3. Project is at `c:\cov\gym-tracker\gym_tracker`.
4. Run `dart analyze lib/` — should report **No issues found** before you start.
5. Run `flutter test` — should report **42 passed, 0 failed** before you start.

---

## 1. Environment

| Item | Version |
|---|---|
| Flutter | 3.41.0 |
| Dart SDK | ^3.11.0 |
| Java | JDK 17 |
| OS | Windows (PowerShell terminal) |
| Platforms | `android`, `ios` only (`--platforms=android,ios`) |
| Firebase | Auth + Firestore (prod only, no dev env) |

---

## 2. Exact `pubspec.yaml` (as of Phase 1)

```yaml
name: gym_tracker
description: "Gym Tracker - A personal gym attendance and supplement tracking app."
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.11.0

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Firebase
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.2
  cloud_firestore: ^5.6.5

  # State management
  flutter_bloc: ^9.1.0
  equatable: ^2.0.7

  # Dependency injection
  get_it: ^8.0.3
  injectable: ^2.5.0

  # Routing
  auto_route: ^9.3.0

  # Storage
  shared_preferences: ^2.5.3
  flutter_secure_storage: ^9.2.4

  # Serialization (runtime)
  json_annotation: ^4.9.0

  # Utils
  collection: ^1.19.1
  intl: ^0.20.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0

  # Code generation
  build_runner: ^2.4.15
  injectable_generator: ^2.7.0
  auto_route_generator: ^9.0.0
  json_serializable: ^6.9.5

  # Testing
  mocktail: ^1.0.4

flutter:
  uses-material-design: true
  generate: true           # enables flutter gen-l10n
  assets:
    - lib/assets/localization/
```

### ⚠️ Known dependency constraint: `bloc_test` is intentionally absent

`bloc_test ^9.x` / `^10.x` is **incompatible** with `auto_route_generator ^9.x`
because of conflicting `analyzer` version ranges. Do **not** add `bloc_test`
without first upgrading to `auto_route ^10.x + auto_route_generator ^10.x`.
Use `mocktail` alone for unit tests until that upgrade happens.

---

## 3. File tree — what EXISTS right now

```
lib/
  main.dart                                    ✅ boilerplate
  assets/
    localization/
      app_en.arb                               ✅ placeholder
      app_ro.arb                               ✅ placeholder
      app_localizations.dart                   ✅ GENERATED (flutter gen-l10n)
      app_localizations_en.dart                ✅ GENERATED
      app_localizations_ro.dart                ✅ GENERATED
  core/
    app_router.dart                            ✅ shell (SplashRoute only)
    app_router.gr.dart                         ✅ GENERATED (auto_route)
    injection.dart                             ✅ boilerplate
    injection.config.dart                      ✅ GENERATED (injectable)
  cubit/
    base_cubit.dart                            ✅
    base_state.dart                            ✅
  data/
    remote/
      attendance/
        attendance_day_dto.dart                ✅
        attendance_day_dto.g.dart              ✅ GENERATED
      supplement/
        product_ingredient_dto.dart            ✅
        product_ingredient_dto.g.dart          ✅ GENERATED
        supplement_log_dto.dart                ✅
        supplement_log_dto.g.dart              ✅ GENERATED
        supplement_product_dto.dart            ✅ (@JsonSerializable(explicitToJson: true))
        supplement_product_dto.g.dart          ✅ GENERATED
      training_type/
        training_type_dto.dart                 ✅
        training_type_dto.g.dart               ✅ GENERATED
  model/
    auth_user.dart                             ✅
    attendance_day.dart                        ✅
    supplement_log.dart                        ✅
    supplement_product.dart                    ✅  (also contains ProductIngredient)
    training_type.dart                         ✅
  presentation/
    pages/
      splash/
        splash_page.dart                       ✅ placeholder @RoutePage()

test/
  data/
    remote/
      attendance/
        attendance_day_dto_test.dart           ✅ 9 tests
      supplement/
        product_ingredient_dto_test.dart       ✅ 7 tests
        supplement_product_dto_test.dart       ✅ 13 tests
        supplement_log_dto_test.dart           ✅ 13 tests
      training_type/
        training_type_dto_test.dart            ✅ 9 tests
  widget_test.dart                             (default Flutter test — not modified)
```

**Files still to be created (none yet):**
- `lib/assets/theme/` — `CustomTheme` (light/dark not yet built)
- `lib/data/constants/`, `lib/data/exceptions/`, `lib/data/mappers/` — empty
- `lib/data/preferences/`, `lib/data/secure_storage/` — empty
- `lib/data/remote/*/` — sources not yet written
- `lib/service/*/` — no services yet
- `lib/presentation/resources/` — `app_colors.dart`, `app_images.dart` not yet written
- No feature pages, cubits, or routes beyond `SplashPage`

---

## 4. Exact source for every boilerplate file

### `lib/main.dart`
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/core/app_router.dart';
import 'package:gym_tracker/core/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await getIt.allReady();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appRouter = getIt<AppRouter>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _appRouter.config(
        navigatorObservers: () => [AutoRouteObserver()],
      ),
      title: 'Gym Tracker',
    );
  }
}
```

> **TODO for Phase 2:** Add `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`
> AFTER `configureDependencies()` / `getIt.allReady()`. Also add `localizationsDelegates`
> and `supportedLocales` to `MaterialApp.router` and wire up the theme.

### `lib/core/injection.dart`
```dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
void configureDependencies() => $initGetIt(getIt);
```

### `lib/core/app_router.dart`
```dart
import 'package:auto_route/auto_route.dart';
import 'package:injectable/injectable.dart';
import 'app_router.gr.dart';

@lazySingleton
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  final List<AutoRoute> routes = <AutoRoute>[
    AutoRoute(
      path: '/splash',
      page: SplashRoute.page,
      initial: true,
      maintainState: false,
    ),
  ];
}
```

### `lib/cubit/base_cubit.dart`
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/cubit/base_state.dart';

class BaseCubit extends Cubit<BaseState> {
  BaseCubit() : super(const InitialState());

  void safeEmit(BaseState state) {
    if (!isClosed) emit(state);
  }
}
```

### `lib/cubit/base_state.dart`
```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BaseState extends Equatable {
  const BaseState();
  @override
  List<Object?> get props => [];
}

class InitialState extends BaseState { const InitialState(); }
class PendingState extends BaseState { const PendingState(); }
class SomethingWentWrongState extends BaseState { const SomethingWentWrongState(); }
```

### `lib/presentation/pages/splash/splash_page.dart`
```dart
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Gym Tracker')),
    );
  }
}
```

---

## 5. Domain models (exact fields)

All models: `extends Equatable`, `const` constructors, `@override props`.

### `AuthUser` (`lib/model/auth_user.dart`)
```dart
class AuthUser extends Equatable {
  final String uid;
  final String? email;
  final String? displayName;
  final bool emailVerified;
}
```

### `TrainingType` (`lib/model/training_type.dart`)
```dart
class TrainingType extends Equatable {
  final String id;
  final String name;
  final String color;    // hex, e.g. "#FF5733"
  final String? icon;   // emoji, e.g. "💪"
}
```

### `AttendanceDay` (`lib/model/attendance_day.dart`)
```dart
class AttendanceDay extends Equatable {
  final String date;              // "YYYY-MM-DD"
  final DateTime timestamp;
  final String? trainingTypeId;
  final int? durationMinutes;
  final String? notes;
}
```

### `ProductIngredient` + `SupplementProduct` (`lib/model/supplement_product.dart`)
```dart
class ProductIngredient extends Equatable {
  final String stdId;    // references global ingredients/{id}
  final String name;
  final double amount;
  final String unit;
}

class SupplementProduct extends Equatable {
  final String id;
  final String name;
  final String brand;
  final List<ProductIngredient> ingredients;
  final double servingsPerDayDefault;
  final String? createdBy;   // userId who created this, null = global
  final bool? verified;
}
```

### `SupplementLog` (`lib/model/supplement_log.dart`)
```dart
class SupplementLog extends Equatable {
  final String id;             // Firestore auto-gen doc id
  final String date;           // "YYYY-MM-DD"
  final String productId;      // references supplementProducts/{id}
  final String? productName;   // snapshot at log time
  final String? productBrand;  // snapshot at log time
  final double servingsTaken;
  final DateTime? timestamp;
}
```

---

## 6. DTOs — key design decisions

All DTOs: `@JsonSerializable()`, `factory fromJson`, `toJson`, `part '...g.dart'`.

### ID field pattern (ALL DTOs that have an id)
```dart
// The Firestore doc ID is NOT stored as a Firestore field.
// It is populated from doc.id after a read, never serialized.
@JsonKey(includeFromJson: false, includeToJson: false, defaultValue: '')
final String id;
```

### Timestamp fields
Fields that hold Firestore `Timestamp` objects are typed as **`Object`** (non-nullable)
or **`Object?`** (nullable) on the DTO. This allows:
- Unit tests to pass a plain `String` (no Firebase dep needed)
- Production code to pass an actual `cloud_firestore.Timestamp`

The mapper is responsible for calling `.toDate()` on the Timestamp when mapping
DTO → model.

### `SupplementProductDto` uses `explicitToJson: true`
```dart
@JsonSerializable(explicitToJson: true)  // ← required for nested List<ProductIngredientDto>
class SupplementProductDto { ... }
```
Without this, `toJson()` leaves `ProductIngredientDto` objects raw in the list —
Firestore would reject them. All other DTOs use plain `@JsonSerializable()`.

### DTO file locations
```
lib/data/remote/
  attendance/attendance_day_dto.dart
  supplement/product_ingredient_dto.dart
  supplement/supplement_log_dto.dart
  supplement/supplement_product_dto.dart
  training_type/training_type_dto.dart
```

---

## 7. Code generation

After any annotation change, run:
```powershell
cd "c:\cov\gym-tracker\gym_tracker"
dart run build_runner build --delete-conflicting-outputs
```

After any ARB file change, run:
```powershell
flutter gen-l10n
```

For a full clean rebuild (branch switch, etc.) use `clean_rebuild.sh` or manually:
```powershell
flutter clean
Remove-Item ios/Podfile.lock, pubspec.lock -ErrorAction SilentlyContinue
Remove-Item ios/Pods, ios/Runner.xcworkspace -Recurse -Force -ErrorAction SilentlyContinue
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
```

---

## 8. Test suite

```
test/data/remote/
  attendance/attendance_day_dto_test.dart       9 tests
  supplement/product_ingredient_dto_test.dart   7 tests
  supplement/supplement_product_dto_test.dart  13 tests
  supplement/supplement_log_dto_test.dart      13 tests
  training_type/training_type_dto_test.dart     9 tests
TOTAL: 42 tests, all passing
```

Run tests:
```powershell
cd "c:\cov\gym-tracker\gym_tracker"
flutter test
```

Each test file covers:
- `fromJson` — field mapping, snake_case keys, default values, `id` excluded
- `toJson`   — correct key names, `id` absent, nested objects serialized as Maps
- Round-trip — `fromJson → toJson` is lossless

---

## 9. What Phase 2 should build

The following are the suggested next phases. Adjust as needed.

### Phase 2 — Auth feature (end-to-end)

**Goal:** Login, Register, ForgotPassword pages wired to Firebase Auth. Splash page
navigates to Login if unauthenticated, or to the main shell if authenticated.

**Checklist:**
- [ ] Run `flutterfire configure` to generate `firebase_options.dart` and wire
      `Firebase.initializeApp` in `main.dart`
- [ ] `lib/data/remote/auth/auth_source.dart` — wraps `FirebaseAuth`
- [ ] `lib/service/auth/auth_service.dart` + `auth_service_exceptions.dart`
- [ ] `lib/cubit/auth/` — `AuthCubit` (listens to `currentUser$` stream),
      `auth_states.dart`
- [ ] `lib/cubit/login/login_cubit.dart` + `login_states.dart`
- [ ] `lib/cubit/register/register_cubit.dart` + `register_states.dart`
- [ ] `lib/cubit/forgot_password/forgot_password_cubit.dart` + states
- [ ] Pages: `LoginPage`, `RegisterPage`, `ForgotPasswordPage`, `AuthActionPage`
      — all `@RoutePage()`, all implement `AutoRouteWrapper`
- [ ] Update `AppRouter` with all auth routes + a guard redirecting to Login
      when not authenticated
- [ ] `SplashPage` becomes a real splash: initialize Firebase, check auth state,
      navigate accordingly
- [ ] Write cubit unit tests using `mocktail` (stub `AuthService`)

**Key custom exceptions (minimum set):**
```dart
// auth_service_exceptions.dart (part of auth_service.dart)
class InvalidCredentialsException implements Exception {}
class EmailAlreadyInUseException implements Exception {}
class EmailNotVerifiedException implements Exception {}
class WeakPasswordException implements Exception {}
```

### Phase 3 — Main shell + bottom navigation

**Goal:** Authenticated users land on a bottom-nav shell with 4 tabs:
Calendar, Stats, Health, Profile.

### Phase 4 — Calendar feature

### Phase 5 — Stats feature

### Phase 6 — Health / Supplements feature

### Phase 7 — Profile + Settings + Workout Types

---

## 10. Architecture rules (critical summary — full list in `project_context.md`)

1. **Every page**: `@RoutePage()` + implements `AutoRouteWrapper` (creates its own `BlocProvider` via `wrappedRoute`)
2. **Every cubit**: `@injectable`, extends `BaseCubit`, always calls `safeEmit(PendingState())` before async ops
3. **Every service**: `@injectable`, `part` + `part of` for its exceptions file
4. **Every source**: `@injectable`, uses `FirebaseFirestore.instance` directly (not injected)
5. **Every mapper**: `@injectable`, maps DTO↔Model, handles `Timestamp.toDate()` and `Timestamp.fromDate()`
6. **No copyWith** anywhere on states or models
7. **Firestore paths are sacred** — never flatten:
   - Attendance: `users/{uid}/attendances/{YYYY-MM}/days/{YYYY-MM-DD}`
   - Health logs: `users/{uid}/healthLogs/{YYYY-MM}/entries/{logId}`
8. **`yearMonth` format = `"YYYY-MM"`**, `date` format = `"YYYY-MM-DD"`
9. **No SQLite / Drift** — only Firestore + SharedPreferences + FlutterSecureStorage
10. **No dev/staging environment** — one Firebase config, prod only

---

## 11. Git history

```
543b12f  feat: Phase 1 – boilerplate, domain models, DTOs, and serialisation tests
d65ab62  chore: initial Flutter project setup (iOS + Android), copy scripts, add project_context.md
```

Branch: `master`

---

## 12. Phase 2  Data Layer (COMPLETE)

### Commit: `2f76c6a feat: Phase 2 - data layer services, mappers, sources, and service tests`

---

### 12.1 New file tree (Phase 2 additions)

```
lib/
  data/
    mappers/
      attendance_day_mapper.dart         AttendanceDayMapper
      supplement_mapper.dart             SupplementMapper  (products + logs)
      training_type_mapper.dart          TrainingTypeMapper
    remote/
      attendance/
        attendance_day_source.dart       AttendanceDaySource  (Firestore)
      supplement/
        health_source.dart               HealthSource  (products + log entries)
      training_type/
        training_type_source.dart        TrainingTypeSource  (Firestore)
  service/
    auth/
      auth_service.dart                  AuthService
      auth_service_exceptions.dart       (part of auth_service.dart)
    attendance/
      attendance_service.dart            AttendanceService
      attendance_service_exceptions.dart 
    health/
      health_service.dart                HealthService
      health_service_exceptions.dart   
    workout/
      workout_service.dart               WorkoutService
      workout_service_exceptions.dart  

test/
  service/
    auth/
      auth_service_test.dart             26 tests
    attendance/
      attendance_service_test.dart       9 tests
    health/
      health_service_test.dart           17 tests
    workout/
      workout_service_test.dart          10 tests
```

---

### 12.2 Service method signatures

#### `AuthService` (`lib/service/auth/auth_service.dart`)

Wraps `FirebaseAuth` (injected via constructor). Annotated `@injectable`.

```dart
Stream<AuthUser?> get currentUser$
Future<AuthUser> signUp({required String email, required String password})
Future<AuthUser> signIn({required String email, required String password})
Future<void> signOut()
Future<void> resetPassword(String email)
Future<void> verifyEmail(String oobCode)
Future<void> confirmPasswordReset({required String oobCode, required String newPassword})
Future<void> changePassword({required String currentPassword, required String newPassword})
```

**Exceptions** (all `implements Exception`, `const` constructors):
- `InvalidCredentialsException`  wrong email/password
- `EmailNotVerifiedException`  sign-in before verification
- `EmailAlreadyInUseException`  sign-up with taken email
- `WeakPasswordException`  password too short
- `InvalidActionCodeException`  expired/invalid OOB code
- `AuthUserNotFoundException`  no current user or disabled account

**Key behaviour:** `signIn` calls `_auth.signOut()` and throws `EmailNotVerifiedException` when `user.emailVerified == false`. `changePassword` re-authenticates before updating.

---

#### `WorkoutService` (`lib/service/workout/workout_service.dart`)

Wraps `TrainingTypeSource`. Annotated `@injectable`.

```dart
Stream<List<TrainingType>> watchAll(String userId)
Future<TrainingType?> getById(String userId, String typeId)
Future<String> create(String userId, TrainingType model)   // returns new doc id
Future<void> update(String userId, TrainingType model)     // throws TrainingTypeNotFoundException if not found
Future<void> delete(String userId, String typeId)
```

**Exceptions:** `TrainingTypeNotFoundException`

---

#### `AttendanceService` (`lib/service/attendance/attendance_service.dart`)

Wraps `AttendanceDaySource`. Annotated `@injectable`.

```dart
static String yearMonthKey(int year, int month)  // "2025-03"
Stream<List<AttendanceDay>> watchMonth({required String userId, required int year, required int month})
Future<AttendanceDay?> getDay({required String userId, required String date})   // date = "YYYY-MM-DD"
Future<void> upsertDay({required String userId, required AttendanceDay model})
Future<void> deleteDay({required String userId, required String date})
```

**Exceptions:** `AttendanceDayNotFoundException` (defined but not yet thrown  reserved for future use)

**Key behaviour:** yearMonth is always derived from the date string via `date.substring(0, 7)`  never passed in separately from the caller.

---

#### `HealthService` (`lib/service/health/health_service.dart`)

Wraps `HealthSource`. Annotated `@injectable`.

```dart
static String yearMonthKey(int year, int month)   // "2025-04"
// Products
Stream<List<SupplementProduct>> watchAllProducts()
Stream<List<SupplementProduct>> watchMyProducts(String userId)
Future<SupplementProduct?> getProduct(String productId)
Future<String> createProduct(SupplementProduct model)   // returns new doc id
Future<void> updateProduct(SupplementProduct model)     // throws SupplementProductNotFoundException if not found
Future<void> deleteProduct(String productId)
// Log entries
Stream<List<SupplementLog>> watchMonthEntries({required String userId, required int year, required int month})
Stream<List<SupplementLog>> watchDayEntries({required String userId, required String date})
Future<String> logSupplement({required String userId, required SupplementLog model})   // returns new entry id
Future<void> deleteEntry({required String userId, required String date, required String entryId})
```

**Exceptions:** `SupplementProductNotFoundException`

---

### 12.3 Mappers

All mappers: `@injectable`, no state, pure mapping functions.

| Mapper | mapDto() in | mapModel() out |
|--------|------------|----------------|
| `TrainingTypeMapper` | `TrainingTypeDto`  `TrainingType` | `TrainingType`  `TrainingTypeDto` (accepts optional `Timestamp? createdAt`) |
| `AttendanceDayMapper` | `AttendanceDayDto`  `AttendanceDay` (calls `.toDate()` on Timestamp) | `AttendanceDay`  `AttendanceDayDto` (calls `Timestamp.fromDate()`) |
| `SupplementMapper` | `mapProductDto`, `mapLogDto` | `mapProductModel`, `mapLogModel` (handles nested `ProductIngredient``ProductIngredientDto`) |

---

### 12.4 Sources (Firestore access layer)

All sources: `@injectable`, `const` constructor, receive mapper via injection, access `FirebaseFirestore.instance` directly (not injected  matches teamlyst pattern).

All sources use `.withConverter<Dto>()` on collection references. The `id` field is populated from `snap.id` inside the `fromFirestore` closure (since DTOs exclude it from JSON).

| Source | Collection path | Operations |
|--------|----------------|------------|
| `TrainingTypeSource` | `users/{uid}/trainingTypes` | `watchAll`, `getById`, `create`, `update`, `delete` |
| `AttendanceDaySource` | `users/{uid}/attendances/{YYYY-MM}/days` | `watchMonth`, `getDay`, `upsertDay`, `deleteDay` |
| `HealthSource` | `supplementProducts` + `users/{uid}/healthLogs/{YYYY-MM}/entries` | full product CRUD + log `watchMonthEntries`, `watchDayEntries`, `createEntry`, `deleteEntry` |

---

### 12.5 Design decisions and gotchas

1. **Services are thin orchestration layers**  they delegate to sources and add only business-rule checks (existence guards). Do NOT add Firestore logic to services.

2. **Existence guard pattern:**
   ```dart
   final existing = await _source.getById(userId, model.id);
   if (existing == null) throw const TrainingTypeNotFoundException();
   return _source.update(userId, model);
   ```
   Used in `WorkoutService.update` and `HealthService.updateProduct`.

3. **yearMonth derivation**  Services always derive `yearMonth` from a date string:
   ```dart
   final yearMonth = model.date.substring(0, 7); // "YYYY-MM-DD"  "YYYY-MM"
   ```
   Callers never need to compute or pass `yearMonth` separately.

4. **`signIn` signs out unverified users**  After Firebase returns a `UserCredential` for a valid but unverified account, `AuthService.signIn` immediately calls `_auth.signOut()` before throwing `EmailNotVerifiedException`. This prevents an unverified user from having an active Firebase session.

5. **`FirebaseAuth` is injected**  Unlike Firestore (accessed via `.instance`), `FirebaseAuth` is passed to `AuthService` as a constructor parameter. This is what makes unit testing possible without `firebase_auth_mocks`.

6. **`mocktail` `registerFallbackValue` requirement**  When `any()` is used on a parameter whose type is a custom class, mocktail requires a fallback to be registered in `setUpAll`. Required fakes:
   ```dart
   class _FakeAuthCredential extends Fake implements AuthCredential {}
   class _FakeTrainingType extends Fake implements TrainingType {}
   class _FakeSupplementProduct extends Fake implements SupplementProduct {}
   class _FakeSupplementLog extends Fake implements SupplementLog {}
   ```

7. **`widget_test.dart` removed**  The default Flutter counter test was deleted because it tries to pump `MyApp` without a DI environment.

---

### 12.6 Test suite totals after Phase 2

```
test/data/remote/               42 tests  (Phase 1 DTO tests  unchanged)
test/service/auth/              26 tests
test/service/workout/           10 tests
test/service/attendance/         9 tests
test/service/health/            17 tests

TOTAL                           94 tests, all passing
```

Run:
```powershell
cd "c:\cov\gym-tracker\gym_tracker"
flutter test
```

---

### 12.7 What Phase 3 should build

**Phase 3  Firebase setup + Auth cubits + Auth pages**

Goals:
1. Run `flutterfire configure`  generates `lib/firebase_options.dart`
2. Update `main.dart` to call `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` after `getIt.allReady()`
3. Register `FirebaseAuth` in the DI container so `AuthService` receives it
4. Build `AuthCubit` (watches `AuthService.currentUser$`, emits auth state changes  drives splash navigation)
5. Build `LoginCubit` + `login_states.dart`
6. Build `RegisterCubit` + `register_states.dart`
7. Build `ForgotPasswordCubit` + states
8. Build pages: `LoginPage`, `RegisterPage`, `ForgotPasswordPage`, `AuthActionPage`
9. Update `AppRouter` with all auth routes + `AuthGuard`
10. Implement real `SplashPage` (waits for auth state, navigates to Login or main shell)
11. Write cubit unit tests using `mocktail` (stub `AuthService`)

**DI registration for FirebaseAuth** (to be added to a `@module` class):
```dart
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
}
```

---

## 13. Git history

```
2f76c6a  feat: Phase 2 - data layer services, mappers, sources, and service tests
543b12f  feat: Phase 1 - boilerplate, domain models, DTOs, and serialisation tests
d65ab62  chore: initial Flutter project setup (iOS + Android), copy scripts, add project_context.md
```

Branch: `master`

---

## 14. Phase 3  State Management (Cubits) (COMPLETE)

### Commit: `f6fb258 feat: Phase 3 - state management cubits and cubit tests`

---

### 14.1 New file tree (Phase 3 additions)

```
lib/
  model/
    attendance_stats.dart        AttendanceStats (Equatable data class)

  cubit/
    auth/
      auth_cubit.dart            AuthCubit  (@injectable)
      auth_states.dart           13 states  (part of auth_cubit.dart)
    workout/
      workout_cubit.dart         WorkoutCubit  (@injectable)
      workout_states.dart        3 states  (part of workout_cubit.dart)
    calendar/
      calendar_cubit.dart        CalendarCubit  (@injectable)
      calendar_states.dart       3 states  (part of calendar_cubit.dart)
    stats/
      stats_cubit.dart           StatsCubit  (@injectable) + private aggregation
      stats_states.dart          1 state  (part of stats_cubit.dart)
    health/
      health_cubit.dart          HealthCubit  (@injectable)
      health_states.dart         4 states  (part of health_cubit.dart)

test/
  cubit/
    auth/
      auth_cubit_test.dart       18 tests
    workout/
      workout_cubit_test.dart    7 tests
    calendar/
      calendar_cubit_test.dart   7 tests
    stats/
      stats_cubit_test.dart      10 tests
    health/
      health_cubit_test.dart     10 tests
```

---

### 14.2 Cubit & state reference

#### `AuthCubit`

```dart
void watchAuthState()
Future<void> signIn({required String email, required String password})
Future<void> signUp({required String email, required String password})
Future<void> signOut()
Future<void> resetPassword(String email)
Future<void> changePassword({required String currentPassword, required String newPassword})
Future<void> verifyEmail(String oobCode)
Future<void> confirmPasswordReset({required String oobCode, required String newPassword})
```

States (all `extends BaseState`, `const` constructors):

| State | Trigger |
|---|---|
| `AuthAuthenticatedState(user)` | `watchAuthState`  Firebase user present |
| `AuthUnauthenticatedState` | `watchAuthState`  no user / sign-out |
| `AuthSignInSuccessState(user)` | `signIn` succeeded |
| `AuthSignUpSuccessState` | `signUp` succeeded (email verification pending) |
| `AuthSignOutSuccessState` | `signOut` succeeded |
| `AuthEmailNotVerifiedState` | `signIn`  email not yet verified |
| `AuthEmailAlreadyInUseState` | `signUp`  email taken |
| `AuthWeakPasswordState` | `signUp`  password too weak |
| `AuthInvalidCredentialsState` | `signIn`/`changePassword`  wrong credentials |
| `AuthPasswordResetSentState` | `resetPassword` email sent |
| `AuthPasswordChangedState` | `changePassword` succeeded |
| `AuthEmailVerifiedState` | `verifyEmail` succeeded |
| `AuthInvalidActionCodeState` | `verifyEmail`/`confirmPasswordReset`  expired code |
| `AuthPasswordResetConfirmedState` | `confirmPasswordReset` succeeded |

---

#### `WorkoutCubit`

```dart
void loadTypes(String userId)             // subscribes to watchAll stream
Future<void> createType(String userId, TrainingType type)
Future<void> deleteType(String userId, String typeId)
```

States: `WorkoutTypesLoadedState(types)`, `WorkoutTypeCreatedState(id)`, `WorkoutTypeDeletedState`

---

#### `CalendarCubit`

```dart
void loadMonth({required String userId, required int year, required int month})
Future<void> markDay({required String userId, required AttendanceDay day})
Future<void> clearDay({required String userId, required String date})
```

States: `CalendarMonthLoadedState(days, year, month)`, `CalendarDayMarkedState(day)`, `CalendarDayClearedState(date)`

**Key behaviour:** calling `loadMonth` a second time cancels the previous subscription before creating the new one  safe for month-paging.

---

#### `StatsCubit`

```dart
Future<void> load({required String userId, required int year})
```

State: `StatsLoadedState(stats: AttendanceStats, year: int, types: List<TrainingType>)`

**Data loading strategy:** fetches all 12 months of `year` plus the previous December (for cross-year streak accuracy) in parallel via `Future.wait`, then aggregates entirely in-memory. No persistent subscription  call `load()` again to refresh.

**`AttendanceStats` model fields:**

| Field | Type | Description |
|---|---|---|
| `totalCount` / `yearlyCount` | `int` | Attendance count for the year |
| `monthlyCount` | `int` | Count for the current calendar month (or December for past years) |
| `currentWeekStreak` | `int` | Consecutive ISO weeks ending at current/previous week |
| `bestWeekStreak` | `int` | Longest consecutive ISO-week run |
| `favoriteDaysOfWeek` | `List<int>` | `DateTime.weekday` values (1=Mon7=Sun) with max attendance |
| `typeDistribution` | `Map<String, int>` | trainingTypeId  attendance count |
| `monthlyDurationAverages` | `Map<int, double>` | month (112)  avg duration minutes |
| `perTypeDurationAverages` | `Map<String, double>` | trainingTypeId  avg duration minutes |

---

#### `HealthCubit`

```dart
void loadDayEntries({required String userId, required String date})
void loadProducts(String userId)
Future<void> logSupplement({required String userId, required SupplementLog model})
Future<void> deleteEntry({required String userId, required String date, required String entryId})
```

States: `HealthDayEntriesLoadedState(entries, date)`, `HealthProductsLoadedState(products)`, `HealthEntryLoggedState(id)`, `HealthEntryDeletedState`

**Key behaviour:** two independent `StreamSubscription`s  one for day entries, one for products. Both are cancelled in `close()`.

---

### 14.3 How to test cubits without `bloc_test`

`bloc_test` is incompatible with `auto_route_generator ^9.x` due to conflicting `analyzer` version ranges, so all cubit tests use plain `mocktail` and `flutter_test`.

**Pattern:**
```dart
// 1. Subscribe BEFORE triggering the method  cubit.stream is a broadcast stream
//    and PendingState is emitted synchronously, so the listener must be in place first.
final future = expectLater(
  sut.stream,
  emitsInOrder([const PendingState(), isA<SomeSuccessState>()]),
);

// 2. Trigger the method (sync void or async).
await sut.someMethod(...);

// 3. Await the expectation; test fails if states never arrive.
await future;
```

For stream-based (void) methods like `loadTypes` and `loadMonth`, `Stream.value(x)` delivers its event on the next microtask. If you need to collect states into a list instead (e.g. for multi-assertion tests), use:
```dart
final emitted = <BaseState>[];
sut.stream.listen(emitted.add);
await sut.load(...);
await Future<void>.delayed(Duration.zero);  // flush microtask queue
expect(emitted.whereType<StatsLoadedState>().first.stats.yearlyCount, 3);
```

**Run all cubit tests:**
```powershell
cd "c:\cov\gym-tracker\gym_tracker"
flutter test test/cubit/
```

---

### 14.4 Design decisions & gotchas

1. **Stream subscriptions and `close()`**  Every cubit that holds a `StreamSubscription` overrides `close()` to cancel it. Pattern:
   ```dart
   @override
   Future<void> close() async {
     await _subscription?.cancel();
     return super.close();
   }
   ```

2. **`loadMonth` replaces the subscription**  Before setting up the new subscription, `_monthSubscription?.cancel()` is called. This prevents stale events from a previous month leaking into the new state.

3. **StatsCubit uses `.first` on streams**  `AttendanceService.watchMonth(...).first` converts the live stream into a one-shot Future. This avoids needing separate `getMonth` methods on the service layer.

4. **ISO-week streak uses T12:00:00 noon time**  When computing ISO weeks and doing `DateTime.subtract(Duration(days: N))`, the calculation is done at noon local time to avoid any DST-boundary edge cases where subtracting a whole day might land on the wrong calendar date.

5. **`monthlyCount` is deterministic for past years**  When `year < DateTime.now().year`, the "current month" defaults to 12 (December) so that `monthlyCount` is stable and does not depend on when the test runs. This makes stats tests for a fixed past year fully deterministic.

6. **`SomethingWentWrongState` is the uniform catch-all**  All `catch (_)` blocks per the pattern emit `SomethingWentWrongState`. Specific typed exceptions are mapped to specific states (`AuthInvalidCredentialsState`, etc.) before the catch-all.

7. **`@injectable` on all cubits**  `get_it`/`injectable` manages lifetime. Cubits are registered as transient (new instance per resolution) via the default `@injectable`  NOT `@singleton` or `@lazySingleton`, since each screen creates its own cubit instance.

---

### 14.5 Test suite totals after Phase 3

```
test/data/remote/               42 tests  (Phase 1 DTO tests)
test/service/auth/              26 tests  (Phase 2)
test/service/workout/           10 tests  (Phase 2)
test/service/attendance/         9 tests  (Phase 2)
test/service/health/            17 tests  (Phase 2)
test/cubit/auth/                18 tests  (Phase 3)
test/cubit/workout/              7 tests  (Phase 3)
test/cubit/calendar/             7 tests  (Phase 3)
test/cubit/stats/               10 tests  (Phase 3)
test/cubit/health/              10 tests  (Phase 3) -- note: test harness deduplication

TOTAL                          151 tests, all passing
```

Run:
```powershell
cd "c:\cov\gym-tracker\gym_tracker"
flutter test
```

---

### 14.6 What Phase 3.5 should check next

**Phase 3.5  Firebase + DI wiring + Splash + App Router scaffold**

1. **Run `flutterfire configure`** to generate `lib/firebase_options.dart`
2. **Add `FirebaseModule`** (a `@module` class) so `get_it` can resolve `FirebaseAuth.instance`:
   ```dart
   @module
   abstract class FirebaseModule {
     @lazySingleton
     FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
   }
   ```
3. **Re-run `build_runner`** after adding the module:  
   `dart run build_runner build --delete-conflicting-outputs`
4. **Update `main.dart`**  call `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` and `configureDependencies()` before `runApp`
5. **Implement real `SplashPage`**  use `AuthCubit.watchAuthState()`, navigate to Login or Home based on the emitted state
6. **Add all `@RoutePage()` stubs** for Login, Register, ForgotPassword so `AppRouter` generates stubs and `dart analyze` stays clean
7. **Verify `dart analyze lib/` and `flutter test` are still clean** after wiring

---

## 15. Git history

```
f6fb258  feat: Phase 3 - state management cubits and cubit tests
2f76c6a  feat: Phase 2 - data layer services, mappers, sources, and service tests
543b12f  feat: Phase 1 - boilerplate, domain models, DTOs, and serialisation tests
d65ab62  chore: initial Flutter project setup (iOS + Android), copy scripts, add project_context.md
```

Branch: `master`
