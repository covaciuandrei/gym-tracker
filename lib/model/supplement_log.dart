import 'package:equatable/equatable.dart';

/// A single supplement log entry.
///
/// Stored in Firestore at:
///   users/{userId}/healthLogs/{yearMonth}/entries/{logId}
/// where yearMonth = "YYYY-MM".
class SupplementLog extends Equatable {
  const SupplementLog({
    required this.id,
    required this.date,
    required this.productId,
    required this.servingsTaken,
    this.productName,
    this.productBrand,
    this.timestamp,
  });

  /// Firestore document id (auto-generated).
  final String id;

  /// Date string in format "YYYY-MM-DD".
  final String date;

  /// References a [SupplementProduct] id in the global `supplementProducts` collection.
  final String productId;

  /// Snapshot of the product name at time of logging.
  final String? productName;

  /// Snapshot of the product brand at time of logging.
  final String? productBrand;

  final double servingsTaken;

  final DateTime? timestamp;

  @override
  List<Object?> get props => [
        id,
        date,
        productId,
        productName,
        productBrand,
        servingsTaken,
        timestamp,
      ];
}
