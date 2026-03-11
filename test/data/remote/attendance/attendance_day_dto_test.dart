// Unit tests for AttendanceDayDto ─ verifies JSON round-trip serialisation.
//
// What we test:
//   • fromJson  ─ JSON map → DTO (snake_case keys, default values)
//   • toJson    ─ DTO → JSON map (snake_case keys emitted)
//   • timestamp ─ typed as Object so tests can pass a plain String
//                 (prod code passes a Firestore Timestamp)
//   • optional fields default to null when absent

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_tracker/data/remote/attendance/attendance_day_dto.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // fromJson
  // ─────────────────────────────────────────────────────────────────────────
  group('AttendanceDayDto.fromJson', () {
    test('maps all fields from a complete JSON map', () {
      final json = {
        'date': '2024-03-10',
        'timestamp': '2024-03-10T09:00:00Z',
        'training_type_id': 'type_abc',
        'duration_minutes': 60,
        'notes': 'Great session',
      };

      final dto = AttendanceDayDto.fromJson(json);

      expect(dto.date, '2024-03-10');
      expect(dto.timestamp, '2024-03-10T09:00:00Z');
      expect(dto.trainingTypeId, 'type_abc');
      expect(dto.durationMinutes, 60);
      expect(dto.notes, 'Great session');
    });

    test('applies default empty string for missing date', () {
      final dto = AttendanceDayDto.fromJson({'timestamp': 'ts'});
      expect(dto.date, '');
    });

    test('optional fields default to null when absent', () {
      final dto = AttendanceDayDto.fromJson({
        'date': '2024-01-01',
        'timestamp': 'ts',
      });

      expect(dto.trainingTypeId, isNull);
      expect(dto.durationMinutes, isNull);
      expect(dto.notes, isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // toJson
  // ─────────────────────────────────────────────────────────────────────────
  group('AttendanceDayDto.toJson', () {
    test('serialises all fields with correct snake_case keys', () {
      final dto = AttendanceDayDto(
        date: '2024-03-10',
        timestamp: '2024-03-10T09:00:00Z',
        trainingTypeId: 'type_abc',
        durationMinutes: 45,
        notes: 'Rest day',
      );

      final json = dto.toJson();

      expect(json['date'], '2024-03-10');
      expect(json['timestamp'], '2024-03-10T09:00:00Z');
      expect(json['training_type_id'], 'type_abc');
      expect(json['duration_minutes'], 45);
      expect(json['notes'], 'Rest day');
    });

    test('emits null for absent optional fields', () {
      final dto = AttendanceDayDto(
        date: '2024-01-01',
        timestamp: 'ts',
      );
      final json = dto.toJson();

      expect(json['training_type_id'], isNull);
      expect(json['duration_minutes'], isNull);
      expect(json['notes'], isNull);
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // Round-trip
  // ─────────────────────────────────────────────────────────────────────────
  group('AttendanceDayDto round-trip', () {
    test('fromJson → toJson preserves all fields', () {
      final original = {
        'date': '2024-05-20',
        'timestamp': '2024-05-20T07:30:00Z',
        'training_type_id': 'type_xyz',
        'duration_minutes': 90,
        'notes': 'Heavy legs',
      };

      final json = AttendanceDayDto.fromJson(original).toJson();

      expect(json['date'], original['date']);
      expect(json['timestamp'], original['timestamp']);
      expect(json['training_type_id'], original['training_type_id']);
      expect(json['duration_minutes'], original['duration_minutes']);
      expect(json['notes'], original['notes']);
    });
  });
}
