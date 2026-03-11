# Health Page — Prep Notes

## Route
`/health` (child of MainShell, tab index 2)

## Angular Source
`src/app/features/health/`

## Top-Level Layout
```
Scaffold
  Column
    ── Tab bar ──
    TabBar(
      tabs: [Tab(text: 'Today'), Tab(text: 'My Supplements'), Tab(text: 'All Supplements')],
      labelColor: cs.primary,
      indicatorColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
    )
    ── Tab content ──
    Expanded(TabBarView([...]))

  ── FAB (visible on All Supplements tab) ──
  FloatingActionButton(
    onPressed: _openSupplementForm,
    child: Icon(Icons.add),
    backgroundColor: cs.primary,
  )
```

---

## Tab 0 — Today
Shows supplement logs recorded for today, grouped by product.

```
if (todayLogs.isEmpty):
  Center
    Column
      Text('💊', fontSize: 48)
      SizedBox(height: 16)
      Text('No supplements logged today', style: tt.bodyLarge, color: cs.onSurfaceVariant)
else:
  ListView
    for each group (by product):
      Card(padding: 16, margin: h16+v8)
        Row(crossAxisAlignment: start)
          ── Product icon / initial ──
          CircleAvatar(radius: 20, child: Text(product.name[0].toUpperCase()))
          SizedBox(width: 12)
          ── Info ──
          Expanded(Column)
            Text(product.name, style: tt.titleMedium)
            Text(product.brand, style: tt.bodySmall, color: cs.onSurfaceVariant)
            SizedBox(height: 4)
            Text('$totalServings serving(s)', style: tt.bodySmall)
            ── Individual log times ──
            for each log:
              Row(spaceBetween)
                Text(log.time formatted 'HH:mm', style: tt.bodySmall, color: cs.onSurfaceVariant)
                IconButton(Icons.delete_outline, size: 20,
                           color: cs.error, onPressed: () => _deleteEntry(log.id))
```

---

## Tab 1 — My Supplements
User's own created products. Searchable.

```
Column
  ── Search field ──
  Padding(h16, v8)
    TextField(
      decoration: InputDecoration(
        hintText: 'Search supplements...',
        prefixIcon: Icon(Icons.search),
        suffixIcon: query.isNotEmpty ? IconButton(Icons.clear) : null,
      )
    )

  if (filtered.isEmpty):
    Center
      Column
        Text('🧪', fontSize: 48)
        Text('No supplements found', style: tt.bodyLarge)
        if (allProductsEmpty):
          SizedBox(height: 16)
          PrimaryButton('Create Your First Supplement', onPressed: _openForm)
  else:
    ListView
      for each product:
        ListTile(
          leading: CircleAvatar(child: Text(product.name[0])),
          title: Text(product.name, style: tt.titleMedium),
          subtitle: Text(product.brand, style: tt.bodySmall),
          trailing: Row [
            IconButton(Icons.delete_outline, color: cs.error, onPressed: () => _deleteProduct(product.id))
          ],
          onTap: () => _openEditForm(product),
        )
```

---

## Tab 2 — All Supplements
Global catalog (all users' products + seeded products). Searchable.
Tapping logs a supplement for today.

```
Column
  ── Search field (same as tab 1) ──

  ListView
    for each product in filteredAll:
      ListTile(
        leading: CircleAvatar(child: Text(product.name[0])),
        title: Text(product.name, style: tt.titleMedium),
        subtitle: Text(product.brand, style: tt.bodySmall),
        onTap: () => _quickLog(product.id),   // logs for today
      )
```
FAB on this tab: → opens `SupplementForm` to create new product.

---

## SupplementForm (bottom sheet, used for create + edit)

### Title
- Create: "Add Supplement"
- Edit: "Edit Supplement"

### Layout
```
DraggableScrollableSheet or showModalBottomSheet(isScrollControlled: true)
  Column
    ── Handle bar ──
    Center(Container(w40, h4, color: cs.outline, borderRadius: 2))
    SizedBox(height: 16)
    Text(title, style: tt.headlineMedium)
    SizedBox(height: 24)

    CustomTextField(label: 'Name')
    SizedBox(height: 16)
    CustomTextField(label: 'Brand')
    SizedBox(height: 24)

    ── Ingredients section ──
    Text('Ingredients', style: tt.titleMedium)
    SizedBox(height: 8)
    Row
      Expanded(TextField(hintText: 'Search ingredients by name...'))
      SizedBox(width: 8)
      ── results dropdown below ──

    ── Ingredient results list (when searching) ──
    ListView(shrinkWrap)
      for each result:
        ListTile(
          title: Text(ingredient.name),
          trailing: IconButton(Icons.add),
          onTap: () → _showAddIngredientDialog(ingredient),
        )

    SizedBox(height: 16)
    ── Added ingredients ──
    if (ingredients.isEmpty):
      Text('No ingredients added yet.', color: cs.onSurfaceVariant, style: tt.bodySmall)
    else:
      for each ingredient:
        Row(spaceBetween)
          Column
            Text(ingredient.name, style: tt.bodyMedium)
            Text('$amount $unit', style: tt.bodySmall, color: cs.onSurfaceVariant)
          IconButton(Icons.remove_circle_outline, color: cs.error)

    SizedBox(height: 32)
    Row
      Expanded(OutlinedButton('Cancel', onPressed: () => Navigator.pop(context)))
      SizedBox(width: 12)
      Expanded(PrimaryButton(createMode ? 'Add Supplement' : 'Save Supplement'))
```

### Add Ingredient Dialog
```
AlertDialog
  title: Text(ingredient.name)
  content: Column
    TextField(label: 'Amount', type: number)
    SizedBox(height: 8)
    DropdownButton(label: 'Unit', items: ['g','mg','mcg','ml','IU','%'])
  actions: [Cancel, Add]
```

---

## Cubit Methods Used
```dart
// HealthCubit:
healthCubit.loadDayEntries(date: today);         // Tab 0
healthCubit.deleteEntry(entryId);                // Tab 0 delete log
healthCubit.loadProducts();                      // Tabs 1 + 2
healthCubit.addProduct(name, brand, ingredients);  // SupplementForm create
healthCubit.updateProduct(id, name, brand, ingredients); // SupplementForm edit
healthCubit.deleteProduct(id);                   // Tab 1 delete
healthCubit.logSupplement(productId);            // Tab 2 quick log
```

## HealthCubit States
| State | Trigger | UI Response |
|---|---|---|
| `PendingState` | any load | spinner in tab content |
| `HealthDayLoadedState(entries)` | loadDayEntries | render Today tab |
| `HealthProductsLoadedState(mine, all)` | loadProducts | render tabs 1 + 2 |
| `SomethingWentWrongState` | error | snackbar |
| `HealthEntryLoggedState` | logSupplement | reload day entries |
| `HealthProductSavedState` | add/update | close form, reload |

## Colors / Styles
- CircleAvatar: `cs.primaryContainer` background, `cs.onPrimaryContainer` text
- Delete icon: `cs.error`
- Search field: standard `InputDecoration.filled`
- Ingredient amount: `cs.primary`

## Navigation In/Out
- IN: MainShell tab 2
- OUT: no navigation; supplement form is in-page modal bottom sheet
