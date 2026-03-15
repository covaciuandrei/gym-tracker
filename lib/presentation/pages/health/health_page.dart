import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
import 'package:gym_tracker/presentation/controls/gym_tab_bar.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';
import 'package:gym_tracker/presentation/controls/primary_fab.dart';
import 'package:gym_tracker/presentation/controls/search_input.dart';
import 'package:gym_tracker/presentation/controls/summary_action_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

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

class _HealthPageState extends State<HealthPage> with SingleTickerProviderStateMixin {
  static const Duration _minimumSkeletonDuration = Duration(milliseconds: 300);

  final ValueNotifier<_HealthTab> _activeTab = ValueNotifier<_HealthTab>(_HealthTab.today);
  final ValueNotifier<String> _mySearch = ValueNotifier<String>('');
  final ValueNotifier<String> _allSearch = ValueNotifier<String>('');
  final TextEditingController _mySearchCtrl = TextEditingController();
  final TextEditingController _allSearchCtrl = TextEditingController();
  TabController? _tabController;

  List<SupplementLog> _latestTodayEntries = const <SupplementLog>[];
  List<SupplementProduct> _latestAllProducts = const <SupplementProduct>[];
  List<SupplementProduct> _latestMyProducts = const <SupplementProduct>[];

  bool _hasTodayData = false;
  bool _hasProductsData = false;
  bool _requestedTodayLoad = false;
  bool _requestedProductsLoad = false;
  bool _forceTodaySkeleton = false;
  bool _forceProductsSkeleton = false;
  int _todayLoadToken = 0;
  int _productsLoadToken = 0;
  DateTime? _todayLoadStartedAt;
  DateTime? _productsLoadStartedAt;
  Timer? _todaySkeletonTimer;
  Timer? _productsSkeletonTimer;

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
    _tabController = TabController(length: 3, vsync: this)..addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _todaySkeletonTimer?.cancel();
    _productsSkeletonTimer?.cancel();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    _activeTab.dispose();
    _mySearch.dispose();
    _allSearch.dispose();
    _mySearchCtrl.dispose();
    _allSearchCtrl.dispose();
    super.dispose();
  }

  _HealthTab _tabForIndex(int index) {
    switch (index) {
      case 0:
        return _HealthTab.today;
      case 1:
        return _HealthTab.mySupplements;
      case 2:
        return _HealthTab.allSupplements;
      default:
        return _HealthTab.today;
    }
  }

  void _onTabChanged() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) {
      return;
    }

    final nextTab = _tabForIndex(controller.index);
    if (_activeTab.value != nextTab) {
      _activeTab.value = nextTab;
    }
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
          _loadTodayEntries(userId);
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
        _loadProducts(userId);
      });
    }
  }

  void _loadTodayEntries(String userId) {
    _startTodaySkeletonWindow();
    context.read<HealthCubit>().loadDayEntries(userId: userId, date: _todayDateString);
  }

  void _loadProducts(String userId) {
    _startProductsSkeletonWindow();
    context.read<HealthCubit>().loadProducts(userId);
  }

  void _updateSkeletonFlags({bool? today, bool? products}) {
    if (!mounted) return;

    Null applyUpdate() {
      if (!mounted) return;
      setState(() {
        if (today != null) {
          _forceTodaySkeleton = today;
        }
        if (products != null) {
          _forceProductsSkeleton = products;
        }
      });
    }

    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => applyUpdate());
      return;
    }

    applyUpdate();
  }

  void _startTodaySkeletonWindow() {
    if (!mounted) return;
    _todaySkeletonTimer?.cancel();
    _todaySkeletonTimer = null;
    _todayLoadToken++;
    _todayLoadStartedAt = DateTime.now();
    _updateSkeletonFlags(today: true);
  }

  void _startProductsSkeletonWindow() {
    if (!mounted) return;
    _productsSkeletonTimer?.cancel();
    _productsSkeletonTimer = null;
    _productsLoadToken++;
    _productsLoadStartedAt = DateTime.now();
    _updateSkeletonFlags(products: true);
  }

  void _releaseTodaySkeletonWindow() {
    final startedAt = _todayLoadStartedAt;
    if (startedAt == null) {
      _todaySkeletonTimer?.cancel();
      _todaySkeletonTimer = null;
      if (mounted && _forceTodaySkeleton) {
        _updateSkeletonFlags(today: false);
      }
      return;
    }

    final token = _todayLoadToken;
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumSkeletonDuration - elapsed;
    if (remaining <= Duration.zero) {
      _todaySkeletonTimer?.cancel();
      _todaySkeletonTimer = null;
      if (mounted && _forceTodaySkeleton) {
        _updateSkeletonFlags(today: false);
      }
      return;
    }

    _todaySkeletonTimer?.cancel();
    _todaySkeletonTimer = Timer(remaining, () {
      if (!mounted || token != _todayLoadToken || !_forceTodaySkeleton) return;
      _updateSkeletonFlags(today: false);
      _todaySkeletonTimer = null;
    });
  }

  void _releaseProductsSkeletonWindow() {
    final startedAt = _productsLoadStartedAt;
    if (startedAt == null) {
      _productsSkeletonTimer?.cancel();
      _productsSkeletonTimer = null;
      if (mounted && _forceProductsSkeleton) {
        _updateSkeletonFlags(products: false);
      }
      return;
    }

    final token = _productsLoadToken;
    final elapsed = DateTime.now().difference(startedAt);
    final remaining = _minimumSkeletonDuration - elapsed;
    if (remaining <= Duration.zero) {
      _productsSkeletonTimer?.cancel();
      _productsSkeletonTimer = null;
      if (mounted && _forceProductsSkeleton) {
        _updateSkeletonFlags(products: false);
      }
      return;
    }

    _productsSkeletonTimer?.cancel();
    _productsSkeletonTimer = Timer(remaining, () {
      if (!mounted || token != _productsLoadToken || !_forceProductsSkeleton) return;
      _updateSkeletonFlags(products: false);
      _productsSkeletonTimer = null;
    });
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

  List<_GroupedTodayLogs> _groupedTodayLogs(List<SupplementLog> entries, String unknownLabel) {
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
        name: entry.productName ?? unknownLabel,
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
          _loadTodayEntries(userId);
          return;
        }
        if (state is HealthProductSavedState || state is HealthProductDeletedState) {
          _requestedProductsLoad = false;
          _loadProducts(userId);
          return;
        }
        if (state is SomethingWentWrongState) {
          _releaseTodaySkeletonWindow();
          _releaseProductsSkeletonWindow();
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        if (state is HealthDayEntriesLoadedState) {
          _releaseTodaySkeletonWindow();
          _hasTodayData = true;
          _requestedTodayLoad = false;
          _latestTodayEntries = state.entries;
        }
        if (state is HealthProductsLoadedState) {
          _releaseProductsSkeletonWindow();
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
                      GymTabBar(
                        controller: _tabController,
                        tabs: [l10n.healthToday, l10n.healthMySupplements, l10n.healthAllSupplements],
                        labelPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTodayTab(context, userId),
                            _buildProductsTab(
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
                            _buildProductsTab(
                              context,
                              searchController: _allSearchCtrl,
                              searchListenable: _allSearch,
                              searchHint: l10n.healthAllSearchHint,
                              emptyTitle: l10n.healthNoSupplementsFound,
                              emptyMessage: l10n.healthNoSupplementsFoundMessage,
                              onlyMine: false,
                              userId: userId,
                            ),
                          ],
                        ),
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

    if (!_hasTodayData || _forceTodaySkeleton) {
      return const _HealthTodaySkeleton();
    }

    final grouped = _groupedTodayLogs(_latestTodayEntries, l10n.healthUnknownProduct);
    if (grouped.isEmpty) {
      return EmptyStateWidget(
        emoji: Emojis.sunrise,
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
          description: l10n.healthServingCount(item.totalServings),
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

    if (!_hasProductsData || _forceProductsSkeleton) {
      return const _HealthProductsSkeleton();
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
                      emoji: Emojis.testTube,
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

class _HealthTodaySkeleton extends StatelessWidget {
  const _HealthTodaySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => const _HealthCardSkeleton(),
    );
  }
}

class _HealthProductsSkeleton extends StatelessWidget {
  const _HealthProductsSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Icon(Icons.search, size: 18),
                SizedBox(width: 8),
                Expanded(child: _HealthSkeletonBox(height: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const _HealthCardSkeleton(),
          ),
        ),
      ],
    );
  }
}

class _HealthCardSkeleton extends StatelessWidget {
  const _HealthCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(16)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HealthSkeletonBox(height: 12, width: 120),
          SizedBox(height: 10),
          _HealthSkeletonBox(height: 16, width: 180),
          SizedBox(height: 10),
          _HealthSkeletonBox(height: 12),
        ],
      ),
    );
  }
}

class _HealthSkeletonBox extends StatelessWidget {
  const _HealthSkeletonBox({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
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
