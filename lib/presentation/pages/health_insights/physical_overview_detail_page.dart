import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health_insights/physical_overview_detail_cubit.dart';
import 'package:gym_tracker/model/health_insights/comparison_mode.dart';
import 'package:gym_tracker/model/health_insights/comparison_row_data.dart';
import 'package:gym_tracker/model/health_insights/timeline_range.dart';
import 'package:gym_tracker/presentation/controls/error_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/option_toggle.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/comparison_rows_card.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/series_chart_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// The Physical Overview's own detail page \u2014 opened by tapping the card on
/// the main Health Insights page. Owns the population/past-you toggle that
/// used to live inline on the card: population mode shows a "you vs.
/// average" comparison (age/sex/height-adjusted); past-you mode shows the
/// weight + lean-mass monthly history as charts.
@RoutePage()
class PhysicalOverviewDetailPage extends StatefulWidget implements AutoRouteWrapper {
  const PhysicalOverviewDetailPage({super.key});

  @override
  State<PhysicalOverviewDetailPage> createState() => _PhysicalOverviewDetailPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PhysicalOverviewDetailCubit>(create: (_) => getIt<PhysicalOverviewDetailCubit>()..load(), child: this);
  }
}

class _PhysicalOverviewDetailPageState extends State<PhysicalOverviewDetailPage> {
  ComparisonMode _mode = ComparisonMode.population;
  TimelineRangeKind? _selectedKind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: GymAppBar(title: l10n.healthInsightsOverviewTitle),
      body: SafeArea(
        child: BlocBuilder<PhysicalOverviewDetailCubit, BaseState>(
          builder: (context, state) => _buildBody(context, l10n, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, BaseState state) {
    if (state is SomethingWentWrongState) {
      return ErrorStateWidget(
        message: l10n.healthInsightsLoadErrorMessage,
        onRetry: () => context.read<PhysicalOverviewDetailCubit>().load(),
      );
    }
    if (state is! PhysicalOverviewDetailReadyState) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: OptionToggle(
            selectedValue: _mode.name,
            items: [
              OptionToggleItem(value: ComparisonMode.population.name, label: l10n.healthInsightsComparePopulation),
              OptionToggleItem(value: ComparisonMode.pastSelf.name, label: l10n.healthInsightsCompareSelf),
            ],
            onSelect: (value) => setState(() => _mode = ComparisonMode.values.firstWhere((m) => m.name == value)),
          ),
        ),
        const SizedBox(height: 16),
        if (_mode == ComparisonMode.population) _buildPopulation(l10n, state) else _buildPastYou(l10n, state),
      ],
    );
  }

  Widget _buildPopulation(AppLocalizations l10n, PhysicalOverviewDetailReadyState state) {
    final comparison = state.comparison;
    if (comparison == null) {
      return ErrorStateWidget(emoji: Emojis.people, title: l10n.healthInsightsOverviewTitle, message: l10n.healthInsightsNoData);
    }

    return ComparisonRowsCard(
      headerText: l10n.healthInsightsPopulationCompareSubtitle(comparison.cohortLabel),
      rows: [
        ComparisonRowData(
          label: l10n.healthInsightsOverviewWeight,
          yourValue: comparison.yourWeightKg,
          averageValue: comparison.averageWeightKg,
          averageCaption: l10n.healthInsightsPopulationCompareAverage,
          unit: 'kg',
        ),
        if (comparison.yourBodyFatPercent != null && comparison.averageBodyFatPercent != null)
          ComparisonRowData(
            label: l10n.healthInsightsOverviewBodyFat,
            yourValue: comparison.yourBodyFatPercent!,
            averageValue: comparison.averageBodyFatPercent!,
            averageCaption: l10n.healthInsightsPopulationCompareAverage,
            unit: '%',
          ),
      ],
    );
  }

  Widget _buildPastYou(AppLocalizations l10n, PhysicalOverviewDetailReadyState state) {
    if (state.availableRanges.isEmpty) {
      return ErrorStateWidget(emoji: Emojis.chartIncreasing, title: l10n.healthInsightsOverviewTitle, message: l10n.healthInsightsNoData);
    }

    final range = state.availableRanges.firstWhere(
      (r) => r.kind == (_selectedKind ?? _preferredDefaultKind(state.availableRanges)),
      orElse: () => state.availableRanges.last,
    );
    final earliestMonth = _earliestMonth(state);
    final startDate = range.startDate(now: DateTime.now(), earliestDataDate: earliestMonth);
    final startMonth = DateTime(startDate.year, startDate.month);

    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in state.availableRanges)
              ChoiceChip(label: Text(r.label), selected: r.kind == range.kind, onSelected: (_) => setState(() => _selectedKind = r.kind)),
          ],
        ),
        const SizedBox(height: 16),
        SeriesChartCard(
          label: l10n.healthInsightsOverviewWeight,
          unit: 'kg',
          points: state.weightPoints.where((p) => !p.month.isBefore(startMonth)).toList(),
        ),
        if (state.leanMassPoints.isNotEmpty)
          SeriesChartCard(
            label: l10n.healthInsightsOverviewLeanMass,
            unit: 'kg',
            points: state.leanMassPoints.where((p) => !p.month.isBefore(startMonth)).toList(),
          ),
      ],
    );
  }

  TimelineRangeKind _preferredDefaultKind(List<TimelineRange> ranges) {
    const preferredOrder = [TimelineRangeKind.oneYear, TimelineRangeKind.sixMonths, TimelineRangeKind.ytd, TimelineRangeKind.threeMonths];
    for (final kind in preferredOrder) {
      if (ranges.any((r) => r.kind == kind)) return kind;
    }
    return ranges.last.kind;
  }

  DateTime _earliestMonth(PhysicalOverviewDetailReadyState state) {
    final points = [...state.weightPoints, ...state.leanMassPoints]..sort((a, b) => a.month.compareTo(b.month));
    return points.isEmpty ? DateTime.now() : points.first.month;
  }
}
