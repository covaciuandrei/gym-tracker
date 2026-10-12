import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health_insights/metric_timeline_cubit.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline.dart';
import 'package:gym_tracker/model/health_insights/metric_timeline_spec.dart';
import 'package:gym_tracker/model/health_insights/timeline_range.dart';
import 'package:gym_tracker/presentation/controls/error_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/series_chart_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Generic monthly-history detail page shared by every "tap a card to see
/// its chart" entry point in Health Insights: currently Body Recomposition
/// (weight + derived body-fat %) and Cardio Fitness (VO2Max).
///
/// Shows a range selector (only the ranges the available data can actually
/// support \u2014 see `MetricTimelineBuilder.availableRanges`) and one
/// always-visible chart card per requested series.
@RoutePage()
class MetricTimelinePage extends StatefulWidget implements AutoRouteWrapper {
  const MetricTimelinePage({super.key, required this.title, required this.emoji, required this.specs, this.derivedBodyFatLabel});

  final String title;
  final String emoji;
  final List<MetricTimelineSeriesSpec> specs;

  /// When provided, an extra series is added: derived monthly body-fat %
  /// (weight + lean mass paired per month) \u2014 used by Body Recomposition.
  final String? derivedBodyFatLabel;

  @override
  State<MetricTimelinePage> createState() => _MetricTimelinePageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<MetricTimelineCubit>(
      create: (_) => getIt<MetricTimelineCubit>()..load(specs: specs, derivedBodyFatLabel: derivedBodyFatLabel),
      child: this,
    );
  }
}

class _MetricTimelinePageState extends State<MetricTimelinePage> {
  TimelineRangeKind? _selectedKind;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: GymAppBar(title: widget.title),
      body: SafeArea(
        child: BlocBuilder<MetricTimelineCubit, BaseState>(
          builder: (context, state) => _buildBody(context, l10n, state),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, BaseState state) {
    if (state is SomethingWentWrongState) {
      return ErrorStateWidget(
        message: l10n.healthInsightsLoadErrorMessage,
        onRetry: () => context.read<MetricTimelineCubit>().load(specs: widget.specs, derivedBodyFatLabel: widget.derivedBodyFatLabel),
      );
    }
    if (state is! MetricTimelineReadyState) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.availableRanges.isEmpty) {
      return ErrorStateWidget(emoji: Emojis.chartIncreasing, title: widget.title, message: l10n.healthInsightsNoData);
    }

    final range = state.availableRanges.firstWhere(
      (r) => r.kind == (_selectedKind ?? _preferredDefaultKind(state.availableRanges)),
      orElse: () => state.availableRanges.last,
    );
    final earliestMonth = _earliestMonth(state.series);
    final startDate = range.startDate(now: DateTime.now(), earliestDataDate: earliestMonth);
    final startMonth = DateTime(startDate.year, startDate.month);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
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
        for (final series in state.series)
          SeriesChartCard(
            label: series.label,
            unit: series.unit,
            points: series.monthlyPoints.where((p) => !p.month.isBefore(startMonth)).toList(),
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

  DateTime _earliestMonth(List<MetricSeriesData> series) {
    DateTime? earliest;
    for (final s in series) {
      if (s.monthlyPoints.isEmpty) continue;
      final first = s.monthlyPoints.first.month;
      if (earliest == null || first.isBefore(earliest)) earliest = first;
    }
    return earliest ?? DateTime.now();
  }
}
