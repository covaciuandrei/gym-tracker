# Gym Tracker Upgrade Roadmap

Date: 23 May 2026

This roadmap prioritizes feature growth while improving quality, reliability, and scalability in parallel.

## Product Direction

- Build for all three goals: growth, stability/quality, and portfolio-level polish.
- Keep feature delivery as the main driver.
- Start with architecture/rules alignment to reduce implementation friction.
- Add Connected Health and Social Coordination as first-class roadmap tracks.

## Phases

### Phase 0: Alignment and Rule Sync (Week 1)

- Sync architecture guidance in .github/copilot-instructions.md with actual code patterns.
- Resolve current rule direction explicitly (for example BaseCubit mutation conventions).
- Define product KPIs for upcoming releases:
  - D7 retention
  - Weekly active users
  - Logs per active user
  - Feature adoption rate

### Phase 1: Retention Feature Pack (Weeks 1-4)

- Add monthly/weekly goals with progress indicators in calendar and profile.
- Add reminder and streak notification controls in settings.
- Add faster today quick-log path and clearer empty-state guidance.
- Localize all new UI and messages in EN/RO.

### Phase 2: Connected Health Integration (Weeks 4-7)

- iOS: integrate Apple Health via HealthKit read-sync flow.
- Apple Watch data is consumed through Apple Health (no watch app required for v1).
- Android: add Health Connect parity path even without smartwatch usage.
- Import target metrics for v1:
  - steps
  - active energy
  - heart rate
  - resting heart rate
  - workouts
  - sleep
  - body metrics where available
- Add source tagging to imported records:
  - manual
  - apple_health
  - health_connect
- Add settings controls for health sync:
  - connect/disconnect
  - per-metric toggles
  - sync frequency
  - conflict preference

### Phase 3: Workout Depth (Weeks 7-10)

- Extend workout logging beyond attendance and duration with exercise items (sets/reps/weight).
- Expand stats with exercise-level progression insights.
- Add body measurement tracking and trend visualizations.

### Phase 4: Social Coordination Layer (Weeks 8-12)

- Add friend graph basics:
  - search users
  - send/accept/remove requests
  - block/report minimum safety actions
- Add workout invite flow:
  - create planned session with date/time window, place, and workout type
  - invite friends
  - RSVP states: going, maybe, cannot
- Add daily social plan board with visibility options.
- Add optional 24h story-style plan card so friends can discover and join sessions.
- Keep v1 social focused on coordination utility.
- Defer feed complexity (likes/comments/chat) until adoption data supports it.

### Phase 5: Project Quality Track (Weeks 1-12, parallel)

- Add CI checks for analysis, targeted tests, and release build validation.
- Add analytics instrumentation for funnels and drop-offs.
- Improve recoverability with typed error states and retry UX.
- Run accessibility pass (semantics, focus flow, contrast).
- Tighten security/data hygiene (for example ingredients write controls after seeding).

### Phase 6: Scale and Cost Readiness (Weeks 12-16)

- Optimize heavy stats and calendar load patterns with caching and selective precomputation.
- Design offline-first approach (cached reads, queued writes, conflict handling).
- Add Firestore cost/read observability and performance SLOs per active user.

## Implementation Decisions

- Connected Health scope is in.
- Social scope is in, starting with coordination-first patterns.
- First-delivery boundaries prioritize:
  - goals/reminders/quick-log
  - connected health ingestion
  - before major offline-first refactor

## Preferred Options

1. Connected health rollout:

- Option A: iOS only first
- Option B: iOS + Android Health Connect in same release
- Option C: iOS first, Android in next minor
- Preferred: Option B if capacity allows, otherwise Option C

2. Health data ownership:

- Option A: read-only import from platform health stores
- Option B: read + write-back
- Preferred: Option A for v1

3. Social scope:

- Option A: coordination only (friends, invites, schedule board, optional 24h story)
- Option B: full social feed
- Preferred: Option A for v1

4. Social privacy defaults:

- Option A: private by default, explicit opt-in to share
- Option B: friends-visible by default
- Preferred: Option A

5. Safety baseline:

- Option A: minimal profile + block/report + invite throttling in v1
- Option B: postpone safety tooling
- Preferred: Option A

## Verification

1. Architecture sync verification:

- Ensure rule-to-code parity for BaseCubit and mutation/state handling before feature work.

2. Static quality gate per milestone:

- Keep dart analyze output clean.

3. Feature-slice testing per milestone:

- Run relevant cubit/page/control test slices for changed features.

4. Connected health verification:

- Validate HealthKit permission prompts and sync correctness on iOS.
- Validate Health Connect permissions and parity behavior on Android-supported devices.

5. Social verification:

- Validate friend request lifecycle.
- Validate invite RSVP transitions.
- Validate visibility controls (private/friends/public where enabled).
- Validate story expiry behavior.

6. Manual product QA:

- auth
- calendar log/edit/remove
- stats tab/year switching
- health today/my/all
- settings
- app-version prompts

7. KPI verification:

- Confirm event capture and compare retention/adoption metrics after each phase.

8. Security and release verification:

- Validate rules behavior and release checklist at phase boundaries.

## Primary File Targets

- .github/copilot-instructions.md
- lib/cubit/base_cubit.dart
- lib/cubit/calendar/calendar_cubit.dart
- lib/cubit/stats/stats_cubit.dart
- lib/cubit/health/health_cubit.dart
- lib/presentation/pages/calendar/calendar_page.dart
- lib/presentation/pages/stats/stats_page.dart
- lib/presentation/pages/health/health_page.dart
- lib/presentation/pages/settings/settings_page.dart
- lib/presentation/pages/profile/profile_page.dart
- lib/core/app_router.dart
- lib/service/health/health_service.dart
- lib/service/attendance/attendance_service.dart
- lib/service/workout/workout_service.dart
- lib/service/auth/auth_service.dart
- lib/data/remote/supplement/health_source.dart
- lib/model/attendance_day.dart
- lib/model/attendance_stats.dart
- lib/model/user.dart
- ios/Runner/Info.plist
- android/app/src/main/AndroidManifest.xml
- firestore.rules
- pubspec.yaml
- README.md
- docs/release/android_v1_checklist.md
