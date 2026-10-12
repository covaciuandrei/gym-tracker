# Rules

> **Single source of truth for all coding rules and conventions.**
> Every AI agent working on this project must follow these rules.
> Reference data (design tokens, file locations) lives in `copilot-instructions.md`.

---

## Environment

- Flutter **3.41.0**, Dart **^3.11.0**, Java JDK **17**.
- Target platforms: **Android + iOS only** — no web, no desktop.
- State management: **flutter_bloc / Cubit**.
- Navigation: **auto_route**.
- Backend: **Firebase Auth + Firestore**.
- Every dependency, API call, and code pattern must be compatible with these versions.
- No dev/staging environment — one Firebase config, prod only.

---

## Architecture

- **Layering:** `Page/Control → Cubit → Service → Source → Firestore`. Never skip a layer.
- **One cubit per page/feature** — cubits live in `lib/cubit/<feature>/`.
- **No business logic in widgets** — all state changes go through cubit methods.
- **Service + source pattern** — cubits call services (`lib/service/*`), services call Firestore sources (`lib/data/remote/*`). Cubits never touch Firestore directly.
- **Services are thin orchestration layers** — they delegate to sources and add only business-rule checks (existence guards). No Firestore logic in services.
- **Health Insights is the one data-layer exception.** Its data comes from Apple Health, not Firestore, so the chain is `Page → Cubit → HealthInsightsService → HealthRepository → HealthKitSource → Swift bridge` (`lib/data/health_insights/`, `ios/Runner/HealthKitBridge.swift`). `MetricTimelineCubit` and `PhysicalOverviewDetailCubit` read the `HealthRepository` directly because they only chart the already-cached snapshot; do not add further cubits that skip the service. All other rules for this feature are in **Apple Health (Health Insights)** below.
- **auto_route** — all navigation uses `context.router.push/replace/popAndPush`.
- **Every page implements `AutoRouteWrapper`** with `wrappedRoute` creating its `BlocProvider`.
- **`@RoutePage()` annotation required** on every page widget.
- **ThemeHelper / LocaleHelper usage scope**: do NOT inject into every page. Most pages read through inherited context (`Theme.of(context)`, `AppLocalizations.of(context)`). Use helpers directly only in Settings page and root app wiring.
- **Widgets must be as stateless as possible.** If a widget only renders state and has no local UI state, it must be a `StatelessWidget`. Use `StatefulWidget` only when local UI state is truly required (e.g. `TextEditingController`, animations, focus nodes).

---

## Cubit Rules

- Every cubit: `@injectable`, extends `BaseCubit`.
- **Before creating a new cubit**, check whether an existing cubit already manages that domain. Reuse the existing cubit if it covers the same data/feature — do not duplicate cubit responsibilities.
- **`BaseCubit` default state is `const InitialState()`**, not a parameterized substate.
- **Mutation methods** (Firestore writes, auth actions) **must use `guardedAction()`** from `BaseCubit`.
  - `guardedAction()` checks `state is PendingState` → returns immediately if true (no-op), otherwise emits `PendingState` and runs the callback.
  - This guarantees that rapid duplicate taps, UI lag, or overlapping requests cannot produce duplicate Firestore documents or conflicting backend calls.
  - The callback handles its own try/catch and emits the final state (success or error).
- **Load / stream / subscription methods do NOT use `guardedAction()`** — they manage their own subscriptions.
- **`StatsCubit` exception:** uses its own token-based guard system with `_activeYearToken` plus private `_SliceStatus` fields. Do not refactor to `guardedAction()`.
- **`SplashCubit.start()` exception:** one-shot bootstrap orchestration with a minimum-splash delay; called once from `initState`. Does not use `guardedAction()`.
- **`SomethingWentWrongState` is the uniform catch-all** — all `catch (_)` blocks emit it. Specific typed exceptions are mapped to specific states before the catch-all.
- **Never use `late` or `late final` in app code.** Prefer eagerly initialized `final` fields, nullable fields with explicit guards, or cubit-emitted state values read in `BlocBuilder`.
- **`@factory` (not `@singleton`)** — each page gets its own fresh cubit instance.

---

## State Management

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
- **No `copyWith` on `BaseState` subclasses** — always replace entirely. Each logical event must emit a distinct, immutable, `final`-only state class (no `copyWith`, no nullable result fields, no status enums embedded in state).

---

## Design & Theming

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

## Firestore

- **Paths are sacred** — never flatten nested collections:
  - Attendance: `users/{uid}/attendances/{YYYY-MM}/days/{YYYY-MM-DD}`
  - Health logs: `users/{uid}/healthLogs/{YYYY-MM}/entries/{logId}`
- **`yearMonth` format = `"YYYY-MM"`** (zero-padded month). **`date` format = `"YYYY-MM-DD"`**.
- **yearMonth derivation:** services always derive from the date string via `date.substring(0, 7)`. Callers never pass yearMonth separately.
- **No SQLite / Drift** — Firestore + SharedPreferences + FlutterSecureStorage only. The single exception is the Apple Health daily snapshot file (see **Apple Health (Health Insights)**).

---

## Apple Health (Health Insights)

Apple Health data is among the most sensitive data a user has, so these rules are strict. A step-by-step walk-through for newcomers: [`docs/guides/apple_health_data_flow.md`](../docs/guides/apple_health_data_flow.md). Feature map: [`docs/features/health_insights.md`](../docs/features/health_insights.md).

- **iOS only — Android must show nothing of this feature.** Gate every entry point: the Health tab's insights icon (`Platform.isIOS`), the sign-up personal-details step (`defaultTargetPlatform == TargetPlatform.iOS`), and `HealthKitSource` (reports "unavailable" off iOS). Widget tests run as Android by default — use `variant: TargetPlatformVariant.only(TargetPlatform.iOS)` for any iOS-only UI.
- **Read-only.** Never write to Apple Health. Request only the metrics listed in `HealthKitSource.units`, and keep the Swift `metrics` keys identical to the Dart `HealthMetric` names.
- **Apple Health data never leaves the device.** Never write it to Firestore, `SharedPreferences`, `FlutterSecureStorage`, logs, Crashlytics, analytics, or any network call. The **only** persisted copy is the daily snapshot file `health_insights_cache.json` in the OS cache directory (`getApplicationCacheDirectory()`, never backed up). It is deleted by `HealthRepository.clearCache()` and by `AccountCleanupService.deleteAllUserData`. Only the personal details the user types in themselves (`sex`, `birthDate`, `heightCm`, `weightKg`, `bodyType` on `users/{uid}`) may live in Firestore.
- **Bounded, cached reads.** Read at most the window starting at `MetricTimelineBuilder.reportingWindowStart()` (24 months). At most **one** Apple Health read per calendar day; refresh and retry go through `HealthInsightsCubit.refresh()` (`clearCache()` + `load()`) — UI code never calls the source. Changing the snapshot shape requires bumping `HealthSnapshot.version`.
- **iOS hides permission denial.** "No data at all" is treated as denied (`HealthPermissionDeniedException` → the "No Apple Health data" screen). Never claim to know the real permission state.
- **Keep the boundary.** Cubits, services, and pages depend on the `HealthRepository` interface only — never on `HealthKitSource` or the method channel. Tests use `MockHealthRepository` and the anonymized fixtures.
- **Anonymized fixtures only.** `test/fixtures/health_insights/*.json` must contain no names, real birth dates, or emails. Never commit a raw Apple Health export (`apple_health_export/` is gitignored). Regenerate fixtures only through `tools/extract_health_fixtures.mjs`.
- **No personal data anywhere in the repo** — real emails, names, birth dates, or passwords never appear in code, tests, comments, docs, or fixtures (use obvious placeholders such as `user@example.com`).
- **Privacy policy stays truthful.** Any change to what is read, stored, or shown from Apple Health must update `legal/privacy.html` (EN + RO) and `docs/legal/privacy-en.md` / `privacy-ro.md`, redeploy Firebase Hosting, and bump `appConfig/version.privacyVersion` so users re-accept it.
- **Docs move with the code.** Keep `docs/guides/apple_health_data_flow.md` and `docs/features/health_insights.md` in sync with any change to the bridge, channel, cache, or gating.

---

## Localization

- **All user-visible strings must use `AppLocalizations`** — ARB files at `lib/assets/localization/`.
- Supported languages: English (`en`), Romanian (`ro`).
- **Every widget and page** must use `AppLocalizations.of(context)` for all displayed text — no hardcoded English strings in `build()` methods. This includes labels, headers, placeholders, button text, and preview/mock data labels.
- **All emoji references must use `Emojis.*` constants** from `lib/presentation/resources/emojis.dart` — never use raw Unicode escapes (`\u{...}`) or literal emoji characters in widget code.

## Date Presentation

- **Every complete calendar date shown to users must use the fixed `dd.MM.yyyy` format** in every locale (for example, `02.07.2026`).
- Use `AppDateFormatter` for user-facing complete dates; do not use locale-dependent `MaterialLocalizations.format*Date()` methods or ad-hoc date interpolation.
- Firestore values, document IDs, and internal date keys remain canonical `YYYY-MM-DD` / `YYYY-MM`. Calendar day numbers, month/year headings, and times keep their purpose-specific formats.

---

## Code Quality

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
Future<void> example({
  required String userId,
  required String email,
  String? displayName,
})
```

---

## Reusable Controls

- If a widget is likely reused across the app, place it in `lib/presentation/controls/` as a public widget (one per file).
- **Always add a matching widget test** under `test/presentation/controls/`.
- Prefer extraction into `controls/` over duplicating similar widgets across pages.
- Expose the **inner view widget as a public class** (e.g. `RegisterView`) so tests can inject a mock cubit via `BlocProvider.value` without `getIt`.

---

## DTOs & Serialization

- DTOs use `@JsonSerializable()` + `json_annotation`.
- **ID fields excluded from JSON**: `@JsonKey(includeFromJson: false, includeToJson: false)` for IDs from Firestore doc ID (not stored as field).
- **`explicitToJson: true`** when DTO has nested lists (e.g. `SupplementProductDto`).
- **Timestamp fields typed as `Object` or `Object?`** — allows unit tests to pass plain `String`; production uses actual `Timestamp`.

---

## Page UI Workflow

When building or updating a page's UI, **always** follow this sequence:

1. **Read the prep doc** → `docs/screens/<page_name>.md` (widget tree, token mappings, interaction notes).
2. **Implement** using the prep doc as the single source of truth for layout, spacing, colours, and interactions.
3. **Do NOT copy from external projects.** The Angular source (`../src/`) is archived reference only — do not read, import, or cross-reference it during implementation. The prep docs already contain everything needed.

---

## Feature Documentation

- `docs/features/` is the canonical source for end-to-end feature behavior and code flow; `docs/screens/` remains the source for per-screen layout and interaction details.
- `docs/guides/` holds concept deep-dives written for learning the code (for example `apple_health_data_flow.md`). Guides quote real code — when a guided file changes, update the guide in the same change set.
- **Before changing a feature**, read its matching `docs/features/<feature>.md` file in addition to the relevant screen prep doc.
- Any change to a feature's behavior, data model, navigation, cubit states, business rules, or user workflow **must update the matching feature map in the same change set**.
- Every new user-facing feature must add a feature map based on `docs/features/_TEMPLATE.md` and an entry in `docs/features/README.md`.
- Every documented workflow must include both a Mermaid diagram and a short numbered **In plain English** explanation.
- Keep the feature status, last-updated date, key-file links, tests, edge cases, and known limitations accurate. Never leave a feature marked complete while it still contains TODO placeholders.

---

## Sources & Mappers

- **Every source:** `@injectable`, `const` constructor, receives mapper and `FirebaseFirestore` instance via injection.
- **Every mapper:** `@injectable`, no state, pure mapping functions. Handles `Timestamp.toDate()` and `Timestamp.fromDate()`.
- All sources use `.withConverter<Dto>()` on collection references. The `id` field is populated from `snap.id` inside the `fromFirestore` closure.

---

## Existence Guard Pattern

Used in `WorkoutService.update` and `HealthService.updateProduct`:

```dart
final existing = await _source.getById(userId, model.id);
if (existing == null) throw const TrainingTypeNotFoundException();
return _source.update(userId, model);
```

---

## AI Context Strategy

Context-loading guidance (feature-slice token estimates, foundations list, never-load list) lives in **[`.github/copilot-instructions.md` § 10](copilot-instructions.md)**.

---

## Git Conventions

- Default branch: `main`.
- Feature branches: `feature/<phase>-<description>`.
- Commit message style: `feat: <description>` / `chore: <description>` / `fix: <description>`.

---

## README Maintenance

The root [`README.md`](../README.md) is the public face of the project and **must stay in sync with the actual app**. After completing any of the following, update `README.md` in the same change set (or explicitly remind the user to do so before closing the task):

- **A new user-facing feature** is shipped (new screen, new flow, new major capability).
- **A major flow changes** (auth flow, navigation tree, version gate, onboarding, etc.).
- **The tech stack changes** — Flutter/Dart version bump, new core dependency (state mgmt, routing, backend, storage), or a removed one.
- **Setup, run, build, or test commands change** (new env var, new code-gen step, new platform target, new Firebase config requirement).
- **The Firestore data model changes** at the collection / top-level-field level.
- **The project structure changes** (top-level `lib/` folders added/renamed/removed).
- **Supported languages or platforms** change.

Sections to keep accurate at minimum: Features, Tech Stack, Project Structure, Getting Started, Configuration, Running the App, Testing, Firestore Data Model.

If a task touches one of the triggers above and the README was **not** updated, flag it to the user before considering the task done.
