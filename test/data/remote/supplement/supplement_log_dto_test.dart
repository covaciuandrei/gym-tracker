// Unit tests for SupplementLogDto ─ verifies JSON round-trip serialisation.
//
// What we test:
//   • fromJson  ─ snake_case keys, snapshot fields, default values
//   • toJson    ─ correct key names emitted
//   • id field  ─ excluded from both directions
//   • timestamp ─ typed as Object? so tests pass a plain String
//                 (prod code passes a Firestore Timestamp)

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/supplement/supplement_log_dto.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────────────────────────────
  group('SupplementLogDto.fromJson', () {
    test('maps all fields from a complete JSON map', () {
      final json = {
        'date': '2024-04-01',
        'product_id': 'prod_abc',
        'product_name': 'Whey Pro',
        'product_brand': 'ON',
        'servings_taken': 1.5,
        'timestamp': '2024-04-01T08:00:00Z',
      };

      final dto = SupplementLogDto.fromJson(json);

      expect(dto.date, '2024-04-01');
      expect(dto.productId, 'prod_abc');
      expect(dto.productName, 'Whey Pro');
      expect(dto.productBrand, 'ON');
      expect(dto.servingsTaken, 1.5);
      expect(dto.timestamp, '2024-04-01T08:00:00Z');
    });

    test('applies default empty string for missing date', () {
      final dto = SupplementLogDto.fromJson({'product_id': 'x', 'servings_taken': 1.0});
      expect(dto.date, '');
    });

    test('applies default empty string for missing product_id', () {
      final dto = SupplementLogDto.fromJson({'date': '2024-01-01', 'servings_taken': 1.0});
      expect(dto.productId, '');
    });

    test('applies default 1.0 for missing servings_taken', () {
      final dto = SupplementLogDto.fromJson({'date': '2024-01-01', 'product_id': 'x'});
      expect(dto.servingsTaken, 1.0);
    });

    test('snapshot fields default to null when absent', () {
      final dto = SupplementLogDto.fromJson({
        'date': '2024-01-01',
        'product_id': 'prod_xyz',
        'servings_taken': 1.0,
      });

      expect(dto.productName, isNull);
      expect(dto.productBrand, isNull);
      expect(dto.timestamp, isNull);
    });

    test('id is always empty after fromJson', () {
      final json = {
        'date': '2024-01-01',
        'product_id': 'x',
        'servings_taken': 1.0,
        'id': 'should-be-ignored',
      };
      final dto = SupplementLogDto.fromJson(json);
      expect(dto.id, '');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────────────────────
  group('SupplementLogDto.toJson', () {
    test('serialises all fields with correct snake_case keys', () {
      final dto = SupplementLogDto(
        date: '2024-04-01',
        productId: 'prod_abc',
        productName: 'Whey Pro',
        productBrand: 'ON',
        servingsTaken: 2.0,
        timestamp: '2024-04-01T08:00:00Z',
      );

      final json = dto.toJson();

      expect(json['date'], '2024-04-01');
      expect(json['product_id'], 'prod_abc');
      expect(json['product_name'], 'Whey Pro');
      expect(json['product_brand'], 'ON');
      expect(json['servings_taken'], 2.0);
      expect(json['timestamp'], '2024-04-01T08:00:00Z');
    });

    test('id is NOT present in toJson output', () {
      final dto = SupplementLogDto(
        date: '2024-01-01',
        productId: 'x',
        servingsTaken: 1.0,
        id: 'doc_999',
      );
      final json = dto.toJson();
      expect(json.containsKey('id'), isFalse);
    });

    test('null optional fields are emitted as null (not omitted)', () {
      final dto = SupplementLogDto(
        date: '2024-01-01',
        productId: 'x',
        servingsTaken: 1.0,
      );
      final json = dto.toJson();

      expect(json.containsKey('product_name'), isTrue);
      expect(json['product_name'], isNull);
      expect(json.containsKey('product_brand'), isTrue);
      expect(json['product_brand'], isNull);
      expect(json.containsKey('timestamp'), isTrue);
      expect(json['timestamp'], isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('SupplementLogDto round-trip', () {
    test('fromJson → toJson preserves all fields', () {
      final original = {
        'date': '2024-07-04',
        'product_id': 'prod_001',
        'product_name': 'Creatine',
        'product_brand': 'Creapure',
        'servings_taken': 1.0,
        'timestamp': '2024-07-04T07:00:00Z',
      };

      final json = SupplementLogDto.fromJson(original).toJson();

      expect(json['date'], original['date']);
      expect(json['product_id'], original['product_id']);
      expect(json['product_name'], original['product_name']);
      expect(json['product_brand'], original['product_brand']);
      expect(json['servings_taken'], original['servings_taken']);
      expect(json['timestamp'], original['timestamp']);
    });
  });
}
