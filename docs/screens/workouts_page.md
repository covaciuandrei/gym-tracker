# Workouts Page — Screen Doc

> Last updated: 2026-05-11

## Route

`/app/workouts` (child of MainShell, tab index 1)

## Source

`lib/presentation/pages/workouts/workouts_page.dart`

## Purpose

Container tab for workout-related features. Currently exposes a single
"Manage workout types" entry that pushes the existing `WorkoutTypesPage`.
Reserved as the future home for additional workout features (sessions,
templates, plans, etc.).

## Page Setup

- `@RoutePage()` annotation
- `StatelessWidget` (no providers — pushed feature owns its cubit)

## Visual Layout

```
Scaffold(backgroundColor: cs.surfaceContainerLow)
  appBar: GymAppBar(title: l10n.workoutsTitle, showBackButton: false)
  SafeArea
    SingleChildScrollView(padding: h16+v16)
      Center → ConstrainedBox(maxWidth: 600)
        Card(surfaceContainerHigh, borderRadius: 16, elevation: 0)
          ListTile(
            leading: Icon(Icons.fitness_center, color: cs.primary),
            title: Text(l10n.workoutsManageTypes),
            trailing: Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            onTap: () => context.router.push(WorkoutTypesRoute()),
          )
```

## Localization Keys

- `workoutsTitle` — "Workouts" / "Antrenamente"
- `workoutsManageTypes` — "Manage workout types" / "Gestionează tipurile de antrenament"
- `navWorkouts` — bottom-nav label

## Controls Used

- `GymAppBar`

## Navigation In/Out

- IN: MainShell tab 1
- OUT: → `WorkoutTypesRoute` (push)

## Status

✅ **IMPLEMENTED**
