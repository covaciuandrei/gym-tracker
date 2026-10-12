import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:gym_tracker/model/health_insights/comparison_row_data.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/comparison_rows_card.dart';

/// Generic "you vs. a reference value" detail page \u2014 used by Heart Rate
/// Recovery (your HRR vs. the Cole et al. 1999 healthy-recovery reference).
///
/// Deliberately simple: no chart, no range selector, no chips \u2014 just the
/// comparison itself, since this entry point neither has a well-verified
/// age-banded population table nor benefits from a monthly trend view the
/// way body composition / cardio fitness do.
@RoutePage()
class TwoColumnComparisonPage extends StatelessWidget {
  const TwoColumnComparisonPage({super.key, required this.title, required this.emoji, required this.rows});

  final String title;
  final String emoji;
  final List<ComparisonRowData> rows;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: GymAppBar(title: title),
      body: SafeArea(
        child: ListView(padding: const EdgeInsets.all(16), children: [ComparisonRowsCard(rows: rows)]),
      ),
    );
  }
}
