import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/supplement/health_source.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';

part 'health_service_exceptions.dart';

@injectable
class HealthService {
  const HealthService(this._source);

  final HealthSource _source;

  /// Returns the "YYYY-MM" key for [year] and [month].
  static String yearMonthKey(int year, int month) =>
      '$year-${month.toString().padLeft(2, '0')}';

  // ─── Supplement Products ──────────────────────────────────────────────────

  /// Streams the full global supplement product catalog, ordered by name.
  Stream<List<SupplementProduct>> watchAllProducts() =>
      _source.watchAllProducts();

  /// Streams only products created by [userId].
  Stream<List<SupplementProduct>> watchMyProducts(String userId) =>
      _source.watchMyProducts(userId);

  /// Returns a single [SupplementProduct] by [productId], or null.
  Future<SupplementProduct?> getProduct(String productId) =>
      _source.getProduct(productId);

  /// Creates a new supplement product. Returns the generated document id.
  Future<String> createProduct(SupplementProduct model) =>
      _source.createProduct(model);

  /// Updates a supplement product.
  /// Throws [SupplementProductNotFoundException] if it does not exist.
  Future<void> updateProduct(SupplementProduct model) async {
    final existing = await _source.getProduct(model.id);
    if (existing == null) throw const SupplementProductNotFoundException();
    return _source.updateProduct(model);
  }

  /// Deletes a supplement product by [productId].
  Future<void> deleteProduct(String productId) =>
      _source.deleteProduct(productId);

  // ─── Health Log Entries ───────────────────────────────────────────────────

  /// Streams all supplement log entries for [userId] in a given month.
  Stream<List<SupplementLog>> watchMonthEntries({
    required String userId,
    required int year,
    required int month,
  }) =>
      _source.watchMonthEntries(userId, yearMonthKey(year, month));

  /// Streams all supplement log entries for a specific [date] ("YYYY-MM-DD").
  Stream<List<SupplementLog>> watchDayEntries({
    required String userId,
    required String date,
  }) {
    final yearMonth = date.substring(0, 7);
    return _source.watchDayEntries(userId, yearMonth, date);
  }

  /// Creates a new log entry. Returns the generated document id.
  Future<String> logSupplement({
    required String userId,
    required SupplementLog model,
  }) {
    final yearMonth = model.date.substring(0, 7);
    return _source.createEntry(userId, yearMonth, model);
  }

  /// Deletes a specific log entry by [entryId] and [date] (to derive yearMonth).
  Future<void> deleteEntry({
    required String userId,
    required String date,
    required String entryId,
  }) {
    final yearMonth = date.substring(0, 7);
    return _source.deleteEntry(userId, yearMonth, entryId);
  }
}
