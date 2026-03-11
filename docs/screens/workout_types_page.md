# Workout Types Page — Prep Notes

## Route
`/workout-types` (pushed from ProfilePage, full-screen, NOT inside MainShell)

## Angular Source
`src/app/features/workouts/workout-types/`

## Layout

### Loading state
```
Scaffold
  AppBar(...)
  Center → Column
    CircularProgressIndicator(color: cs.primary)
    SizedBox(height: 16)
    Text('Loading workout types...', style: tt.bodyLarge, color: cs.onSurfaceVariant)
```

### Empty state
```
Scaffold
  AppBar(...)
  Center → Column
    Text('🏋️', fontSize: 64)
    SizedBox(height: 16)
    Text('No Workout Types Yet', style: tt.headlineMedium)
    SizedBox(height: 8)
    Text('Create custom workout types to categorize your sessions',
         style: tt.bodyMedium, color: cs.onSurfaceVariant, textAlign: center)
    SizedBox(height: 24)
    PrimaryButton('Create Your First Type', onPressed: _openCreateModal)
  FAB: FloatingActionButton(onPressed: _openCreateModal, child: Icon(Icons.add))
```

### Loaded state (list)
```
Scaffold
  AppBar(
    leading: BackButton
    title: Text('Workout Types', style: tt.titleLarge)
    actions: [IconButton(Icons.add, onPressed: _openCreateModal)]
  )
  ListView.builder
    for each workoutType:
      Card(elevation: 0, color: cs.surfaceContainerHigh, margin: h16+v4, borderRadius: 12)
        ListTile(
          leading: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Color(workoutType.colorHex).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            )
            child: Center(Text(workoutType.icon, style: TextStyle(fontSize: 24)))
          )
          title: Text(workoutType.name, style: tt.titleMedium)
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: cs.error)
            onPressed: () => _showDeleteConfirm(workoutType)
          )
          onTap: () => _openEditModal(workoutType)
        )
  FAB: FloatingActionButton(
    onPressed: _openCreateModal,
    child: Icon(Icons.add),
    backgroundColor: cs.primary,
  )
```

---

## Create / Edit Modal (showModalBottomSheet)
```
DraggableScrollableSheet(initialChildSize: 0.85, maxChildSize: 0.95)
  Column
    ── Handle ──
    Center(Container(w40, h4, color: cs.outline, borderRadius: 2))
    SizedBox(height: 16)
    ── Title ──
    Padding(h24) Text(editMode ? 'Edit Workout Type' : 'New Workout Type', style: tt.headlineMedium)
    SizedBox(height: 24)

    ── Name field ──
    Padding(h24)
      CustomTextField(
        label: 'Name',
        maxLength: 30,
        onChanged: (v) => setState(() => name = v),
      )
    SizedBox(height: 24)

    ── Icon picker ──
    Padding(h24) Text('Icon', style: tt.titleMedium)
    SizedBox(height: 8)
    GridView(
      crossAxisCount: 5, mainAxisSpacing: 8, crossAxisSpacing: 8,
      padding: h24,
      children: icons.map((icon) =>
        GestureDetector(
          onTap: () => setState(() => selectedIcon = icon),
          child: Container(
            decoration: BoxDecoration(
              color: selectedIcon == icon ? cs.primaryContainer : cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: selectedIcon == icon ? Border.all(cs.primary, width: 2) : null,
            )
            child: Center(Text(icon, style: TextStyle(fontSize: 28)))
          )
        )
      ),
    )
    SizedBox(height: 24)

    ── Color picker ──
    Padding(h24) Text('Color', style: tt.titleMedium)
    SizedBox(height: 8)
    Wrap(spacing: 12, runSpacing: 12, padding: h24)
      for each color in presetColors:
        GestureDetector(
          onTap: () => setState(() => selectedColor = color),
          child: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Color(color),
              shape: BoxShape.circle,
              border: selectedColor == color ? Border.all(cs.onSurface, width: 2) : null,
            )
            child: selectedColor == color
              ? Icon(Icons.check, color: Colors.white, size: 18)
              : null
          )
        )
    SizedBox(height: 24)

    ── Live preview ──
    Padding(h24) Text('Preview', style: tt.titleMedium)
    SizedBox(height: 8)
    Padding(h24)
      Card(elevation: 0, color: cs.surfaceContainerHigh, borderRadius: 12)
        ListTile(
          leading: Container(
            w44, h44,
            decoration: BoxDecoration(
              color: Color(selectedColor).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            )
            child: Center(Text(selectedIcon, fontSize: 24))
          )
          title: Text(name.isEmpty ? 'Workout Type Name' : name, style: tt.titleMedium)
        )
    SizedBox(height: 32)

    ── Action buttons ──
    Padding(h24)
      Row
        Expanded(OutlinedButton('Cancel', onPressed: () => Navigator.pop(context)))
        SizedBox(width: 12)
        Expanded(PrimaryButton(
          label: editMode ? 'Save' : 'Create',
          onPressed: name.trim().isEmpty ? null : _onSubmit,
          isLoading: state is PendingState,
        ))
    SizedBox(height: 24)
```

---

## Delete Confirmation Dialog
```
showDialog → AlertDialog(
  title: Text('Delete Workout Type?', style: tt.headlineSmall),
  content: RichText(
    text: TextSpan(children: [
      TextSpan(text: 'Delete ', style: tt.bodyMedium.copyWith(color: cs.onSurface)),
      TextSpan(text: workoutType.name, style: tt.bodyMedium.copyWith(fontWeight: w700)),
      TextSpan(text: '? This action cannot be undone.', style: tt.bodyMedium.copyWith(color: cs.onSurface)),
    ])
  )
  actions: [
    TextButton('Cancel', onPressed: Navigator.pop)
    TextButton(
      'Delete',
      style: TextButton.styleFrom(foregroundColor: cs.error),
      onPressed: () { Navigator.pop(context); _deleteType(workoutType.id); }
    )
  ]
)
```

---

## Available Icons (15)
`['🏋️', '🏃', '🚴', '🤸', '🥊', '⚽', '🏊', '🧘', '🏌️', '🎾', '🏀', '🏈', '⛷️', '🤼', '🚣']`

## Preset Colors
| Label | Hex |
|---|---|
| Purple | `#8B5CF6` |
| Blue | `#3B82F6` |
| Green | `#10B981` |
| Yellow | `#F59E0B` |
| Red | `#EF4444` |
| Pink | `#EC4899` |
| Teal | `#06B6D4` |
| Orange | `#F97316` |

## Cubit Methods Used
```dart
// WorkoutCubit:
workoutCubit.loadTypes();
workoutCubit.addType(name: name, icon: icon, colorHex: color);
workoutCubit.updateType(id: id, name: name, icon: icon, colorHex: color);
workoutCubit.deleteType(id);
```

## WorkoutCubit States
| State | UI Response |
|---|---|
| `PendingState` | spinner / button loading |
| `WorkoutTypesLoadedState(types)` | render list or empty state |
| `WorkoutTypeAddedState` | close modal, reload |
| `WorkoutTypeUpdatedState` | close modal, reload |
| `WorkoutTypeDeletedState` | reload list |
| `SomethingWentWrongState` | error snackbar |

## Colors / Styles
- Icon tile background: `Color(hex).withOpacity(0.2)`, borderRadius: 10
- Selected icon cell: `cs.primaryContainer`, border: `cs.primary`
- Selected color circle: border `cs.onSurface`, width 2, checkmark white
- Delete button: `cs.error`
- Modal handle: `cs.outline`

## Navigation In/Out
- IN: from `ProfilePage` (push)
- OUT: back to Profile (pop / AppBar back button)
