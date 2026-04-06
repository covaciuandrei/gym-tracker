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
- **`StatsCubit` exception:** uses its own token-based guard system with `_activeYearToken` and `StatsLoadStatus` checks. Do not refactor to `guardedAction()`.
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
- **No `copyWith` on `BaseState` subclasses** — always replace entirely. Exception: `StatsLoadedState` uses `copyWith` for its multi-tab independent loading pattern.

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
- **No SQLite / Drift** — Firestore + SharedPreferences + FlutterSecureStorage only.

---

## Localization

- **All user-visible strings must use `AppLocalizations`** — ARB files at `lib/assets/localization/`.
- Supported languages: English (`en`), Romanian (`ro`).
- **Every widget and page** must use `AppLocalizations.of(context)` for all displayed text — no hardcoded English strings in `build()` methods. This includes labels, headers, placeholders, button text, and preview/mock data labels.
- **All emoji references must use `Emojis.*` constants** from `lib/presentation/resources/emojis.dart` — never use raw Unicode escapes (`\u{...}`) or literal emoji characters in widget code.

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
Future<void> initializeProfileOnFirstLogin({
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

## Testing

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

## Sources & Mappers

- **Every source:** `@injectable`, `const` constructor, receives mapper via injection, accesses `FirebaseFirestore.instance` directly (not injected).
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

This project is ~120k tokens (hand-written lib/) or ~186k tokens (lib + test + docs + config).

### Always include these foundations (~20k tokens)

Every AI session must start with these files loaded, regardless of feature:

- `.github/copilot-instructions.md` — architecture map, design tokens, controls inventory
- `.github/rules.md` — this file
- `lib/presentation/resources/app_colors.dart` + `lib/assets/theme/custom_theme.dart` — design tokens
- `lib/model/` — all shared domain models
- `lib/cubit/base_cubit.dart` + `lib/cubit/base_state.dart` — base classes
- The relevant `docs/screens/<page>.md` prep doc
- The relevant reusable controls from `lib/presentation/controls/`

### Feature-slice approach (default)

For any task, load **only** the relevant vertical slice on top of the foundations:

| Feature | Slice to load | ~Tokens |
|---|---|---|
| Auth | auth pages + auth cubit/states + auth service | ~25k |
| Calendar | calendar page + calendar cubit + attendance service/data + mappers | ~50k |
| Stats | stats page + stats cubit + relevant services | ~40k |
| Health | health page + health cubit + health service/data + supplement models | ~35k |
| Workout Types | workout_types page + workout cubit + workout service/data | ~20k |
| Profile/Settings | profile + settings pages + settings cubit | ~15k |

This approach works within any 200k context window, leaving room for conversation and output.

### Full-project load (complex cross-cutting tasks only)

The entire Flutter project (lib + test + docs + config, no generated files) fits in ~186k tokens. Loading everything is acceptable **only** for:

- Cross-cutting refactors that touch 3+ features
- Architecture changes (DI, routing, base classes)
- Full audit / review tasks

For a 200k context window this leaves ~14k for conversation — tight but workable. For 400k windows it's comfortable.

### Never load

- Generated files (`.g.dart`, `.gr.dart`, `.config.dart`, generated localizations, `firebase_options.dart`) — ~29k tokens of noise
- The Angular source (`../src/`) — archived, not needed for implementation
- Binary assets (fonts, images)

---

## External Project References

- **Angular source (`../src/`):** Archived reference only. Do **not** read, copy from, or cross-reference during implementation. All necessary information has been captured in `docs/screens/` prep docs and `copilot-instructions.md`.
- **Other external projects:** Do not reference or copy from any external project codebase. Follow only the architecture, patterns, and conventions defined in this file and `copilot-instructions.md`.

---

## Git Conventions

- Default branch: `master`.
- Feature branches: `feature/<phase>-<description>`.
- Commit message style: `feat: <description>` / `chore: <description>` / `fix: <description>`.
