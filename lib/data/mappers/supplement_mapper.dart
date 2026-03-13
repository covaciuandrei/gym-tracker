import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import 'package:gym_tracker/data/remote/supplement/product_ingredient_dto.dart';
import 'package:gym_tracker/data/remote/supplement/supplement_log_dto.dart';
import 'package:gym_tracker/data/remote/supplement/supplement_product_dto.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';

@injectable
class SupplementMapper {
  // ─── SupplementProduct ───────────────────────────────────────────────────

  SupplementProduct mapProductDto(SupplementProductDto dto) =>
      SupplementProduct(
        id: dto.id,
        name: dto.name,
        brand: dto.brand,
        ingredients: dto.ingredients.map(_mapIngredientDto).toList(),
        servingsPerDayDefault: dto.servingsPerDayDefault,
        createdBy: dto.createdBy,
        verified: dto.verified,
      );

  SupplementProductDto mapProductModel(SupplementProduct model) =>
      SupplementProductDto(
        id: model.id,
        name: model.name,
        brand: model.brand,
        ingredients: model.ingredients.map(_mapIngredientModel).toList(),
        servingsPerDayDefault: model.servingsPerDayDefault,
        createdBy: model.createdBy,
        verified: model.verified,
      );

  // ─── SupplementLog ───────────────────────────────────────────────────────

  SupplementLog mapLogDto(SupplementLogDto dto) => SupplementLog(
    id: dto.id,
    date: dto.date,
    productId: dto.productId,
    productName: dto.productName,
    productBrand: dto.productBrand,
    servingsTaken: dto.servingsTaken,
    timestamp: _toNullableDateTime(dto.timestamp),
  );

  SupplementLogDto mapLogModel(SupplementLog model) => SupplementLogDto(
    id: model.id,
    date: model.date,
    productId: model.productId,
    productName: model.productName,
    productBrand: model.productBrand,
    servingsTaken: model.servingsTaken,
    timestamp: model.timestamp == null
        ? null
        : Timestamp.fromDate(model.timestamp!),
  );

  // ─── Private ─────────────────────────────────────────────────────────────

  ProductIngredient _mapIngredientDto(ProductIngredientDto dto) =>
      ProductIngredient(
        stdId: dto.stdId,
        name: dto.name,
        amount: dto.amount,
        unit: dto.unit,
      );

  ProductIngredientDto _mapIngredientModel(ProductIngredient model) =>
      ProductIngredientDto(
        stdId: model.stdId,
        name: model.name,
        amount: model.amount,
        unit: model.unit,
      );

  DateTime? _toNullableDateTime(Object? raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw);
    if (raw is Map) {
      final seconds = raw['seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }
      if (seconds is num) {
        return DateTime.fromMillisecondsSinceEpoch((seconds * 1000).round());
      }
    }
    return null;
  }
}
