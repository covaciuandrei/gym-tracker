import 'package:json_annotation/json_annotation.dart';

part 'supplement_log_dto.g.dart';

@JsonSerializable()
class SupplementLogDto {
  SupplementLogDto({
    required this.date,
    required this.productId,
    required this.servingsTaken,
    this.id = '',
    this.productName,
    this.productBrand,
    this.timestamp,
  });

  factory SupplementLogDto.fromJson(Map<String, dynamic> json) =>
      _$SupplementLogDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SupplementLogDtoToJson(this);

  /// Document id — excluded from Firestore fields (comes from doc.id).
  @JsonKey(includeFromJson: false, includeToJson: false, defaultValue: '')
  final String id;

  /// Date string in format "YYYY-MM-DD".
  @JsonKey(name: 'date', defaultValue: '')
  final String date;

  @JsonKey(name: 'product_id', defaultValue: '')
  final String productId;

  /// Snapshot of product name at time of logging.
  @JsonKey(name: 'product_name')
  final String? productName;

  /// Snapshot of product brand at time of logging.
  @JsonKey(name: 'product_brand')
  final String? productBrand;

  @JsonKey(name: 'servings_taken', defaultValue: 1.0)
  final double servingsTaken;

  /// Stored as a Firestore Timestamp; serialized as ISO-8601 String in unit tests.
  @JsonKey(name: 'timestamp')
  final Object? timestamp;
}
