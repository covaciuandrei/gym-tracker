import 'dart:async';

import 'package:injectable/injectable.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/service/health/health_service.dart';

part 'health_states.dart';

@injectable
class HealthCubit extends BaseCubit {
  HealthCubit(this._healthService);

  final HealthService _healthService;

  StreamSubscription<List<SupplementLog>>? _dayEntriesSubscription;
  StreamSubscription<List<SupplementLog>>? _monthEntriesSubscription;
  StreamSubscription<List<SupplementProduct>>? _productsSubscription;

  /// Subscribes to supplement log entries for [date] ("YYYY-MM-DD") and emits
  /// [HealthDayEntriesLoadedState] on every update.
  void loadDayEntries({required String userId, required String date}) {
    _dayEntriesSubscription?.cancel();
    safeEmit(const PendingState());
    _dayEntriesSubscription = _healthService
        .watchDayEntries(userId: userId, date: date)
        .listen(
          (entries) => safeEmit(
            HealthDayEntriesLoadedState(entries: entries, date: date),
          ),
          onError: (_) => safeEmit(const SomethingWentWrongState()),
        );
  }

  /// Subscribes to supplement log entries for the given [year]/[month] and emits
  /// [HealthMonthEntriesLoadedState] on every update.
  void loadMonthEntries({
    required String userId,
    required int year,
    required int month,
  }) {
    _monthEntriesSubscription?.cancel();
    safeEmit(const PendingState());
    _monthEntriesSubscription = _healthService
        .watchMonthEntries(userId: userId, year: year, month: month)
        .listen(
          (entries) =>
              safeEmit(HealthMonthEntriesLoadedState(entries: entries)),
          onError: (_) => safeEmit(const SomethingWentWrongState()),
        );
  }

  /// Subscribes to the global supplement product catalog and emits
  /// [HealthProductsLoadedState] on every update.
  void loadProducts(String userId) {
    _productsSubscription?.cancel();
    safeEmit(const PendingState());
    _productsSubscription = _healthService.watchAllProducts().listen((
      products,
    ) {
      final myProducts = products
          .where((product) => product.createdBy == userId)
          .toList(growable: false);
      safeEmit(
        HealthProductsLoadedState(products: products, myProducts: myProducts),
      );
    }, onError: (_) => safeEmit(const SomethingWentWrongState()));
  }

  Future<void> saveProduct({
    required String userId,
    required SupplementProduct model,
    required bool isEdit,
  }) async {
    safeEmit(const PendingState());
    try {
      if (isEdit) {
        await _healthService.updateProduct(model);
        safeEmit(HealthProductSavedState(id: model.id));
        return;
      }

      final id = await _healthService.createProduct(
        SupplementProduct(
          id: '',
          name: model.name,
          brand: model.brand,
          ingredients: model.ingredients,
          servingsPerDayDefault: model.servingsPerDayDefault,
          createdBy: userId,
          verified: model.verified,
        ),
      );
      safeEmit(HealthProductSavedState(id: id));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  Future<void> deleteProduct(String productId) async {
    safeEmit(const PendingState());
    try {
      await _healthService.deleteProduct(productId);
      safeEmit(const HealthProductDeletedState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Logs a supplement entry and emits [HealthEntryLoggedState] with the
  /// generated document id.
  Future<void> logSupplement({
    required String userId,
    required SupplementLog model,
  }) async {
    safeEmit(const PendingState());
    try {
      final id = await _healthService.logSupplement(
        userId: userId,
        model: model,
      );
      safeEmit(HealthEntryLoggedState(id: id));
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  /// Deletes the supplement log entry identified by [entryId] and [date].
  Future<void> deleteEntry({
    required String userId,
    required String date,
    required String entryId,
  }) async {
    safeEmit(const PendingState());
    try {
      await _healthService.deleteEntry(
        userId: userId,
        date: date,
        entryId: entryId,
      );
      safeEmit(const HealthEntryDeletedState());
    } catch (_) {
      safeEmit(const SomethingWentWrongState());
    }
  }

  @override
  Future<void> close() async {
    await _dayEntriesSubscription?.cancel();
    await _monthEntriesSubscription?.cancel();
    await _productsSubscription?.cancel();
    return super.close();
  }
}
