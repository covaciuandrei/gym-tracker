import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/health_insights/body_composition_trend.dart';
import 'package:gym_tracker/model/health_insights/cardio_fitness.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/heart_rate_recovery.dart';
import 'package:gym_tracker/model/health_insights/metabolic_estimate.dart';
import 'package:gym_tracker/model/health_insights/physical_overview.dart';

/// The full composed result of one Health Insights load: the physical
/// overview snapshot plus each of the five v1 insight cards.
///
/// Any card field is `null` when there isn't enough data to compute it
/// (e.g. no VO2Max readings at all) \u2014 the page renders that card's empty
/// state instead of hiding it, so users understand what's missing rather
/// than wondering why a card disappeared.
class HealthInsightsResult extends Equatable {
  const HealthInsightsResult({
    required this.overview,
    required this.comparisonMode,
    required this.comparisonWindow,
    this.bodyComposition,
    this.cardioFitness,
    this.heartRateRecovery,
    this.metabolic,
  });

  final PhysicalOverview overview;
  final ComparisonMode comparisonMode;
  final ComparisonWindow comparisonWindow;
  final BodyCompositionTrend? bodyComposition;
  final CardioFitness? cardioFitness;
  final HeartRateRecovery? heartRateRecovery;
  final MetabolicEstimate? metabolic;

  @override
  List<Object?> get props => [
    overview,
    comparisonMode,
    comparisonWindow,
    bodyComposition,
    cardioFitness,
    heartRateRecovery,
    metabolic,
  ];
}
