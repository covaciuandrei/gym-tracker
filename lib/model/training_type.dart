import 'package:equatable/equatable.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

class TrainingType extends Equatable {
  const TrainingType({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
  });

  final String id;
  final String name;

  /// Hex color string, e.g. "#FF5733"
  final String color;

  /// Emoji icon, e.g. Emojis.biceps
  final String? icon;

  @override
  List<Object?> get props => [id, name, color, icon];
}
