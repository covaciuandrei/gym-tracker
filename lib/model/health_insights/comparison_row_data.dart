import 'package:equatable/equatable.dart';

/// One row in a "you vs. a reference value" comparison card \u2014 shared by
/// the Heart Rate Recovery detail page and the Physical Overview detail
/// page's population-mode content.
class ComparisonRowData extends Equatable {
  const ComparisonRowData({
    required this.label,
    required this.yourValue,
    required this.averageValue,
    required this.averageCaption,
    this.unit = '',
  });

  final String label;
  final double yourValue;

  /// The reference figure shown in the second column \u2014 not always a
  /// literal population average (see [averageCaption]).
  final double averageValue;

  /// Describes what [averageValue] represents, e.g. "Average \u00b7 Men, 20-29"
  /// or "Healthy reference" \u2014 shown as the second column's caption instead
  /// of a generic "Average" label whenever the reference isn't a true
  /// population average (e.g. Heart Rate Recovery's clinical cutoff).
  final String averageCaption;

  final String unit;

  @override
  List<Object?> get props => [label, yourValue, averageValue, averageCaption, unit];
}
