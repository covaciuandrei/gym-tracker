import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/mappers/supplement_mapper.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'supplement_log_dto.dart';
import 'supplement_product_dto.dart';

@injectable
class HealthSource {
  const HealthSource(this._mapper);

  final SupplementMapper _mapper;

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  // ─── Supplement Products (global collection) ──────────────────────────────

  CollectionReference<SupplementProductDto> get _productsRef => _db
      .collection('supplementProducts')
      .withConverter<SupplementProductDto>(
        fromFirestore: (snap, _) {
          final dto = SupplementProductDto.fromJson(snap.data()!);
          return SupplementProductDto(
            id: snap.id,
            name: dto.name,
            brand: dto.brand,
            ingredients: dto.ingredients,
            servingsPerDayDefault: dto.servingsPerDayDefault,
            createdBy: dto.createdBy,
            verified: dto.verified,
          );
        },
        toFirestore: (dto, _) => dto.toJson(),
      );

  /// Streams all supplement products from the global catalog.
  Stream<List<SupplementProduct>> watchAllProducts() => _productsRef
      .orderBy('name')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => _mapper.mapProductDto(d.data())).toList());

  /// Streams supplement products created by [userId].
  Stream<List<SupplementProduct>> watchMyProducts(String userId) => _productsRef
      .where('created_by', isEqualTo: userId)
      .orderBy('name')
      .snapshots()
      .map((snap) =>
          snap.docs.map((d) => _mapper.mapProductDto(d.data())).toList());

  /// Returns a single supplement product by [productId].
  Future<SupplementProduct?> getProduct(String productId) async {
    final snap = await _productsRef.doc(productId).get();
    if (!snap.exists) return null;
    return _mapper.mapProductDto(snap.data()!);
  }

  /// Creates a new supplement product. Returns the generated document id.
  Future<String> createProduct(SupplementProduct model) async {
    final ref = await _productsRef.add(_mapper.mapProductModel(model));
    return ref.id;
  }

  /// Overwrites the supplement product identified by [model.id].
  Future<void> updateProduct(SupplementProduct model) =>
      _productsRef.doc(model.id).set(_mapper.mapProductModel(model));

  /// Deletes the supplement product identified by [productId].
  Future<void> deleteProduct(String productId) =>
      _productsRef.doc(productId).delete();

  // ─── Health Logs (per-user, per-month) ───────────────────────────────────

  /// Path:  users/{userId}/healthLogs/{yearMonth}/entries
  ///   yearMonth = "YYYY-MM"
  CollectionReference<SupplementLogDto> _entriesRef(
    String userId,
    String yearMonth,
  ) =>
      _db
          .collection('users')
          .doc(userId)
          .collection('healthLogs')
          .doc(yearMonth)
          .collection('entries')
          .withConverter<SupplementLogDto>(
            fromFirestore: (snap, _) {
              final dto = SupplementLogDto.fromJson(snap.data()!);
              return SupplementLogDto(
                id: snap.id,
                date: dto.date,
                productId: dto.productId,
                productName: dto.productName,
                productBrand: dto.productBrand,
                servingsTaken: dto.servingsTaken,
                timestamp: dto.timestamp,
              );
            },
            toFirestore: (dto, _) => dto.toJson(),
          );

  /// Streams all supplement log entries for a given [userId] and [yearMonth].
  Stream<List<SupplementLog>> watchMonthEntries(
    String userId,
    String yearMonth,
  ) =>
      _entriesRef(userId, yearMonth)
          .orderBy('date')
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => _mapper.mapLogDto(d.data())).toList());

  /// Streams all supplement log entries for a specific [date] ("YYYY-MM-DD").
  Stream<List<SupplementLog>> watchDayEntries(
    String userId,
    String yearMonth,
    String date,
  ) =>
      _entriesRef(userId, yearMonth)
          .where('date', isEqualTo: date)
          .snapshots()
          .map((snap) =>
              snap.docs.map((d) => _mapper.mapLogDto(d.data())).toList());

  /// Creates a new log entry. Returns the generated document id.
  Future<String> createEntry(
    String userId,
    String yearMonth,
    SupplementLog model,
  ) async {
    final ref = await _entriesRef(userId, yearMonth)
        .add(_mapper.mapLogModel(model));
    return ref.id;
  }

  /// Deletes a specific log entry by [entryId].
  Future<void> deleteEntry(
    String userId,
    String yearMonth,
    String entryId,
  ) =>
      _entriesRef(userId, yearMonth).doc(entryId).delete();
}
