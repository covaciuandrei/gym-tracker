# Membership History Page — Screen Doc

> Last updated: 2026-07-22

## Route

`/membership-history` (authenticated, pushed from Profile, the Calendar
reminder, or the Calendar app-bar shortcut)

Optional route argument: `startAddFlow: true` opens the normal add/copy flow after the first history load.

## Purpose

Track manually entered gym-membership purchases. This feature does not process payments, infer renewals, or mutate expired records. Every renewal creates a new historical record.

## Architecture

```
MembershipHistoryPage / MembershipHistoryView
  → MembershipCubit
  → GymMembershipService
  → GymMembershipSource
  → users/{uid}/gymMemberships/{membershipId}
```

- `MembershipHistoryPage` implements `AutoRouteWrapper` and creates a fresh `MembershipCubit`.
- `MembershipHistoryView` is public so widget tests can inject a mock Cubit.
- All writes use `BaseCubit.guardedAction()`.
- `GymMembershipService` applies update/delete existence guards.
- `GymMembershipSource` uses `withConverter<GymMembershipDto>()`.

## Stored fields

| Field             | Type                | Notes                                             |
| ----------------- | ------------------- | ------------------------------------------------- |
| `gym_name`        | String              | Gym or club display name                          |
| `start_date`      | `YYYY-MM-DD` String | Purchase/start date, timezone-safe                |
| `duration_months` | Number              | One of 1, 3, 6, or 12                             |
| `valid_until`     | `YYYY-MM-DD` String | Duration-rule result snapshotted at save time     |
| `price_minor`     | Number              | Integer minor units; never a floating-point price |
| `currency`        | String              | EUR, GBP, RON, or USD                             |
| `created_at`      | Timestamp           | Set by the source                                 |
| `updated_at`      | Timestamp           | Set on every write                                |

Active/upcoming/expired status is derived at render time and is not persisted.
`valid_until` is inclusive. The 1-month option adds exactly 30 date-only days,
so 22.07.2026 becomes 21.08.2026 and initially shows 30 days remaining. The
3/6/12-month options use calendar-month arithmetic and clamp invalid target days.

All complete dates shown in the UI use `dd.MM.yyyy`. Stored date-only values
remain canonical `YYYY-MM-DD` strings.

## Top-Level Layout

```
Scaffold
  GymAppBar("Membership history")
  body
    PendingState → 3 card skeletons
    SomethingWentWrongState → ErrorStateWidget + retry
    Ready + empty → EmptyStateWidget + "Add first membership"
    Ready + data → PullToRefresh
      ListView
        MembershipHistoryCard × N (newest first)
  if Ready + data: PrimaryFab(+)
```

## History Card

Each card displays:

- credit-card emoji and gym name;
- start-date → valid-until range in `dd.MM.yyyy` format;
- formatted price and duration;
- derived badge: Upcoming, Expired, Expires today, or N days left;
- overflow menu: Renew, Edit, Delete.

Delete always uses `ConfirmationDialog` and permanently removes only the selected historical record.

## Add / Copy Flow

```
Tap FAB or arrive with `startAddFlow: true`
  ├── no existing history → open blank MembershipFormSheet
  └── history exists → ask:
      ├── Copy last details
        │     gym, duration, price, currency copied
        │     start date reset to today
        └── Start fresh
              blank form, start date today, 1 month,
              users/{uid}.currency (EUR fallback)
```

Tapping **Renew** on a specific card skips the choice dialog and copies that card directly. Saving always creates a new document; it never rewrites the source record.

The empty state already contains **Add first membership**, so the FAB is hidden
when history is empty. Calendar uses `startAddFlow: true`, which means tapping
the banner immediately opens the blank form when there is no history, or the
copy/start-fresh choice when an older period exists.

## Membership Form

Reusable control: `lib/presentation/controls/membership_form_sheet.dart`.

Fields:

1. Gym name — required.
2. Price — required, positive, max two fractional digits; parsed into minor units without floating-point arithmetic.
3. Currency — EUR / GBP / RON / USD.
4. Purchase/start date — defaults to today, can be changed, and displays as `dd.MM.yyyy`.
5. Validity — 1 / 3 / 6 / 12 months; 1 month is a fixed 30-day offset, while 3/6/12 use calendar months.
6. Read-only localized valid-until preview using `dd.MM.yyyy`.
7. `GradientButton` Save action.

The form contains local draft state only. Firestore loading, success, and errors remain Cubit-owned.

## Calendar Integration

Calendar requests `GymMembershipService.getRelevant()` through `CalendarCubit`.
The service prefers a currently active membership, then the nearest upcoming one,
then the latest expired record. `MembershipReminderService` adds a two-hour
new-account grace period and a permanent per-user dismissal stored in
`SharedPreferences`. Fetch failures never block Calendar.

## Status

✅ **IMPLEMENTED**
