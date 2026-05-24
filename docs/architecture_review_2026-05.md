# gym_tracker — Senior Architecture Review & Scale-Up Roadmap

**Date:** 2026-05-23
**Scope:** Full-app review across architecture, data, presentation, ops, security.
**Goal:** Identify what blocks scaling and define a prioritized roadmap.

---

## Executive Verdict

The app today is a **solid MVP** — clean Cubit/Source layering, `get_it` + `injectable` DI,
typed exceptions, centralized design tokens, GDPR / account-deletion done right, Crashlytics
wired, 42 unit/widget tests. **It will not scale** without changes across architecture, data,
presentation, ops, and observability.

### 9 Big Flaws

1. **God-pages.** `calendar_page.dart` ~2,350 LOC / 16 inner classes,
   `stats_page.dart` ~1,700 LOC / 15 classes, `health_page.dart` ~1,078 LOC.
   New features will deadlock merges and slow the IDE.
2. **No Repository layer + no local DB.** Cubits → Service → Source is mostly pass-through.
   No Isar / Drift / Hive. No place to put caching or stale-while-revalidate.
   Offline-first is impossible.
3. **No pagination on the one collection that needs it.** `supplementProducts` is a
   global catalog that grows with every user and is loaded fully into memory — it needs
   cursor paging + search. `trainingTypes`, `attendances`, and `healthLogs` are bounded
   (per-user catalog and `{yearMonth}` subcollections) and don't need paging; they need
   local caching to avoid re-reads on every visit.
4. **No environment flavors.** Single `firebase_options.dart` → every dev / QA write hits
   production.
5. **No CI/CD.** `.github/workflows/` is empty. Tests run manually; lint not enforced;
   releases ad-hoc.
6. **No analytics / observability.** No Firebase Analytics, no Performance Monitoring,
   no structured logger, no Remote Config beyond a hand-rolled `appConfig/version` doc.
   Cannot measure retention or funnel drop-off.
7. **Domain logic lives in Cubits.** Streak, heatmap, monthly stats roll-ups, multi-month
   stream merging, supplement grouping — none unit-testable without a full BlocTest harness.
8. **Zero `Semantics()` widgets.** App fails basic screen-reader requirements
   (also an EU EAA / App Store risk in 2025+).
9. **No retry, no connectivity awareness, no `RefreshIndicator`, no optimistic updates.**
   Stream errors are swallowed to empty lists — users see "no data" when they actually
   have data.

### Other Notable Issues

- **Anemic models** — no value objects for `Email` / `Password` / `Duration`, no invariants.
- **Sources & mappers are 0% tested** — the highest-bug-density layer.
- **No App Check** — backend reachable from any client running the app's API key.
- **`ingredients` Firestore rule too permissive** — any signed-in user can write.
- **`maintainState: false` on Stats / Health** forces full recomputation on every tab visit.
- **Form validators inlined** in 4+ pages (email regex, password rules duplicated).

---

## Findings by Layer

### A. Architecture & Layering

- **No Repository layer.** Cubits → Service → Source. Services are 80% pass-through; the
  missing abstraction means: (a) Cubits depend on Firestore-shaped data, (b) caching /
  offline cannot be inserted later without rewriting cubits, (c) no place for cross-source
  orchestration (e.g., "log supplement + bump user stats" is currently impossible
  atomically).
- **Cubits hold domain logic** that shouldn't live there: streak algorithm, heatmap
  aggregation, stats roll-ups, merging of 3 monthly attendance streams, supplement
  grouping by product. These belong in pure-Dart `domain/usecases/` — currently
  impossible to unit-test without a full cubit harness.
- **Models are anemic** (data bags). No invariants (`AttendanceDay` accepts any string for
  `date`). No factories for safe construction. No value objects for `Email`, `Password`,
  `Duration`.

### B. Data & Persistence

- **No local DB.** Relies on Firestore's _implicit_ SDK cache (enabled-by-default on
  mobile, but never configured / verified). No Isar, Drift, Hive, sqflite. Consequence:
  cold-start = empty UI until Firestore replies. No offline-first.
- **No pagination where it matters.** `supplementProducts` is the only truly unbounded
  collection (global catalog, potentially thousands) and needs `startAfterDocument`
  cursors + indexed search. `trainingTypes` is per-user and realistically caps at a
  handful; `attendances` / `healthLogs` are loaded one `{yearMonth}` subcollection at a
  time. Those three need local caching, not pagination.
- **No connectivity awareness** (`connectivity_plus` not in `pubspec`). `NoConnectionPage`
  is only reached if the _splash_ config fetch throws — runtime drops are invisible.
- **No retry / backoff.** Stream errors call `.catchError((_) => [])` and silently render
  empty. Users get "no data" when they actually have data.
- **Stats tabs use `maintainState: false`** — entire recomputation on every tab visit.
  Untenable as a user accumulates years of history.
- **Sources & mappers untested.** Zero tests for `*_source.dart` (the layer doing actual
  Firestore I/O). Most likely regression site.
- **DTOs use loosely-typed `Object` for timestamps** with try / catch fallback in mappers.
  Pragmatic but means schema drift is invisible until production crashes — needs Firestore
  schema-versioning strategy.

### C. Presentation

- **Calendar (2,350 LOC, 16 inner classes), Stats (1,700, 15), Health (1,078, 10)** —
  God-widgets. Multiple devs cannot work on them in parallel. Skeletons, day cells,
  sheets, carousels all inlined.
- **Zero `Semantics()` widgets** across `lib/presentation/`. App fails basic screen-reader
  / TalkBack / VoiceOver requirements (also a soft App-Store / EU EAA risk in 2025+).
- **No `RefreshIndicator`** anywhere — users cannot pull-to-refresh.
- **No optimistic updates.** Mark-attendance shows spinner, waits for Firestore
  round-trip, then updates UI. Should flip instantly.
- **Form validators inlined** in 4+ pages. Email regex duplicated. Password rules
  duplicated. No `lib/presentation/validators/` package.
- **No `FutureButton` / debounce.** Double-tap on submit can submit twice (mitigated only
  by `guardedAction` at cubit level, which is good but fragile).
- **No design-system documentation** (no Storybook / Widgetbook). The 27 controls are
  great, but adoption is by convention only.

### D. Quality, Ops, Observability

- **No `.github/workflows/`** — verified, the folder is empty. No CI, no PR test gate,
  no auto-lint, no build artifact, no release pipeline.
- **No analytics.** Firebase Analytics not in `pubspec`. Cannot measure D1 / D7 / D30,
  funnel drop-off, feature usage. Roadmap KPIs are unmeasurable.
- **No structured logging.** `print` and Crashlytics only. No `logger` / no log levels /
  no breadcrumbs.
- **No environment flavors.** Single `firebase_options.dart` → all dev work writes to
  prod. Recipe for data corruption.
- **No Firebase Remote Config** beyond the `appConfig/version` doc the team hand-rolled.
  Feature flags impossible without a release.
- **No Firebase Performance Monitoring.**
- **No code-coverage tooling** (`lcov`, Codecov badge). Coverage is invisible.
- **Lint rules minimal** (`flutter_lints` defaults only). Missing:
  `prefer_const_constructors`, `avoid_dynamic_calls`, `use_build_context_synchronously`,
  `unawaited_futures`, `require_trailing_commas`, `no_logic_in_create_state`, …
- **No deep-link handling** for password-reset / email-verification return-from-browser.
  Users have to manually re-open the app.

### E. Security

- Firestore rules generally tight (ownership-checked); GDPR consent recorded properly
  with versioned terms / privacy.
- **`ingredients` collection writable by any signed-in user** — should be admin-only
  after seed.
- **Firebase Auth reCAPTCHA disabled in debug** is fine, but no automated check that
  it's _not_ disabled in release builds.
- **No App Check** (`firebase_app_check`) — backend can be hit from any client running
  the app's API key.
- **No certificate pinning** for non-Firebase endpoints (legal URLs etc.) — low risk
  because https-only is enforced.

---

## Recommended Roadmap

### Phase 0 — Foundations (P0, do first; unblocks everything else)

1. **CI/CD pipeline.** `.github/workflows/ci.yml`: `flutter analyze`,
   `flutter test --coverage`, `flutter build apk --debug` (smoke). PR-gated.
   Codecov upload.
2. **Build flavors.** Add `dev` / `staging` / `prod` flavors with separate Firebase
   projects and `firebase_options_<flavor>.dart` generated via FlutterFire CLI per
   flavor. Wire entry points `main_dev.dart` / `main_prod.dart`. Update
   `android/app/build.gradle.kts` `productFlavors` block + iOS schemes.
3. **Stricter lints.** Extend `analysis_options.yaml` with the missing rules.
   Treat warnings as errors in CI.
4. **Firebase Analytics + structured logger.** Add `firebase_analytics`, `logger` to
   `pubspec.yaml`. Create `AnalyticsService` injected via `@lazySingleton`. Log key
   events: `sign_up`, `sign_in`, `workout_marked`, `supplement_logged`, `tab_view`,
   `error_*`.
5. **App Check.** Add `firebase_app_check` with Play Integrity (Android) /
   DeviceCheck (iOS).

### Phase 1 — Architecture Hardening (P1)

6. **Introduce a Repository layer.** `lib/data/repositories/<feature>_repository.dart`.
   Services keep network / Firebase concerns; repositories own caching, merging
   local + remote, and exposing streams of `Result<T, Failure>`. Cubits depend on
   repositories, not services. **Single biggest leverage change.**
7. **Extract domain logic out of cubits.** New `lib/domain/usecases/` (pure Dart, no
   Flutter import). Examples: `ComputeAttendanceStreak`, `ComputeHeatmap`,
   `RollUpMonthlyStats`, `GroupSupplementLogsByProduct`. Trivially unit-testable.
8. **`Result<T, Failure>` everywhere.** Replace try / catch ladders with
   `sealed class Failure` (`NetworkFailure`, `AuthFailure`, `NotFoundFailure`,
   `ValidationFailure`, `UnknownFailure`). `fpdart` or hand-rolled. Eliminates
   `SomethingWentWrongState`.
9. **Value objects for primitives.** `Email`, `Password`, `WorkoutDuration`.
   Validators live on the type, not in form widgets. Reuse in cubits + form widgets.

### Phase 2 — Data Scalability (P1)

10. **Local persistence with Isar or Drift.** Cache: attendances by month, training
    types, user's products, last user profile. Repository pattern reads cache first,
    then refreshes from Firestore (stale-while-revalidate). Offline-first becomes
    possible.
11. **Explicit Firestore offline config.** Call
    `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true,
cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED)` in `FirebaseModule` and document it.
12. **Pagination.** `supplementProducts` infinite-scroll with `startAfterDocument`
    cursors and a `SearchProductsUseCase` indexed on lowercased name.
    (`trainingTypes`, `attendances`, and `healthLogs` don't need this — they're either
    per-user bounded or already scoped by the `{yearMonth}` subcollection window.)
13. **Connectivity awareness.** Add `connectivity_plus`. Show a global offline banner
    (single widget mounted in `MainShellPage`). Repositories degrade to cache-only
    when offline; queue mutations.
14. **Retry with backoff.** Wrap remote calls in `Retry(attempts: 3, backoff:
exponential)` for transient errors (`unavailable`, `deadline-exceeded`).
    Do NOT retry permission / not-found.
15. **Source-layer tests** using `fake_cloud_firestore` (or Firestore emulator).
    Cover every `*_source.dart` and every mapper. Highest-bug-density layer with
    0% test coverage today.

### Phase 3 — Presentation Polish (P2)

16. **Split God-pages.** Calendar / Stats / Health → break into
    `pages/<feature>/widgets/*.dart`. Target: no file > 500 LOC.
    Suggested calendar layout:

    ```
    calendar/
      ├── calendar_page.dart          (routing + cubit only)
      ├── calendar_view.dart          (main state holder)
      ├── widgets/
      │   ├── calendar_day_cell.dart
      │   ├── calendar_day_sheet.dart
      │   ├── supplement_carousel.dart
      │   ├── calendar_month_view.dart
      │   └── calendar_year_view.dart
      └── skeleton/
          ├── calendar_month_skeleton.dart
          └── calendar_year_skeleton.dart
    ```

17. **Accessibility pass.** Wrap all interactive elements in
    `Semantics(button: true, label: …)`. Verify with TalkBack / VoiceOver.
    Document WCAG-AA contrast for `AppColors`.
18. **`RefreshIndicator`** on every scrollable data view.
19. **Optimistic updates** for mark-attendance and log-supplement (repository pattern
    from Phase 1 makes this clean).
20. **Form validators package** `lib/presentation/validators/`. Compose with value
    objects from Phase 1.
21. **Widgetbook** for the 27 controls — visual regression catch + onboarding for new
    devs.

### Phase 4 — Observability & Release Engineering (P2)

22. **Firebase Remote Config** for feature flags
    (`feature_new_dashboard`, `feature_meal_planner`). Replace ad-hoc
    `appConfig/version` extensions.
23. **Firebase Performance Monitoring** + custom traces around cold-start, splash
    gate, calendar month load.
24. **Crashlytics breadcrumbs.** Log every `Cubit` state transition as a breadcrumb.
    Crash reports become useful.
25. **Code coverage in CI.** Codecov badge in README. Target: 70% line coverage on
    `domain/` and `data/`.
26. **Fastlane / `flutter_distributor`** for `android beta` and `ios beta` lanes →
    Firebase App Distribution. (`docs/release/` exists but seems doc-only.)
27. **Integration tests** with `integration_test` + `patrol` for golden flows:
    sign-up → mark attendance → view stats.

### Phase 5 — Security (P2)

28. Lock `ingredients` write to `request.auth.token.admin == true` after initial seed.
29. Verify reCAPTCHA NOT disabled in release builds (compile-time assertion or a
    launch-time check).
30. Add **Sign in with Apple** (Apple requires it if any 3rd-party social sign-in is
    added later) — preempts an iOS review block.

---

## What I'd Do First — One-Sprint Slice

1. CI + lint + analyzer-clean (Day 1).
2. Build flavors with a separate dev Firebase project (Day 1–2).
3. Repository layer + `Result<T, Failure>`; refactor Auth + Calendar as the proof
   (Day 3–5).
4. Isar caching for attendances + training types (Day 6–8).
5. Split `calendar_page.dart` into 8 files (Day 9).
6. Analytics events + App Check (Day 10).

Everything else is a follow-up sprint.

---

## Critical Files / Symbols (most-impacted)

| File                                                                                                        | Why it matters                                                                                                                                                                    |
| ----------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [lib/cubit/calendar/calendar_cubit.dart](../lib/cubit/calendar/calendar_cubit.dart)                         | Needs Repository extraction (caching + merge current-month stream with prev/next prefetch).                                                                                       |
| [lib/cubit/stats/stats_cubit.dart](../lib/cubit/stats/stats_cubit.dart)                                     | Domain math (streak / heatmap / roll-ups) belongs in `domain/usecases/`.                                                                                                          |
| [lib/presentation/pages/calendar/calendar_page.dart](../lib/presentation/pages/calendar/calendar_page.dart) | 2,350 LOC — split.                                                                                                                                                                |
| [lib/presentation/pages/stats/stats_page.dart](../lib/presentation/pages/stats/stats_page.dart)             | 1,700 LOC — split.                                                                                                                                                                |
| [lib/presentation/pages/health/health_page.dart](../lib/presentation/pages/health/health_page.dart)         | 1,078 LOC — split.                                                                                                                                                                |
| [lib/core/firebase_module.dart](../lib/core/firebase_module.dart)                                           | Add explicit offline `Settings` + App Check.                                                                                                                                      |
| [firestore.rules](../firestore.rules)                                                                       | Tighten `ingredients` writes.                                                                                                                                                     |
| [analysis_options.yaml](../analysis_options.yaml)                                                           | Extend lint set.                                                                                                                                                                  |
| [pubspec.yaml](../pubspec.yaml)                                                                             | Add `firebase_analytics`, `firebase_app_check`, `firebase_remote_config`, `firebase_performance`, `connectivity_plus`, `logger`, `isar` / `drift`, `fpdart` (optional), `patrol`. |

---

## Decisions Pending

1. **Repository shape:** Service + Repository, or Repository replaces Service?
   → _Recommend: Repository replaces Service_ (services collapse to thin Firebase
   adapters only where Firebase exposes a non-trivial API).
2. **Local DB:** Isar / Drift / Hive? → _Recommend Isar_ (fastest, schema-driven).
3. **State pattern:** Sealed everywhere, or keep `BaseState` + distinct classes?
   → _Decided: keep the existing `BaseState` (Equatable) + one-class-per-event
   convention._ No Dart 3 `sealed` migration.
4. **Analytics vendor:** Firebase Analytics vs PostHog / Amplitude?
   → _Recommend Firebase first_; reassess at 10k MAU.
5. **Drop Splash-cubit version gate in favor of Remote Config?**
   → _Recommend: yes, eventually_ — cut custom `appConfig/version` once Remote Config
   is in.
6. **Sprint scope:** Phase 0 only, or 0 + 1 + small slice of 2 (Auth + Calendar
   refactor proof) in one sprint? → _Recommend the latter._
