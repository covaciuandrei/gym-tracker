# Feature Maps

> **Canonical, human-readable map of every feature in the app.**
> Each file explains one feature end-to-end: purpose, entry points, code layers,
> data model, states, workflows (diagram **+** plain-English steps), rules, tests,
> and known limitations.

## Why this exists

`docs/screens/` describes **per-screen UI layout** (widget trees, tokens). This folder
describes **per-feature behavior and code flow**, which usually spans several screens
(e.g. Gym Membership touches Calendar, Profile, and the Membership History page).

These files are the first thing an AI (or a human) should read to understand or safely
change a feature. They are kept in sync via the **Feature Documentation** rule in
[`.github/rules.md`](../../.github/rules.md): any change to a feature's behavior, data
model, workflow, navigation, or states must update the matching file here in the same
change set.

## How to add / update

1. Copy [`_TEMPLATE.md`](_TEMPLATE.md) to `docs/features/<feature>.md`.
2. Fill in every section. Every workflow gets a mermaid diagram **and** a plain-English
   numbered list (house style is documented in the template).
3. Add the feature to the index below.
4. Bump **Last updated** whenever you touch it.

## Feature index

| Feature | Doc | Status |
| ------- | --- | ------ |
| Gym membership (manual purchase history) | [gym_membership.md](gym_membership.md) | ✅ Implemented |
| Calendar (attendance + supplements + membership reminder) | [calendar.md](calendar.md) | ✅ Implemented |
| Authentication & account | [auth.md](auth.md) | ✅ Implemented |
| Statistics dashboard | [stats.md](stats.md) | ✅ Implemented |
| Health & supplements | [health_supplements.md](health_supplements.md) | ✅ Implemented |
| Workouts hub | [workouts.md](workouts.md) | ✅ Implemented |
| Workout types | [workout_types.md](workout_types.md) | ✅ Implemented |
| Profile | [profile.md](profile.md) | ✅ Implemented |
| Settings | [settings.md](settings.md) | ✅ Implemented |
| App version gate (splash / maintenance / force-update) | [app_version_gate.md](app_version_gate.md) | ✅ Implemented |
| Onboarding | [onboarding.md](onboarding.md) | ✅ Implemented |

> **Status legend:** ✅ Implemented = complete and verified · 🚧 In progress = the
> implementation or its feature map is intentionally incomplete.

## Relationship to other docs

- **Reference facts** (design tokens, controls inventory, route tree, Firestore model):
  [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md).
- **Coding rules:** [`.github/rules.md`](../../.github/rules.md).
- **Per-screen UI prep:** [`docs/screens/`](../screens/).
- **Feature behavior & code flow (this folder):** the canonical map for changing a feature.
