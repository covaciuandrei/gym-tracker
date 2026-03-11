// Unit tests for ProductIngredientDto ─ verifies JSON round-trip serialisation.
//
// What we test:
//   • fromJson  ─ JSON map → DTO (std_id snake_case key, numeric defaults)
//   • toJson    ─ DTO → JSON map
//   • Round-trip consistency

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/supplement/product_ingredient_dto.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────────────────────────────
  group('ProductIngredientDto.fromJson', () {
    test('maps all fields from a complete JSON map', () {
      final json = {
        'std_id': 'vit_c',
        'name': 'Vitamin C',
        'amount': 1000.0,
        'unit': 'mg',
      };

      final dto = ProductIngredientDto.fromJson(json);

      expect(dto.stdId, 'vit_c');
      expect(dto.name, 'Vitamin C');
      expect(dto.amount, 1000.0);
      expect(dto.unit, 'mg');
    });

    test('applies default empty string for missing std_id', () {
      final dto = ProductIngredientDto.fromJson({
        'name': 'Zinc',
        'amount': 15.0,
        'unit': 'mg',
      });
      expect(dto.stdId, '');
    });

    test('applies default 0.0 for missing amount', () {
      final dto = ProductIngredientDto.fromJson({
        'std_id': 'zn',
        'name': 'Zinc',
        'unit': 'mg',
      });
      expect(dto.amount, 0.0);
    });

    test('applies default empty string for missing unit', () {
      final dto = ProductIngredientDto.fromJson({
        'std_id': 'zn',
        'name': 'Zinc',
        'amount': 15.0,
      });
      expect(dto.unit, '');
    });

    test('handles integer amount (JSON numbers can be int or double)', () {
      final json = {
        'std_id': 'prot',
        'name': 'Protein',
        'amount': 25,
        'unit': 'g',
      };
      final dto = ProductIngredientDto.fromJson(json);
      // json_serializable converts int to double for double fields
      expect(dto.amount, 25.0);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────────────────────
  group('ProductIngredientDto.toJson', () {
    test('serialises all fields with correct keys', () {
      final dto = ProductIngredientDto(
        stdId: 'vit_d',
        name: 'Vitamin D3',
        amount: 2000.0,
        unit: 'IU',
      );

      final json = dto.toJson();

      expect(json['std_id'], 'vit_d');
      expect(json['name'], 'Vitamin D3');
      expect(json['amount'], 2000.0);
      expect(json['unit'], 'IU');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('ProductIngredientDto round-trip', () {
    test('fromJson → toJson preserves all fields', () {
      final original = {
        'std_id': 'mg',
        'name': 'Magnesium',
        'amount': 400.0,
        'unit': 'mg',
      };

      final json = ProductIngredientDto.fromJson(original).toJson();

      expect(json['std_id'], original['std_id']);
      expect(json['name'], original['name']);
      expect(json['amount'], original['amount']);
      expect(json['unit'], original['unit']);
    });
  });
}
