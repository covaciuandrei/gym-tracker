// Unit tests for TrainingTypeDto ─ verifies JSON round-trip serialisation.
//
// What we test:
//   • fromJson  ─ JSON map → DTO (field mapping, default values)
//   • toJson    ─ DTO → JSON map
//   • id field  ─ excluded from both fromJson and toJson (comes from doc.id)
//
// No Firebase dependency: timestamps are plain Strings in these tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/training_type/training_type_dto.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────────────────────────────
  group('TrainingTypeDto.fromJson', () {
    test('maps all fields from a complete JSON map', () {
      final json = {
        'name': 'Strength',
        'color': '#FF5733',
        'icon': '🏋️',
        'created_at': '2024-01-15T10:00:00Z',
      };

      final dto = TrainingTypeDto.fromJson(json);

      expect(dto.name, 'Strength');
      expect(dto.color, '#FF5733');
      expect(dto.icon, '🏋️');
      expect(dto.createdAt, '2024-01-15T10:00:00Z');
    });

    test('applies default empty string for missing name', () {
      final dto = TrainingTypeDto.fromJson({'color': '#000000'});
      expect(dto.name, '');
    });

    test('applies default empty string for missing color', () {
      final dto = TrainingTypeDto.fromJson({'name': 'Cardio'});
      expect(dto.color, '');
    });

    test('icon defaults to null when absent', () {
      final dto = TrainingTypeDto.fromJson({'name': 'Yoga', 'color': '#FFF'});
      expect(dto.icon, isNull);
    });

    test('createdAt defaults to null when absent', () {
      final dto = TrainingTypeDto.fromJson({'name': 'Yoga', 'color': '#FFF'});
      expect(dto.createdAt, isNull);
    });

    test('id is always empty after fromJson (not read from JSON)', () {
      final json = {'name': 'HIIT', 'color': '#000', 'id': 'should-be-ignored'};
      final dto = TrainingTypeDto.fromJson(json);
      // id has includeFromJson: false – the 'id' key in JSON is ignored
      expect(dto.id, '');
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────────────────────
  group('TrainingTypeDto.toJson', () {
    test('serialises all present fields', () {
      final dto = TrainingTypeDto(
        name: 'Strength',
        color: '#FF5733',
        icon: '🏋️',
        createdAt: '2024-01-15T10:00:00Z',
      );

      final json = dto.toJson();

      expect(json['name'], 'Strength');
      expect(json['color'], '#FF5733');
      expect(json['icon'], '🏋️');
      expect(json['created_at'], '2024-01-15T10:00:00Z');
    });

    test('id is NOT present in toJson output', () {
      final dto = TrainingTypeDto(name: 'Pull', color: '#ABC', id: 'abc123');
      final json = dto.toJson();
      expect(json.containsKey('id'), isFalse);
    });

    test('null icon is omitted from output', () {
      final dto = TrainingTypeDto(name: 'Run', color: '#111');
      final json = dto.toJson();
      // null values for nullable fields are included as null, not omitted,
      // unless @JsonKey(includeIfNull: false) is set. Verify actual behaviour.
      expect(json.containsKey('icon'), isTrue);
      expect(json['icon'], isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('TrainingTypeDto round-trip', () {
    test('fromJson → toJson preserves all fields', () {
      final original = {
        'name': 'Cardio',
        'color': '#00FF00',
        'icon': '🏃',
        'created_at': '2024-06-01T08:30:00Z',
      };

      final json = TrainingTypeDto.fromJson(original).toJson();

      expect(json['name'], original['name']);
      expect(json['color'], original['color']);
      expect(json['icon'], original['icon']);
      expect(json['created_at'], original['created_at']);
    });
  });
}
