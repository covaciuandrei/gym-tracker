import 'package:equatable/equatable.dart';
import 'package:gym_tracker/model/health_insights/stress_index.dart';
import 'package:gym_tracker/model/sex.dart';

/// The at-a-glance snapshot shown at the top of the Health Insights page.
///
/// Row 1 (shown whenever any data exists): weight / age / height \u2014 "now"
/// facts, no comparison logic.
/// Row 2 (only shown when [row2Visible] is true, i.e. there's a scale
/// reading \u2014 weight + lean mass \u2014 within the last 3 months): body fat %
/// and a stress index. Deliberately excludes a "body score" for now \u2014
/// planned for later once more inputs exist to make one meaningful.
///
/// Tapping the whole card opens `PhysicalOverviewDetailPage`, which owns the
/// population/past-you comparison itself (loaded fresh there) \u2014 this
/// snapshot intentionally carries no comparison state of its own.
class PhysicalOverview extends Equatable {
  const PhysicalOverview({
    required this.asOf,
    required this.heightCm,
    this.weightKg,
    this.age,
    this.sex,
    this.bodyFatPercent,
    this.stressIndex,
    this.row2Visible = false,
  });

  final DateTime asOf;
  final double heightCm;
  final double? weightKg;
  final int? age;
  final Sex? sex;

  final double? bodyFatPercent;
  final StressIndex? stressIndex;

  /// Whether row 2 (body fat % / stress index) should render at all \u2014
  /// gated on recency of the underlying scale/body-composition data.
  final bool row2Visible;

  @override
  List<Object?> get props => [asOf, heightCm, weightKg, age, sex, bodyFatPercent, stressIndex, row2Visible];
}


