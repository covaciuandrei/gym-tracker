// Unit tests for SupplementProductDto ─ verifies JSON round-trip serialisation.
//
// What we test:
//   • fromJson  ─ nested List<ProductIngredientDto>, snake_case keys, defaults
//   • toJson    ─ nested ingredients list serialised correctly
//   • id field  ─ excluded from both fromJson and toJson
//   • Optional fields (createdBy, verified) default to null

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/supplement/supplement_product_dto.dart';
import 'package:gym_tracker/data/remote/supplement/product_ingredient_dto.dart';

void main() {
  // Convenience fixture ─ a minimal valid ingredient JSON map
  Map<String, dynamic> ingredientJson({
    String stdId = 'prot',
    String name = 'Protein',
    double amount = 25.0,
    String unit = 'g',
  }) =>
      {'std_id': stdId, 'name': name, 'amount': amount, 'unit': unit};

  // ─────────────────────────────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────────────────────────────
  group('SupplementProductDto.fromJson', () {
    test('maps all fields from a complete JSON map', () {
      final json = {
        'name': 'Whey Pro',
        'brand': 'OptimumNutrition',
        'ingredients': [ingredientJson()],
        'servings_per_day_default': 2.0,
        'created_by': 'user_001',
        'verified': true,
      };

      final dto = SupplementProductDto.fromJson(json);

      expect(dto.name, 'Whey Pro');
      expect(dto.brand, 'OptimumNutrition');
      expect(dto.ingredients, hasLength(1));
      expect(dto.ingredients.first.stdId, 'prot');
      expect(dto.servingsPerDayDefault, 2.0);
      expect(dto.createdBy, 'user_001');
      expect(dto.verified, isTrue);
    });

    test('applies default 1.0 for missing servings_per_day_default', () {
      final dto = SupplementProductDto.fromJson({
        'name': 'Creatine',
        'brand': 'MyProtein',
        'ingredients': <dynamic>[],
      });
      expect(dto.servingsPerDayDefault, 1.0);
    });

    test('applies empty list for missing ingredients', () {
      final dto = SupplementProductDto.fromJson({
        'name': 'BCAA',
        'brand': 'Scitec',
        'servings_per_day_default': 3.0,
      });
      expect(dto.ingredients, isEmpty);
    });

    test('optional fields default to null when absent', () {
      final dto = SupplementProductDto.fromJson({
        'name': 'Zinc',
        'brand': 'NOW',
        'ingredients': <dynamic>[],
        'servings_per_day_default': 1.0,
      });

      expect(dto.createdBy, isNull);
      expect(dto.verified, isNull);
    });

    test('id is always empty after fromJson', () {
      final json = {
        'name': 'Test',
        'brand': 'Brand',
        'ingredients': <dynamic>[],
        'servings_per_day_default': 1.0,
        'id': 'should-be-ignored',
      };
      final dto = SupplementProductDto.fromJson(json);
      expect(dto.id, '');
    });

    test('deserialises multiple nested ingredients', () {
      final json = {
        'name': 'Multi-Vitamin',
        'brand': 'LifeExtension',
        'ingredients': [
          ingredientJson(stdId: 'vit_c', name: 'Vitamin C', amount: 500.0, unit: 'mg'),
          ingredientJson(stdId: 'vit_d', name: 'Vitamin D', amount: 1000.0, unit: 'IU'),
        ],
        'servings_per_day_default': 1.0,
      };

      final dto = SupplementProductDto.fromJson(json);

      expect(dto.ingredients, hasLength(2));
      expect(dto.ingredients[0].stdId, 'vit_c');
      expect(dto.ingredients[1].stdId, 'vit_d');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────────────────────
  group('SupplementProductDto.toJson', () {
    test('serialises all fields with correct keys', () {
      final dto = SupplementProductDto(
        name: 'Whey',
        brand: 'Gold Standard',
        ingredients: [
          ProductIngredientDto(
            stdId: 'prot',
            name: 'Protein',
            amount: 24.0,
            unit: 'g',
          ),
        ],
        servingsPerDayDefault: 1.0,
        createdBy: 'admin',
        verified: false,
      );

      final json = dto.toJson();

      expect(json['name'], 'Whey');
      expect(json['brand'], 'Gold Standard');
      expect(json['servings_per_day_default'], 1.0);
      expect(json['created_by'], 'admin');
      expect(json['verified'], isFalse);

      final ingredients = json['ingredients'] as List<dynamic>;
      expect(ingredients, hasLength(1));
      expect((ingredients.first as Map<String, dynamic>)['std_id'], 'prot');
    });

    test('id is NOT present in toJson output', () {
      final dto = SupplementProductDto(
        name: 'X',
        brand: 'Y',
        ingredients: [],
        servingsPerDayDefault: 1.0,
        id: 'doc_123',
      );
      final json = dto.toJson();
      expect(json.containsKey('id'), isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('SupplementProductDto round-trip', () {
    test('fromJson → toJson preserves top-level fields', () {
      final original = {
        'name': 'Casein',
        'brand': 'ON',
        'ingredients': [ingredientJson()],
        'servings_per_day_default': 1.0,
        'created_by': 'user_x',
        'verified': true,
      };

      final json = SupplementProductDto.fromJson(original).toJson();

      expect(json['name'], original['name']);
      expect(json['brand'], original['brand']);
      expect(json['servings_per_day_default'], original['servings_per_day_default']);
      expect(json['created_by'], original['created_by']);
      expect(json['verified'], original['verified']);
    });
  });
}
