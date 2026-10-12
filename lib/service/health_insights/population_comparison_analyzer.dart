import 'package:gym_tracker/model/health_insights/population_physical_comparison.dart';
import 'package:gym_tracker/model/sex.dart';
import 'package:gym_tracker/service/health_insights/population_norms.dart';
import 'package:injectable/injectable.dart';

/// Builds a simple "you vs. an average person of your sex, age, and height"
/// physical comparison, shown on the Physical Overview detail page in
/// population mode.
///
/// Delegates to [PopulationNorms] for both reference values so this never
/// disagrees with the average figures shown elsewhere in Health Insights
/// (e.g. the Body Recomposition card's own population benchmark).
@injectable
class PopulationComparisonAnalyzer {
  const PopulationComparisonAnalyzer(this._norms);

  final PopulationNorms _norms;

  PopulationPhysicalComparison? build({
    required double? weightKg,
    required double? heightCm,
    required int? age,
    required Sex? sex,
    double? bodyFatPercent,
  }) {
    if (weightKg == null || heightCm == null || age == null) return null;

    final effectiveSex = sex ?? Sex.male;
    final averageWeightKg = _norms.averageWeightKg(heightCm: heightCm, age: age, sex: effectiveSex);
    final sexLabel = effectiveSex == Sex.female ? 'Women' : 'Men';
    final decade = (age ~/ 10) * 10;
    final cohortLabel = '$sexLabel, $decade\u2013${decade + 9}';

    return PopulationPhysicalComparison(
      yourWeightKg: weightKg,
      averageWeightKg: averageWeightKg,
      heightCm: heightCm,
      cohortLabel: cohortLabel,
      yourBodyFatPercent: bodyFatPercent,
      averageBodyFatPercent: bodyFatPercent != null ? _norms.averageBodyFatPercent(sex: effectiveSex) : null,
    );
  }
}

