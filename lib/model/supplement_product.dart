import 'package:equatable/equatable.dart';

/// A single supplement product ingredient entry.
class ProductIngredient extends Equatable {
  const ProductIngredient({
    required this.stdId,
    required this.name,
    required this.amount,
    required this.unit,
  });

  /// References an ingredient document id in the global `ingredients` collection.
  final String stdId;
  final String name;
  final double amount;
  final String unit;

  @override
  List<Object?> get props => [stdId, name, amount, unit];
}

/// A supplement product (stored in the global `supplementProducts` collection).
class SupplementProduct extends Equatable {
  const SupplementProduct({
    required this.id,
    required this.name,
    required this.brand,
    required this.ingredients,
    required this.servingsPerDayDefault,
    this.createdBy,
    this.verified,
  });

  final String id;
  final String name;
  final String brand;
  final List<ProductIngredient> ingredients;
  final double servingsPerDayDefault;

  /// The uid of the user who created this product, or null for global entries.
  final String? createdBy;
  final bool? verified;

  @override
  List<Object?> get props => [
        id,
        name,
        brand,
        ingredients,
        servingsPerDayDefault,
        createdBy,
        verified,
      ];
}
