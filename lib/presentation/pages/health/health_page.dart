import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health/health_cubit.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/presentation/controls/action_bottom_sheet.dart';
import 'package:gym_tracker/presentation/controls/confirmation_dialog.dart';
import 'package:gym_tracker/presentation/controls/empty_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/option_toggle.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';
import 'package:gym_tracker/presentation/controls/primary_fab.dart';
import 'package:gym_tracker/presentation/controls/search_input.dart';
import 'package:gym_tracker/presentation/controls/summary_action_card.dart';

@RoutePage()
class HealthPage extends StatefulWidget implements AutoRouteWrapper {
  const HealthPage({super.key, this.testUserId});

  final String? testUserId;

  @override
  State<HealthPage> createState() => _HealthPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<HealthCubit>(create: (_) => getIt<HealthCubit>(), child: this);
  }
}

enum _HealthTab { today, mySupplements, allSupplements }

class _HealthPageState extends State<HealthPage> {
  final ValueNotifier<_HealthTab> _activeTab = ValueNotifier<_HealthTab>(_HealthTab.today);
  final ValueNotifier<String> _mySearch = ValueNotifier<String>('');
  final ValueNotifier<String> _allSearch = ValueNotifier<String>('');
  final TextEditingController _mySearchCtrl = TextEditingController();
  final TextEditingController _allSearchCtrl = TextEditingController();

  List<SupplementLog> _latestTodayEntries = const <SupplementLog>[];
  List<SupplementProduct> _latestAllProducts = const <SupplementProduct>[];
  List<SupplementProduct> _latestMyProducts = const <SupplementProduct>[];

  bool _hasTodayData = false;
  bool _hasProductsData = false;
  bool _requestedTodayLoad = false;
  bool _requestedProductsLoad = false;

  String? get _userId => widget.testUserId ?? FirebaseAuth.instance.currentUser?.uid;

  String get _todayDateString {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = _userId;
      if (userId == null) return;
      final cubit = context.read<HealthCubit>();
      cubit.loadProducts(userId);
      cubit.loadDayEntries(userId: userId, date: _todayDateString);
    });
  }

  @override
  void dispose() {
    _activeTab.dispose();
    _mySearch.dispose();
    _allSearch.dispose();
    _mySearchCtrl.dispose();
    _allSearchCtrl.dispose();
    super.dispose();
  }

  void _ensureActiveTabData(String userId, _HealthTab activeTab) {
    if (activeTab == _HealthTab.today) {
      if (_hasTodayData) {
        return;
      }
      if (!_requestedTodayLoad) {
        _requestedTodayLoad = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          context.read<HealthCubit>().loadDayEntries(userId: userId, date: _todayDateString);
        });
      }
      return;
    }

    if (_hasProductsData) {
      return;
    }
    if (!_requestedProductsLoad) {
      _requestedProductsLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<HealthCubit>().loadProducts(userId);
      });
    }
  }

  Future<void> _openProductForm(String userId, {SupplementProduct? initial}) async {
    final l10n = AppLocalizations.of(context);
    final draft = await showModalBottomSheet<_SupplementProductDraft>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SupplementFormSheet(initial: initial),
    );
    if (draft == null) return;

    final isEdit = initial != null;
    await context.read<HealthCubit>().saveProduct(
      userId: userId,
      isEdit: isEdit,
      model: SupplementProduct(
        id: initial?.id ?? '',
        name: draft.name,
        brand: draft.brand,
        ingredients: draft.ingredients,
        servingsPerDayDefault: draft.servingsPerDayDefault,
        createdBy: initial?.createdBy ?? userId,
        verified: initial?.verified,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(isEdit ? l10n.healthProductUpdated : l10n.healthProductCreated)));
  }

  Future<void> _deleteProduct(SupplementProduct product) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await ConfirmationDialog.show(
      context,
      title: l10n.healthDeleteSupplementTitle,
      message: '${l10n.healthDelete} "${product.name}"? ${l10n.healthDeleteWarning}',
      cancelLabel: l10n.workoutTypesCancel,
      confirmLabel: l10n.healthDelete,
    );
    if (!shouldDelete) return;

    await context.read<HealthCubit>().deleteProduct(product.id);
  }

  Future<void> _deleteEntry(String userId, SupplementLog entry) async {
    final l10n = AppLocalizations.of(context);
    final shouldDelete = await ConfirmationDialog.show(
      context,
      title: l10n.healthDeleteLogTitle,
      message: l10n.healthDeleteLogMessage,
      cancelLabel: l10n.workoutTypesCancel,
      confirmLabel: l10n.healthDelete,
    );
    if (!shouldDelete) return;

    await context.read<HealthCubit>().deleteEntry(userId: userId, date: entry.date, entryId: entry.id);
  }

  Future<void> _quickLog(String userId, SupplementProduct product) async {
    await context.read<HealthCubit>().logSupplement(
      userId: userId,
      model: SupplementLog(
        id: '',
        date: _todayDateString,
        productId: product.id,
        productName: product.name,
        productBrand: product.brand,
        servingsTaken: product.servingsPerDayDefault <= 0 ? 1 : product.servingsPerDayDefault,
        timestamp: DateTime.now(),
      ),
    );
  }

  List<SupplementProduct> _applyQuery(List<SupplementProduct> products, String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return products;

    return products
        .where((product) {
          final name = product.name.toLowerCase();
          final brand = product.brand.toLowerCase();
          return name.contains(normalized) || brand.contains(normalized);
        })
        .toList(growable: false);
  }

  String _timeLabel(BuildContext context, SupplementLog log) {
    final timestamp = log.timestamp;
    if (timestamp == null) return '--:--';
    final tod = TimeOfDay(hour: timestamp.hour, minute: timestamp.minute);
    return MaterialLocalizations.of(context).formatTimeOfDay(tod);
  }

  List<_GroupedTodayLogs> _groupedTodayLogs(List<SupplementLog> entries) {
    final map = <String, _GroupedTodayLogs>{};

    for (final entry in entries) {
      if (map.containsKey(entry.productId)) {
        final existing = map[entry.productId];
        if (existing == null) continue;
        map[entry.productId] = existing.copyWith(
          totalServings: existing.totalServings + entry.servingsTaken,
          entries: [...existing.entries, entry],
        );
        continue;
      }

      map[entry.productId] = _GroupedTodayLogs(
        productId: entry.productId,
        name: entry.productName ?? 'Unknown',
        brand: entry.productBrand ?? '',
        totalServings: entry.servingsTaken,
        entries: [entry],
      );
    }

    return map.values.toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.replace(const LoginRoute());
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<HealthCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is HealthEntryLoggedState ||
          curr is HealthEntryDeletedState ||
          curr is HealthProductSavedState ||
          curr is HealthProductDeletedState ||
          curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is HealthEntryLoggedState || state is HealthEntryDeletedState) {
          _requestedTodayLoad = false;
          ctx.read<HealthCubit>().loadDayEntries(userId: userId, date: _todayDateString);
          return;
        }
        if (state is HealthProductSavedState || state is HealthProductDeletedState) {
          _requestedProductsLoad = false;
          ctx.read<HealthCubit>().loadProducts(userId);
          return;
        }
        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        if (state is HealthDayEntriesLoadedState) {
          _hasTodayData = true;
          _requestedTodayLoad = false;
          _latestTodayEntries = state.entries;
        }
        if (state is HealthProductsLoadedState) {
          _hasProductsData = true;
          _requestedProductsLoad = false;
          _latestAllProducts = state.products;
          _latestMyProducts = state.myProducts;
        }

        return ValueListenableBuilder<_HealthTab>(
          valueListenable: _activeTab,
          builder: (_, activeTab, _) {
            _ensureActiveTabData(userId, activeTab);

            final showFab = activeTab == _HealthTab.mySupplements || activeTab == _HealthTab.allSupplements;

            return Scaffold(
              backgroundColor: cs.surfaceContainerLow,
              appBar: GymAppBar(title: l10n.healthTitle, showBackButton: false),
              floatingActionButton: showFab ? PrimaryFab(onPressed: () => _openProductForm(userId)) : null,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OptionToggle(
                        selectedValue: activeTab.name,
                        items: [
                          OptionToggleItem(value: _HealthTab.today.name, label: l10n.healthToday),
                          OptionToggleItem(value: _HealthTab.mySupplements.name, label: l10n.healthMySupplements),
                          OptionToggleItem(value: _HealthTab.allSupplements.name, label: l10n.healthAllSupplements),
                        ],
                        onSelect: (value) {
                          _activeTab.value = _HealthTab.values.firstWhere(
                            (tab) => tab.name == value,
                            orElse: () => _HealthTab.today,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: switch (activeTab) {
                          _HealthTab.today => _buildTodayTab(context, userId),
                          _HealthTab.mySupplements => _buildProductsTab(
                            context,
                            searchController: _mySearchCtrl,
                            searchListenable: _mySearch,
                            searchHint: l10n.healthMySearchHint,
                            emptyTitle: l10n.healthNoPersonalSupplements,
                            emptyMessage: l10n.healthNoPersonalSupplementsMessage,
                            emptyActionLabel: l10n.healthAddSupplement,
                            onEmptyAction: () => _openProductForm(userId),
                            onlyMine: true,
                            userId: userId,
                          ),
                          _HealthTab.allSupplements => _buildProductsTab(
                            context,
                            searchController: _allSearchCtrl,
                            searchListenable: _allSearch,
                            searchHint: l10n.healthAllSearchHint,
                            emptyTitle: l10n.healthNoSupplementsFound,
                            emptyMessage: l10n.healthNoSupplementsFoundMessage,
                            onlyMine: false,
                            userId: userId,
                          ),
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodayTab(BuildContext context, String userId) {
    final l10n = AppLocalizations.of(context);

    if (!_hasTodayData) {
      return const Center(child: CircularProgressIndicator());
    }

    final grouped = _groupedTodayLogs(_latestTodayEntries);
    if (grouped.isEmpty) {
      return EmptyStateWidget(
        emoji: '🌅',
        title: l10n.healthNoSupplementsToday,
        message: l10n.healthNoSupplementsTodayMessage,
      );
    }

    return ListView.separated(
      itemCount: grouped.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final item = grouped[index];
        return SummaryActionCard(
          subtitle: item.brand,
          title: item.name,
          description:
              '${item.totalServings.toStringAsFixed(item.totalServings % 1 == 0 ? 0 : 1)} ${l10n.healthServings}',
          actions: item.entries
              .map(
                (entry) => ActionChip(
                  label: Text(_timeLabel(context, entry)),
                  avatar: const Icon(Icons.delete_outline, size: 16),
                  onPressed: () => _deleteEntry(userId, entry),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  Widget _buildProductsTab(
    BuildContext context, {
    required TextEditingController searchController,
    required ValueNotifier<String> searchListenable,
    required String searchHint,
    required String emptyTitle,
    required String emptyMessage,
    String? emptyActionLabel,
    VoidCallback? onEmptyAction,
    required bool onlyMine,
    required String userId,
  }) {
    final l10n = AppLocalizations.of(context);

    if (!_hasProductsData) {
      return const Center(child: CircularProgressIndicator());
    }

    final baseProducts = onlyMine ? _latestMyProducts : _latestAllProducts;

    return ValueListenableBuilder<String>(
      valueListenable: searchListenable,
      builder: (_, query, _) {
        final products = _applyQuery(baseProducts, query);
        return Column(
          children: [
            SearchInput(
              controller: searchController,
              hint: searchHint,
              onChanged: (value) => searchListenable.value = value,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: products.isEmpty
                  ? EmptyStateWidget(
                      emoji: '🧪',
                      title: emptyTitle,
                      message: emptyMessage,
                      actionLabel: emptyActionLabel,
                      onAction: onEmptyAction,
                    )
                  : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        final product = products[index];
                        final description = product.ingredients.isEmpty
                            ? '-'
                            : product.ingredients
                                  .take(3)
                                  .map((ing) => '${ing.amount}${ing.unit} ${ing.name}')
                                  .join(', ');

                        final actions = <Widget>[];
                        if (product.createdBy == userId) {
                          actions.add(
                            TextButton.icon(
                              onPressed: () => _openProductForm(userId, initial: product),
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(l10n.healthEditAction),
                            ),
                          );
                          actions.add(
                            TextButton.icon(
                              onPressed: () => _deleteProduct(product),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(l10n.healthDelete),
                            ),
                          );
                        }

                        return SummaryActionCard(
                          subtitle: product.brand,
                          title: product.name,
                          description: description,
                          actions: actions,
                          onTap: onlyMine ? null : () => _quickLog(userId, product),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _SupplementFormSheet extends StatefulWidget {
  const _SupplementFormSheet({this.initial});

  final SupplementProduct? initial;

  @override
  State<_SupplementFormSheet> createState() => _SupplementFormSheetState();
}

class _SupplementFormSheetState extends State<_SupplementFormSheet> {
  TextEditingController? _nameCtrl;
  TextEditingController? _brandCtrl;
  TextEditingController? _servingsCtrl;
  ValueNotifier<String>? _nameValue;
  TextEditingController? _ingredientNameCtrl;
  TextEditingController? _ingredientAmountCtrl;
  ValueNotifier<String>? _ingredientUnit;
  ValueNotifier<List<ProductIngredient>>? _ingredients;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _nameCtrl = TextEditingController(text: initial?.name ?? '');
    _brandCtrl = TextEditingController(text: initial?.brand ?? '');
    _servingsCtrl = TextEditingController(text: (initial?.servingsPerDayDefault ?? 1).toString());
    _nameValue = ValueNotifier<String>(initial?.name ?? '');
    _ingredientNameCtrl = TextEditingController();
    _ingredientAmountCtrl = TextEditingController();
    _ingredientUnit = ValueNotifier<String>('mg');
    _ingredients = ValueNotifier<List<ProductIngredient>>(initial?.ingredients ?? <ProductIngredient>[]);
  }

  @override
  void dispose() {
    _nameCtrl?.dispose();
    _brandCtrl?.dispose();
    _servingsCtrl?.dispose();
    _nameValue?.dispose();
    _ingredientNameCtrl?.dispose();
    _ingredientAmountCtrl?.dispose();
    _ingredientUnit?.dispose();
    _ingredients?.dispose();
    super.dispose();
  }

  String _slug(String input) {
    final normalized = input.trim().toLowerCase();
    final keep = normalized.replaceAll(RegExp(r'[^a-z0-9\s]'), '').replaceAll(RegExp(r'\s+'), '_');
    return keep.isEmpty ? 'custom_ingredient' : keep;
  }

  void _addIngredient() {
    final nameCtrl = _ingredientNameCtrl;
    final amountCtrl = _ingredientAmountCtrl;
    final unit = _ingredientUnit;
    final ingredients = _ingredients;
    if (nameCtrl == null || amountCtrl == null || unit == null || ingredients == null) {
      return;
    }

    final name = nameCtrl.text.trim();
    final amount = double.tryParse(amountCtrl.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) {
      return;
    }

    ingredients.value = [
      ...ingredients.value,
      ProductIngredient(stdId: _slug(name), name: name, amount: amount, unit: unit.value),
    ];
    nameCtrl.clear();
    amountCtrl.clear();
  }

  void _removeIngredient(ProductIngredient ingredient) {
    final ingredients = _ingredients;
    if (ingredients == null) return;
    ingredients.value = ingredients.value.where((item) => item != ingredient).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;

    final nameCtrl = _nameCtrl;
    final brandCtrl = _brandCtrl;
    final servingsCtrl = _servingsCtrl;
    final nameValue = _nameValue;
    final ingredientNameCtrl = _ingredientNameCtrl;
    final ingredientAmountCtrl = _ingredientAmountCtrl;
    final ingredientUnit = _ingredientUnit;
    final ingredients = _ingredients;

    if (nameCtrl == null ||
        brandCtrl == null ||
        servingsCtrl == null ||
        nameValue == null ||
        ingredientNameCtrl == null ||
        ingredientAmountCtrl == null ||
        ingredientUnit == null ||
        ingredients == null) {
      return const SizedBox.shrink();
    }

    final isEdit = widget.initial != null;
    return ActionBottomSheet(
      title: isEdit ? l10n.healthEditSupplement : l10n.healthAddSupplement,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.healthProductName, style: tt.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: nameCtrl, onChanged: (value) => nameValue.value = value),
          const SizedBox(height: 16),
          Text(l10n.healthBrand, style: tt.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: brandCtrl),
          const SizedBox(height: 16),
          Text(l10n.healthServingsPerDay, style: tt.titleMedium),
          const SizedBox(height: 8),
          TextField(controller: servingsCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: 24),
          Text(l10n.healthIngredients, style: tt.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ingredientNameCtrl,
                  decoration: InputDecoration(hintText: l10n.healthIngredientName),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 96,
                child: TextField(
                  controller: ingredientAmountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(hintText: l10n.healthAmount),
                ),
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<String>(
                valueListenable: ingredientUnit,
                builder: (_, unit, _) {
                  return DropdownButton<String>(
                    value: unit,
                    items: const ['mg', 'mcg', 'g', 'IU', 'ml']
                        .map((value) => DropdownMenuItem<String>(value: value, child: Text(value)))
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) return;
                      ingredientUnit.value = value;
                    },
                  );
                },
              ),
              IconButton(onPressed: _addIngredient, icon: const Icon(Icons.add_circle_outline)),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<ProductIngredient>>(
            valueListenable: ingredients,
            builder: (_, values, _) {
              if (values.isEmpty) {
                return Text(l10n.healthNoIngredientsYet, style: tt.bodySmall);
              }
              return Column(
                children: values
                    .map(
                      (ingredient) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(ingredient.name),
                        subtitle: Text('${ingredient.amount} ${ingredient.unit}'),
                        trailing: IconButton(
                          onPressed: () => _removeIngredient(ingredient),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                      ),
                    )
                    .toList(growable: false),
              );
            },
          ),
        ],
      ),
      footer: Row(
        children: [
          Expanded(
            child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.workoutTypesCancel)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<List<ProductIngredient>>(
              valueListenable: ingredients,
              builder: (_, values, _) {
                return ValueListenableBuilder<String>(
                  valueListenable: nameValue,
                  builder: (_, currentName, _) {
                    final name = currentName.trim();
                    return PrimaryButton(
                      label: isEdit ? l10n.healthSave : l10n.healthAddSupplement,
                      isLoading: false,
                      onPressed: name.isEmpty || values.isEmpty
                          ? null
                          : () {
                              final servings = double.tryParse(servingsCtrl.text.trim()) ?? 1;
                              Navigator.of(context).pop(
                                _SupplementProductDraft(
                                  name: name,
                                  brand: brandCtrl.text.trim(),
                                  ingredients: values,
                                  servingsPerDayDefault: servings <= 0 ? 1 : servings,
                                ),
                              );
                            },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplementProductDraft {
  const _SupplementProductDraft({
    required this.name,
    required this.brand,
    required this.ingredients,
    required this.servingsPerDayDefault,
  });

  final String name;
  final String brand;
  final List<ProductIngredient> ingredients;
  final double servingsPerDayDefault;
}

class _GroupedTodayLogs {
  const _GroupedTodayLogs({
    required this.productId,
    required this.name,
    required this.brand,
    required this.totalServings,
    required this.entries,
  });

  final String productId;
  final String name;
  final String brand;
  final double totalServings;
  final List<SupplementLog> entries;

  _GroupedTodayLogs copyWith({double? totalServings, List<SupplementLog>? entries}) {
    return _GroupedTodayLogs(
      productId: productId,
      name: name,
      brand: brand,
      totalServings: totalServings ?? this.totalServings,
      entries: entries ?? this.entries,
    );
  }
}
