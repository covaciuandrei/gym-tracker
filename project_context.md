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
