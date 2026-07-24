# Supplements Refactor Plan — MyFitnessPal-style catalog

> **Status:** 📋 Planned, not started
> **Created:** 2026-07-23
> **Scope:** Refactor of the Health / Supplements feature only.

## Goal

Rebuild the supplements feature around a **curated, searchable catalog** with a
**standardized, admin-curated ingredient database**. Users search products → open a
**detail screen** showing the full ingredient breakdown with **age/sex-specific % daily
value** and safety-limit warnings → pick servings → log. Products stay global but carry
an **"Unverified" badge** until a single **admin-role** account verifies them. A one-off
**Node.js migration** seeds the ingredient catalog and re-standardizes existing data.

---

## Why (current problems)

The feature is architecturally clean (Model → DTO → Mapper → `HealthSource` →
`HealthService` → `HealthCubit` → `HealthPage`), but the data model and sourcing strategy
are the wrong shape for MyFitnessPal-style discovery:

1. **There is no real catalog.** Products are user-created but written to a *global*
   collection — every user's homemade entry pollutes everyone's "All Supplements". No
   curated, verified, searchable database.
2. **The `ingredients` collection is dead.** The schema documents a rich ingredient
   catalog (canonical name, aliases, category, RDA, safe upper limit) and the security
   rules protect it — but no code ever reads or writes it. Ingredients are typed freehand
   into each product.
3. **Ingredient identity is broken.** `stdId` is just a lowercase slug of typed text.
   "Vitamin C", "vitamin c", and "VitC" become three different nutrients — which silently
   **breaks the nutrient roll-up in Stats** (keys on `stdId|unit`).
4. **No product detail screen.** MFP's core loop is *search → open product → see full
   ingredient/nutrient breakdown → log*. Here you only get name + brand + first 3
   ingredients on a card.
5. **It won't scale.** `watchAllProducts()` streams the *entire* global catalog into
   memory; search is a client-side `.contains()`. The architecture review already flags
   this as the one collection that needs cursor paging + real search.

---

## Locked decisions

- Supplements only (no foods / macros / calories).
- Curated, self-seeded Firestore catalog (no external API).
- Strict catalog-only ingredient selection — users pick ingredients only from the
  canonical catalog; they cannot free-type new ones.
- Global products, visible immediately, badged **"Unverified"**.
- No barcode scanning in v1.
- Single admin account (`role: admin`, set manually in the Firebase Console) can **verify
  products** and **manage the ingredient catalog** in-app — but **not** edit/delete other
  users' products.
- **Age/sex-specific RDAs** → requires capturing the user's **sex** and **birth date**
  (new profile fields; today only a "16+" checkbox exists at registration).
- Detail screen with servings chosen at log time (MFP loop).
- Firestore normalized-prefix search + cursor pagination (catalog is hundreds–low thousands).
- Migration does **full re-standardization** and **discards** freehand ingredients with no
  canonical match (a product may end up with zero ingredients but is kept).
- Ingredient seed data: a curated starter set (~100–150 common supplement ingredients with
  NIH/FDA references) that the admin expands later.
- Migration executed via a **Node.js firebase-admin** script.

---

## Target schema

```
ingredients/{id}
  name, nameLower, aliases[], aliasesLower[], category, defaultUnit,
  rda            { male: { <age_band>: value }, female: { ... } }
  safeUpperLimit { male: { <age_band>: value }, female: { ... } }
  createdBy?, createdAt

supplementProducts/{id}
  name, nameLower, brand, brandLower,
  ingredients [{ ingredient_id, name, amount, unit }]   ← now references canonical ingredient
  servingsPerDayDefault, createdBy?, verified (bool → badge), createdAt, updatedAt

users/{uid}
  ...existing...
  role?      "admin" | absent
  sex?       "male" | "female" | null
  birthDate? "YYYY-MM-DD" | null

users/{uid}/healthLogs/{YYYY-MM}/entries/{id}
  unchanged (snapshots name/brand; ingredient breakdown read from the live product)
```

Age bands: `14_18 / 19_50 / 51_70 / 71_plus`. Sex: male/female. Pregnancy/lactation
excluded in v1.

---

## Phases

### Phase 0 — Foundations & schema *(everything else depends on this)*
1. New `Ingredient` domain model + value objects for the RDA/upper-limit tables (keyed by
   sex → age band).
2. Change `ProductIngredient`: `stdId` → `ingredientId` (FK into canonical catalog); keep
   denormalized `name` / `amount` / `unit` for display.
3. Extend `User` model with `role`, `sex`, `birthDate`.
4. Matching DTOs + mappers (`ingredient_dto`, updated `product_ingredient_dto` →
   `ingredient_id`, `supplement_product_dto` → add `nameLower` / `brandLower`, `user_dto` →
   new fields).
5. Update `firestore.rules`: add `isAdmin()` helper (reads `users/{uid}.role`); `ingredients`
   writable only by admin; `supplementProducts` `verified` field only settable/changeable by
   admin; owners keep create/edit of their own products.
6. Localization scaffold (EN + RO) for all new strings.

### Phase 1 — Ingredient catalog *(after P0; parallel with P2)*
7. `IngredientSource` + `IngredientService` + `IngredientCubit`: prefix search (`nameLower`
   + alias lookup), admin create/edit/delete.
8. Admin-only **Ingredient Management** page (`AdminGuard`) — list/search + form for name,
   aliases, category, unit, and a compact RDA/UL editor.
9. Reusable **ingredient picker** control with catalog autocomplete (strict: pick-from-catalog
   only).

### Phase 2 — RDA engine + profile capture *(after P0; parallel with P1)*
10. Pure-Dart `DailyValueService`: `(ingredient, sex, age) → % daily value + over-upper-limit
    flag`; age bands `14–18 / 19–50 / 51–70 / 71+`.
11. Add `sex` + `birthDate` capture to **Settings** (new "Personal details" section) via
    `SettingsCubit` + `UserService` / `UserSource`.

### Phase 3 — Catalog search + detail + logging *(after P1, P2)*
12. `HealthSource.searchProducts(query, cursor, limit)` — `nameLower` prefix range query +
    `startAfterDocument` pagination; `HealthCubit` search/pagination states.
13. New **Supplement Detail page/route**: full ingredient breakdown with `DailyValueService`
    % DV rows + UL warnings, servings selector, **Log** button.
14. Refactor `HealthPage`: **Today** (kept), **Search catalog** (replaces "All Supplements",
    paginated), **My Supplements** (own products).

### Phase 4 — Product form + moderation *(after P3)*
15. Product create/edit uses the strict ingredient picker (Phase 1); writes `nameLower` /
    `brandLower`; new products `verified=false`.
16. **Unverified badge** control on cards/detail; admin-only **Verify** action on detail
    (flips `verified`).

### Phase 5 — Stats & Calendar compatibility *(after P0–P4)*
17. `stats_cubit.dart` (~L472): key nutrient aggregation on `ingredientId|unit` (fixes the
    collision bug).
18. Update `calendar_page.dart` product/ingredient usages to the new shape.

### Phase 6 — Seed + migration *(after schema stable, P0–P4)*
19. Author `tools/seed_ingredients.json` (~100–150 curated supplement ingredients: vitamins,
    minerals, amino acids, creatine, caffeine, omega-3, etc., with NIH/FDA age/sex RDAs +
    tolerable upper limits).
20. `tools/migrate_supplements.mjs` (firebase-admin, dry-run + idempotent): seed `ingredients`;
    add `nameLower` / `brandLower`; re-standardize existing products (match freehand ingredient
    by name/alias → `ingredient_id`, **discard unmatched**); set existing user products
    `verified=false`.

### Phase 7 — Tests, docs, verification
21. Unit tests: `DailyValueService`, mappers, search pagination, ingredient/health cubits;
    widget tests: detail + log-with-servings, admin gating; run migration against the Firestore
    emulator.
22. Update `docs/features/health_supplements.md` and the controls inventory in
    `.github/copilot-instructions.md`.

---

## Relevant files

- `lib/model/supplement_product.dart` — `ProductIngredient.stdId` → `ingredientId`
- `lib/model/user.dart` — add `role`, `sex`, `birthDate`; new `lib/model/ingredient.dart`
- `lib/data/remote/supplement/health_source.dart` — paginated `searchProducts`, `verifyProduct`,
  `nameLower` writes; new `lib/data/remote/ingredient/`
- `lib/data/mappers/supplement_mapper.dart` — `ingredient_id`; new `ingredient_mapper.dart`
- `lib/service/health/health_service.dart` — search/verify; new `lib/service/ingredient/` +
  `lib/service/nutrition/daily_value_service.dart`
- `lib/cubit/health/health_cubit.dart` — search/detail/verify/log states; new
  `lib/cubit/ingredient/`
- `lib/presentation/pages/health/health_page.dart` — tab refactor; new detail page + admin
  ingredient page
- `lib/presentation/pages/settings/settings_page.dart` — sex/birthDate section
- `lib/core/app_router.dart` — detail + admin routes; new `lib/core/guards/admin_guard.dart`
- `lib/cubit/stats/stats_cubit.dart` — `ingredientId` keying
- `firestore.rules` — `isAdmin()`, ingredient writes, `verified` field control
- `lib/assets/localization/app_en.arb` · `app_ro.arb` — new keys
- `tools/seed_ingredients.json` + `tools/migrate_supplements.mjs` — new

---

## Verification

1. `flutter analyze` clean; `dart run build_runner build` regenerates DTO/router/DI without
   errors.
2. `flutter test` green, including new `DailyValueService`, search-pagination, and detail-flow
   tests.
3. Migration runs against the Firestore emulator: ingredients seeded, existing products carry
   `ingredient_id`s (unmatched dropped), `verified=false` set; re-run is a no-op (idempotent).
4. Manual: search paginates; detail shows correct % DV for a set age/sex and a UL warning when
   exceeded; % DV hidden with a prompt when the profile is incomplete; admin account sees Verify
   + ingredient management, a normal account does not (confirm Firestore rules reject a non-admin
   `verified=true` write).

---

## Further considerations (open, non-blocking)

1. **Sex/birth-date capture + incomplete-profile fallback.** Recommend capturing in **Settings**
   (+ an inline "set age & sex" prompt on the detail screen) and leaving registration's 16+
   consent checkbox untouched; show absolute amounts always but **hide % DV** until the profile
   is complete.
   - Option A: Settings + prompt *(recommended)*
   - Option B: also add to registration
   - Option C: use a generic-adult default so % DV always shows
2. **Admin RDA/UL editing depth.** The per-sex×age-band tables are the heaviest UI. Recommend v1
   admin form edits name/aliases/category/unit + **verify**, while the numeric RDA/UL tables come
   from the seed JSON (re-run/Console to change).
   - Option A: light form + seed-driven numbers *(recommended)*
   - Option B: full in-app matrix editor now
3. **Pregnancy/lactation RDAs.** Recommend **excluding** these life-stage groups in v1
   (male/female × age bands only).
   - Option A: exclude *(recommended)*
   - Option B: include now
