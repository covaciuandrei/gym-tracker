import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/health_insights/health_insights_cubit.dart';
import 'package:gym_tracker/presentation/controls/error_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/pull_to_refresh.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/body_recomposition_card.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/cardio_fitness_card.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/heart_rate_recovery_card.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/metabolic_card.dart';
import 'package:gym_tracker/presentation/pages/health_insights/widgets/physical_overview_card.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

/// Apple Watch / Apple Health analytics not shown in the stock Health app:
/// body recomposition, weight-adjusted VO2Max, recovery/readiness, and
/// personalized metabolic estimates — each benchmarked against people who
/// share the user's age/sex/height, or against an earlier version of the
/// user.
///
/// Data comes live from Apple Health (see `docs/features/health_insights.md`).
/// iOS-only — see the entry point on [HealthPage].
@RoutePage()
class HealthInsightsPage extends StatefulWidget implements AutoRouteWrapper {
  const HealthInsightsPage({super.key});

  @override
  State<HealthInsightsPage> createState() => _HealthInsightsPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<HealthInsightsCubit>(create: (_) => getIt<HealthInsightsCubit>()..load(), child: this);
  }
}

class _HealthInsightsPageState extends State<HealthInsightsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: GymAppBar(title: l10n.healthInsightsTitle),
      body: SafeArea(
        child: BlocBuilder<HealthInsightsCubit, BaseState>(builder: _buildBody),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BaseState state) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<HealthInsightsCubit>();

    if (state is SomethingWentWrongState) {
      return ErrorStateWidget(message: l10n.healthInsightsLoadErrorMessage, onRetry: cubit.load);
    }
    if (state is HealthInsightsPermissionDeniedState) {
      return ErrorStateWidget(
        emoji: Emojis.locked,
        title: l10n.healthInsightsPermissionDeniedTitle,
        message: l10n.healthInsightsPermissionDeniedMessage,
        onRetry: cubit.refresh,
      );
    }
    if (state is! HealthInsightsReadyState) {
      return const _HealthInsightsSkeleton();
    }

    final result = state.result;
    return PullToRefresh(
      onRefresh: cubit.refresh,
      child: ListView(
        physics: PullToRefresh.alwaysScrollablePhysics,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          PhysicalOverviewCard(overview: result.overview),
          const SizedBox(height: 16),
          BodyRecompositionCard(trend: result.bodyComposition),
          const SizedBox(height: 16),
          CardioFitnessCard(cardioFitness: result.cardioFitness),
          const SizedBox(height: 16),
          HeartRateRecoveryCard(recovery: result.heartRateRecovery),
          const SizedBox(height: 16),
          MetabolicCard(estimate: result.metabolic),
        ],
      ),
    );
  }
}

class _HealthInsightsSkeleton extends StatelessWidget {
  const _HealthInsightsSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, _) =>
          Container(height: 140, decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: BorderRadius.circular(16))),
    );
  }
}
