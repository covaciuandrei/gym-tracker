import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/stats/stats_cubit.dart';
import 'package:gym_tracker/model/attendance_stats.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/controls/emoji_text.dart';
import 'package:gym_tracker/presentation/controls/error_state.dart';
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/gym_tab_bar.dart';
import 'package:gym_tracker/presentation/resources/app_colors.dart';
import 'package:gym_tracker/presentation/resources/emojis.dart';

@RoutePage()
class StatsPage extends StatelessWidget implements AutoRouteWrapper {
  const StatsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<StatsCubit>(
      create: (_) => getIt<StatsCubit>(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = getIt<FirebaseAuth>().currentUser?.uid;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.replace(const LoginRoute());
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    return StatsView(userId: userId);
  }
}

class StatsView extends StatefulWidget {
  const StatsView({super.key, required this.userId});

  final String userId;

  @override
  State<StatsView> createState() => _StatsViewState();
}

class _StatsViewState extends State<StatsView>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<int> _selectedYear = ValueNotifier<int>(
    DateTime.now().year,
  );
  final ValueNotifier<int> _selectedWorkoutMonth = ValueNotifier<int>(
    DateTime.now().month,
  );
  final ValueNotifier<int> _selectedDurationMonth = ValueNotifier<int>(
    DateTime.now().month,
  );
  final ValueNotifier<int> _selectedHealthMonth = ValueNotifier<int>(
    DateTime.now().month,
  );
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this)
      ..addListener(_onTabChanged);
    _initYearAndLoadActiveTab();
  }

  @override
  void dispose() {
    _selectedYear.dispose();
    _selectedWorkoutMonth.dispose();
    _selectedDurationMonth.dispose();
    _selectedHealthMonth.dispose();
    _tabController?.removeListener(_onTabChanged);
    _tabController?.dispose();
    super.dispose();
  }

  void _initYearAndLoadActiveTab() {
    final year = _selectedYear.value;
    final cubit = context.read<StatsCubit>();
    cubit.initYear(year);
    _loadCurrentTab(force: true);
  }

  void _onTabChanged() {
    final controller = _tabController;
    if (controller == null || controller.indexIsChanging) {
      return;
    }
    _loadCurrentTab();
  }

  StatsTabKind _tabKindForIndex(int index) {
    switch (index) {
      case 0:
        return StatsTabKind.attendances;
      case 1:
        return StatsTabKind.workouts;
      case 2:
        return StatsTabKind.duration;
      case 3:
        return StatsTabKind.health;
      default:
        return StatsTabKind.attendances;
    }
  }

  Future<void> _loadCurrentTab({bool force = false}) {
    final controller = _tabController;
    if (controller == null) {
      return Future<void>.value();
    }
    final selectedTab = _tabKindForIndex(controller.index);
    return context.read<StatsCubit>().loadTab(
      userId: widget.userId,
      year: _selectedYear.value,
      tab: selectedTab,
      force: force,
    );
  }

  void _changeYear(int delta) {
    final nextYear = _selectedYear.value + delta;
    _selectedYear.value = nextYear;
    context.read<StatsCubit>().initYear(nextYear);
    _loadCurrentTab(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surfaceContainerLow,
      appBar: GymAppBar(title: l10n.statsTitle, showBackButton: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              ValueListenableBuilder<int>(
                valueListenable: _selectedYear,
                builder: (_, year, _) {
                  return _YearHeader(
                    title: '$year',
                    onPrevious: () => _changeYear(-1),
                    onNext: () => _changeYear(1),
                  );
                },
              ),
              const SizedBox(height: 12),
              GymTabBar(
                controller: _tabController,
                tabs: [
                  l10n.statsAttendances,
                  l10n.statsWorkout,
                  l10n.statsDuration,
                  l10n.statsHealth,
                ],
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 0,
                  vertical: 8,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: BlocBuilder<StatsCubit, BaseState>(
                  buildWhen: (previous, current) =>
                      current is StatsLoadedState || current is InitialState,
                  builder: (ctx, state) {
                    final currentYear = _selectedYear.value;
                    if (state is! StatsLoadedState ||
                        state.year != currentYear) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final tabController = _tabController;
                    if (tabController == null) {
                      return const SizedBox.shrink();
                    }

                    return TabBarView(
                      controller: tabController,
                      children: [
                        _buildAttendancesTab(state),
                        _buildWorkoutsTab(state),
                        _buildDurationTab(state),
                        _buildHealthTab(state),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttendancesTab(StatsLoadedState state) {
    switch (state.attendancesStatus) {
      case StatsLoadStatus.idle:
      case StatsLoadStatus.loading:
        return const _AttendancesTabSkeleton();
      case StatsLoadStatus.error:
        return ErrorStateWidget(
          message: AppLocalizations.of(context).errorsUnknown,
          onRetry: () => context.read<StatsCubit>().loadTab(
            userId: widget.userId,
            year: _selectedYear.value,
            tab: StatsTabKind.attendances,
            force: true,
          ),
        );
      case StatsLoadStatus.loaded:
        final stats = state.attendancesStats;
        if (stats == null) {
          return const _AttendancesTabSkeleton();
        }
        return _AttendancesTab(stats: stats);
    }
  }

  Widget _buildWorkoutsTab(StatsLoadedState state) {
    switch (state.workoutsStatus) {
      case StatsLoadStatus.idle:
      case StatsLoadStatus.loading:
        return const _WorkoutsTabSkeleton();
      case StatsLoadStatus.error:
        return ErrorStateWidget(
          message: AppLocalizations.of(context).errorsUnknown,
          onRetry: () => context.read<StatsCubit>().loadTab(
            userId: widget.userId,
            year: _selectedYear.value,
            tab: StatsTabKind.workouts,
            force: true,
          ),
        );
      case StatsLoadStatus.loaded:
        final stats = state.workoutsStats;
        if (stats == null) {
          return const _WorkoutsTabSkeleton();
        }
        return _WorkoutsTab(
          stats: stats,
          types: state.types,
          selectedMonth: _selectedWorkoutMonth,
        );
    }
  }

  Widget _buildDurationTab(StatsLoadedState state) {
    switch (state.durationStatus) {
      case StatsLoadStatus.idle:
      case StatsLoadStatus.loading:
        return const _DurationTabSkeleton();
      case StatsLoadStatus.error:
        return ErrorStateWidget(
          message: AppLocalizations.of(context).errorsUnknown,
          onRetry: () => context.read<StatsCubit>().loadTab(
            userId: widget.userId,
            year: _selectedYear.value,
            tab: StatsTabKind.duration,
            force: true,
          ),
        );
      case StatsLoadStatus.loaded:
        final stats = state.durationStats;
        if (stats == null) {
          return const _DurationTabSkeleton();
        }
        return _DurationTab(
          stats: stats,
          types: state.types,
          selectedMonth: _selectedDurationMonth,
        );
    }
  }

  Widget _buildHealthTab(StatsLoadedState state) {
    switch (state.healthStatus) {
      case StatsLoadStatus.idle:
      case StatsLoadStatus.loading:
        return const _HealthTabSkeleton();
      case StatsLoadStatus.error:
        return ErrorStateWidget(
          message: AppLocalizations.of(context).errorsUnknown,
          onRetry: () => context.read<StatsCubit>().loadTab(
            userId: widget.userId,
            year: _selectedYear.value,
            tab: StatsTabKind.health,
            force: true,
          ),
        );
      case StatsLoadStatus.loaded:
        final stats = state.healthStats;
        if (stats == null) {
          return const _HealthTabSkeleton();
        }
        return _HealthTab(stats: stats, selectedMonth: _selectedHealthMonth);
    }
  }
}

class _YearHeader extends StatelessWidget {
  const _YearHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _NavIconButton(icon: Icons.chevron_left, onTap: onPrevious),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        _NavIconButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
  }
}

class _NavIconButton extends StatelessWidget {
  const _NavIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _AttendancesTab extends StatefulWidget {
  const _AttendancesTab({required this.stats});

  final AttendanceStats stats;

  @override
  State<_AttendancesTab> createState() => _AttendancesTabState();
}

class _AttendancesTabState extends State<_AttendancesTab> {
  String _currentStreakLabel = '';
  String _bestStreakLabel = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resetLabels();
  }

  void _resetLabels() {
    final l10n = AppLocalizations.of(context);
    _currentStreakLabel = l10n.statsTapToSeeDates;
    _bestStreakLabel = l10n.statsTapToSeeDates;
  }

  void _showStreakTemporarily(bool isCurrentStreak) {
    final streakInfo = isCurrentStreak
        ? widget.stats.currentStreakInfo
        : widget.stats.bestStreakInfo;
    if (streakInfo.count == 0 ||
        streakInfo.startDate.isEmpty ||
        streakInfo.endDate.isEmpty)
      return;

    final dateRange = _formatDateRange(
      context,
      streakInfo.startDate,
      streakInfo.endDate,
    );
    final l10n = AppLocalizations.of(context);

    setState(() {
      if (isCurrentStreak) {
        _currentStreakLabel = dateRange;
      } else {
        _bestStreakLabel = dateRange;
      }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          if (isCurrentStreak) {
            _currentStreakLabel = l10n.statsTapToSeeDates;
          } else {
            _bestStreakLabel = l10n.statsTapToSeeDates;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final weekdayMax = _maxOrOne(widget.stats.weekdayAttendanceCounts);
    final monthMax = _maxOrOne(widget.stats.monthlyAttendanceCounts);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.calendar,
                  value: '${widget.stats.monthlyCount}',
                  label: l10n.statsThisMonth,
                  colors: const [
                    AppColors.statsBluePurple,
                    AppColors.statsBluePurpleDark,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.target,
                  value: '${widget.stats.yearlyCount}',
                  label: l10n.statsThisYear,
                  colors: const [
                    AppColors.statsPinkRed,
                    AppColors.statsPinkRedDark,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.trophy,
                  value: '${widget.stats.totalCount}',
                  label: l10n.statsAllTime,
                  colors: const [
                    AppColors.statsOrangeAlt,
                    AppColors.statsOrangeAltDark,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.star,
                  value:
                      '${l10n.statsFavoriteDay} ${_favoriteDayLabel(context, widget.stats.favoriteDaysOfWeek)}',
                  label: widget.stats.favoriteDayCount > 0
                      ? l10n.statsXThisYear(widget.stats.favoriteDayCount)
                      : '0',
                  colors: const [
                    AppColors.statsViolet,
                    AppColors.statsVioletDark,
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.target,
                  value:
                      '${l10n.statsConsistencyWithoutIcon} ${_getConsistencyPercentage(widget.stats)} ',
                  label: l10n.statsOfWeeksThisYear,
                  colors: const [
                    AppColors.statsPurple,
                    AppColors.statsPurpleDark,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.fire,
                  value:
                      '${l10n.statsCurrentStreak} ${l10n.statsWeekCount(widget.stats.currentWeekStreak)}',
                  label: _currentStreakLabel,
                  colors: const [
                    AppColors.statsOrange,
                    AppColors.statsOrangeDark,
                  ],
                  onTap: widget.stats.currentWeekStreak > 0
                      ? () => _showStreakTemporarily(true)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.trophy,
                  value:
                      '${l10n.statsBestStreak} ${l10n.statsWeekCount(widget.stats.bestWeekStreak)}',
                  label: _bestStreakLabel,
                  colors: const [AppColors.statsTeal, AppColors.statsTealDark],
                  onTap: widget.stats.bestWeekStreak > 0
                      ? () => _showStreakTemporarily(false)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ChartSection(
            title: l10n.statsDaysYouHitGym,
            titleEmoji: Emojis.barChart,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.statsBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.stats.favoriteDaysOfWeek.length > 1
                      ? l10n.statsFavoriteDaysLegend
                      : l10n.statsFavoriteDayLegend,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.statsBlue),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < 7; i++) ...[
                  Expanded(
                    child: _VerticalBar(
                      value: widget.stats.weekdayAttendanceCounts[i].toDouble(),
                      max: weekdayMax.toDouble(),
                      label: _weekdayShort(context, i + 1),
                      highlighted: widget.stats.favoriteDaysOfWeek.contains(
                        i + 1,
                      ),
                      showValue: true,
                    ),
                  ),
                  if (i < 6) const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _ChartSection(
            title: l10n.statsMonthlyBreakdown,
            titleEmoji: Emojis.chartIncreasing,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.statsAttendances,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < 12; i++) ...[
                  Expanded(
                    child: _VerticalBar(
                      value: widget.stats.monthlyAttendanceCounts[i].toDouble(),
                      max: monthMax.toDouble(),
                      label: _monthShort(context, i + 1),
                      showValue: true,
                    ),
                  ),
                  if (i < 11) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutsTab extends StatelessWidget {
  const _WorkoutsTab({
    required this.stats,
    required this.types,
    required this.selectedMonth,
  });

  final AttendanceStats stats;
  final List<TrainingType> types;
  final ValueNotifier<int> selectedMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final sortedTypes = stats.typeDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final mostUsed = sortedTypes.isEmpty ? null : sortedTypes.first;
    final totalTracked = sortedTypes.fold(0, (sum, e) => sum + e.value);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.weightLifting,
                  value: mostUsed == null
                      ? '-'
                      : _typeFor(types, mostUsed.key)?.name ?? '-',
                  label: l10n.statsMostUsed,
                  colors: const [AppColors.primary, AppColors.primaryDark],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GradientStatCard(
                  icon: Emojis.barChart,
                  value: '$totalTracked',
                  label: l10n.statsTotalTracked,
                  colors: const [AppColors.statsTeal, AppColors.statsTealDark],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: selectedMonth,
            builder: (_, month, _) {
              final monthData =
                  stats.monthlyTypeDistribution[month] ?? const <String, int>{};
              final entries = monthData.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final maxCount = entries.isEmpty ? 1 : entries.first.value;

              return _ChartSection(
                title: '${_monthLong(context, month)} ${DateTime.now().year}',
                trailing: _MonthSwitcher(
                  selectedMonth: month,
                  onPrevious: () =>
                      selectedMonth.value = month == 1 ? 12 : month - 1,
                  onNext: () =>
                      selectedMonth.value = month == 12 ? 1 : month + 1,
                ),
                child: entries.isEmpty
                    ? _StatsCompactEmptyState(
                        title: l10n.statsWorkout,
                        message: l10n.statsThisMonth,
                        emoji: Emojis.weightLifting,
                      )
                    : Column(
                        children: entries
                            .map((entry) {
                              final type = _typeFor(types, entry.key);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _HorizontalProgress(
                                  icon: type?.icon ?? Emojis.weightLifting,
                                  name: type?.name ?? '-',
                                  value: entry.value.toDouble(),
                                  max: maxCount.toDouble(),
                                  color: _parseHexColor(type?.color),
                                  trailing: '${entry.value}',
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ChartSection(
            title: l10n.statsThisYear,
            child: sortedTypes.isEmpty
                ? _StatsCompactEmptyState(
                    title: l10n.statsWorkout,
                    message: l10n.statsThisYear,
                    emoji: Emojis.weightLifting,
                  )
                : Column(
                    children: sortedTypes
                        .map((entry) {
                          final type = _typeFor(types, entry.key);
                          final maxCount = sortedTypes.first.value.toDouble();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _HorizontalProgress(
                              icon: type?.icon ?? Emojis.weightLifting,
                              name: type?.name ?? '-',
                              value: entry.value.toDouble(),
                              max: maxCount,
                              color: _parseHexColor(type?.color),
                              trailing: '${entry.value}',
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
          ),
        ],
      ),
    );
  }
}

class _DurationTab extends StatelessWidget {
  const _DurationTab({
    required this.stats,
    required this.types,
    required this.selectedMonth,
  });

  final AttendanceStats stats;
  final List<TrainingType> types;
  final ValueNotifier<int> selectedMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: selectedMonth,
            builder: (_, month, _) {
              final monthAvg = stats.monthlyDurationAverages[month] ?? 0;

              return Row(
                children: [
                  Expanded(
                    child: _GradientStatCard(
                      icon: Emojis.stopwatchFull,
                      value: _durationLabel(context, monthAvg),
                      label: l10n.statsAvgThisMonth,
                      colors: const [AppColors.primary, AppColors.primaryDark],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GradientStatCard(
                      icon: Emojis.barChart,
                      value: _durationLabel(
                        context,
                        stats.yearlyAverageDurationMinutes,
                      ),
                      label: l10n.statsAvgThisYear,
                      colors: const [
                        AppColors.statsViolet,
                        AppColors.statsVioletDark,
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: selectedMonth,
            builder: (_, month, _) {
              final monthData =
                  stats.monthlyTypeDurationAverages[month] ??
                  const <String, double>{};
              final entries = monthData.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final maxValue = entries.isEmpty ? 1.0 : entries.first.value;

              return _ChartSection(
                title: _monthLong(context, month),
                trailing: _MonthSwitcher(
                  selectedMonth: month,
                  onPrevious: () =>
                      selectedMonth.value = month == 1 ? 12 : month - 1,
                  onNext: () =>
                      selectedMonth.value = month == 12 ? 1 : month + 1,
                ),
                child: entries.isEmpty
                    ? _StatsCompactEmptyState(
                        title: l10n.statsDuration,
                        message: l10n.statsThisMonth,
                        emoji: Emojis.stopwatchFull,
                      )
                    : Column(
                        children: entries
                            .map((entry) {
                              final type = _typeFor(types, entry.key);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _HorizontalProgress(
                                  icon: type?.icon ?? Emojis.stopwatchFull,
                                  name: type?.name ?? '-',
                                  value: entry.value,
                                  max: maxValue,
                                  color: _parseHexColor(type?.color),
                                  trailing: _durationLabel(
                                    context,
                                    entry.value,
                                  ),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ChartSection(
            title: l10n.statsDuration,
            titleEmoji: Emojis.stopwatch,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  l10n.statsAverageDurationLegend,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 1; i <= 12; i++) ...[
                  Expanded(
                    child: _VerticalBar(
                      value: stats.monthlyDurationAverages[i] ?? 0,
                      max: _maxDoubleOrOne(
                        stats.monthlyDurationAverages.values,
                      ),
                      label: _monthShort(context, i),
                      showValue: true,
                    ),
                  ),
                  if (i < 12) const SizedBox(width: 6),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthTab extends StatelessWidget {
  const _HealthTab({required this.stats, required this.selectedMonth});

  final AttendanceStats stats;
  final ValueNotifier<int> selectedMonth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          ValueListenableBuilder<int>(
            valueListenable: selectedMonth,
            builder: (_, month, _) {
              final monthSupp =
                  stats.monthlySupplementServings[month] ??
                  const <String, double>{};
              final sortedMonthSupp = monthSupp.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));
              final topMonth = sortedMonthSupp.isEmpty
                  ? null
                  : sortedMonthSupp.first;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _GradientStatCard(
                          icon: Emojis.pill,
                          value: topMonth == null
                              ? '-'
                              : stats.productNames[topMonth.key] ?? '-',
                          label: topMonth == null
                              ? l10n.statsThisMonth
                              : '${l10n.statsCountTimes(topMonth.value.toInt())} ${l10n.statsThisMonth}',

                          colors: const [
                            AppColors.statsEmerald,
                            AppColors.statsEmeraldDark,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientStatCard(
                          icon: Emojis.trophy,
                          value: stats.mostTakenSupplementName ?? '-',
                          label: stats.mostTakenSupplementCount <= 0
                              ? l10n.statsMostUsed
                              : '${l10n.statsCountTimes(stats.mostTakenSupplementCount.toInt())} ${l10n.statsMostUsed}',

                          colors: const [
                            AppColors.statsTeal,
                            AppColors.statsTealDark,
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _GradientStatCard(
                          icon: Emojis.target,
                          value: l10n.statsConsistencyWithoutIcon,
                          label: l10n.statsPercentOfWeeksThisYear(
                            stats.healthConsistencyPct.round(),
                          ),
                          colors: const [
                            AppColors.statsCyan,
                            AppColors.statsCyanDark,
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GradientStatCard(
                          icon: Emojis.pill,
                          value: l10n.statsUniqueSupplements,
                          label: l10n.statsDifferentProducts(
                            stats.productNames.length,
                          ),
                          colors: const [
                            AppColors.statsEmerald,
                            AppColors.statsEmeraldDark,
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: selectedMonth,
            builder: (_, month, _) {
              final monthSupp =
                  stats.monthlySupplementServings[month] ??
                  const <String, double>{};
              final entries = monthSupp.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value));

              return _ChartSection(
                title: _monthLong(context, month),
                trailing: _MonthSwitcher(
                  selectedMonth: month,
                  onPrevious: () =>
                      selectedMonth.value = month == 1 ? 12 : month - 1,
                  onNext: () =>
                      selectedMonth.value = month == 12 ? 1 : month + 1,
                ),
                child: entries.isEmpty
                    ? _StatsCompactEmptyState(
                        title: l10n.statsHealth,
                        message: l10n.statsThisMonth,
                        emoji: Emojis.pill,
                      )
                    : Column(
                        children: entries
                            .take(8)
                            .map((entry) {
                              final max = entries.first.value;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _HorizontalProgress(
                                  icon: Emojis.pill,
                                  name: stats.productNames[entry.key] ?? '-',
                                  value: entry.value,
                                  max: max,
                                  color: AppColors.statsEmerald,
                                  trailing: entry.value.toStringAsFixed(0),
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AttendancesTabSkeleton extends StatelessWidget {
  const _AttendancesTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: const [
          _StatsSkeletonRow(cards: 3),
          SizedBox(height: 12),
          _StatsSkeletonRow(cards: 2),
          SizedBox(height: 12),
          _StatsSkeletonRow(cards: 2),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
        ],
      ),
    );
  }
}

class _WorkoutsTabSkeleton extends StatelessWidget {
  const _WorkoutsTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: const [
          _StatsSkeletonRow(cards: 2),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
        ],
      ),
    );
  }
}

class _DurationTabSkeleton extends StatelessWidget {
  const _DurationTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: const [
          _StatsSkeletonRow(cards: 2),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
        ],
      ),
    );
  }
}

class _HealthTabSkeleton extends StatelessWidget {
  const _HealthTabSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: const [
          _StatsSkeletonRow(cards: 2),
          SizedBox(height: 12),
          _StatsSkeletonRow(cards: 2),
          SizedBox(height: 16),
          _StatsSkeletonSection(),
        ],
      ),
    );
  }
}

class _StatsSkeletonRow extends StatelessWidget {
  const _StatsSkeletonRow({required this.cards});

  final int cards;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int index = 0; index < cards; index++) ...[
          const Expanded(child: _StatsSkeletonCard()),
          if (index < cards - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _StatsSkeletonCard extends StatelessWidget {
  const _StatsSkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 98,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _SkeletonBox(height: 18, width: 24),
            SizedBox(height: 10),
            _SkeletonBox(height: 14, width: 76),
            SizedBox(height: 6),
            _SkeletonBox(height: 12, width: 54),
          ],
        ),
      ),
    );
  }
}

class _StatsSkeletonSection extends StatelessWidget {
  const _StatsSkeletonSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SkeletonBox(height: 16, width: 160),
          SizedBox(height: 12),
          _SkeletonBox(height: 12),
          SizedBox(height: 8),
          _SkeletonBox(height: 12),
          SizedBox(height: 8),
          _SkeletonBox(height: 12, width: 220),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: cs.outlineVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

class _ChartSection extends StatelessWidget {
  const _ChartSection({
    required this.title,
    required this.child,
    this.titleEmoji,
    this.trailing,
  });

  final String title;

  /// Optional emoji displayed before [title]. Using a separate field ensures
  /// EmojiText is used so iOS renders the emoji correctly.
  final String? titleEmoji;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final titleStyle = Theme.of(context).textTheme.titleMedium;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (titleEmoji != null) ...[
                        EmojiText(titleEmoji!, style: titleStyle),
                        const SizedBox(width: 6),
                      ],
                      Expanded(child: Text(title, style: titleStyle)),
                    ],
                  ),
                ),
                ...trailing != null ? [trailing!] : [],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _StatsCompactEmptyState extends StatelessWidget {
  const _StatsCompactEmptyState({
    required this.title,
    required this.message,
    required this.emoji,
  });

  final String title;
  final String message;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          EmojiText(emoji, style: const TextStyle(fontSize: 34)),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientStatCard extends StatelessWidget {
  const _GradientStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.colors,
    this.onTap,
  });

  final String icon;
  final String value;
  final String label;
  final List<Color> colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12 * 0.8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            EmojiText(
              icon,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2 * 0.8),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 10, // Smaller font for longer text like dates
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalBar extends StatelessWidget {
  const _VerticalBar({
    required this.value,
    required this.max,
    required this.label,
    this.highlighted = false,
    this.showValue = false,
  });

  final double value;
  final double max;
  final String label;
  final bool highlighted;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 20,
                height: 8 + (ratio * 112),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: highlighted ? AppColors.statsBlue : cs.primary,
                ),
              ),
              if (showValue)
                Positioned(
                  bottom: 8 + (ratio * 112) + 4,
                  child: Text(
                    value.round().toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: highlighted
                          ? AppColors.statsBlue
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 8.5,

            color: highlighted ? AppColors.statsBlue : cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _HorizontalProgress extends StatelessWidget {
  const _HorizontalProgress({
    required this.icon,
    required this.name,
    required this.value,
    required this.max,
    required this.color,
    required this.trailing,
  });

  final String icon;
  final String name;
  final double value;
  final double max;
  final Color color;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);

    return Row(
      children: [
        EmojiText(icon),
        const SizedBox(width: 8),
        Expanded(
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 12,
              color: cs.outline.withValues(alpha: 0.25),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(color: color),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(trailing, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({
    required this.selectedMonth,
    required this.onPrevious,
    required this.onNext,
  });

  final int selectedMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPrevious,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.chevron_left, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        Text(_monthShort(context, selectedMonth)),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onNext,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.chevron_right, size: 18),
          ),
        ),
      ],
    );
  }
}

TrainingType? _typeFor(List<TrainingType> types, String id) {
  for (final type in types) {
    if (type.id == id) return type;
  }
  return null;
}

Color _parseHexColor(String? hex) {
  if (hex == null || hex.trim().isEmpty) return AppColors.primary;
  final cleaned = hex.replaceAll('#', '');
  final value = int.tryParse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
  return value == null ? AppColors.primary : Color(value);
}

int _maxOrOne(List<int> values) {
  if (values.isEmpty) return 1;
  final max = values.reduce((a, b) => a > b ? a : b);
  return max <= 0 ? 1 : max;
}

double _maxDoubleOrOne(Iterable<double> values) {
  if (values.isEmpty) return 1;
  double max = 0;
  for (final value in values) {
    if (value > max) max = value;
  }
  return max <= 0 ? 1 : max;
}

String _durationLabel(BuildContext context, double minutes) {
  final l10n = AppLocalizations.of(context);
  return '${minutes.round()} ${l10n.statsMinutes}';
}

String _favoriteDayLabel(BuildContext context, List<int> weekdayIndexes) {
  if (weekdayIndexes.isEmpty) return '-';
  return weekdayIndexes
      .map((weekday) => _weekdayShort(context, weekday))
      .join(' / ');
}

String _monthShort(BuildContext context, int month) {
  final full = _monthLong(context, month);
  if (full.length <= 3) return full;
  return full.substring(0, 3);
}

String _monthLong(BuildContext context, int month) {
  final l10n = AppLocalizations.of(context);
  return switch (month) {
    1 => l10n.monthsJanuary,
    2 => l10n.monthsFebruary,
    3 => l10n.monthsMarch,
    4 => l10n.monthsApril,
    5 => l10n.monthsMay,
    6 => l10n.monthsJune,
    7 => l10n.monthsJuly,
    8 => l10n.monthsAugust,
    9 => l10n.monthsSeptember,
    10 => l10n.monthsOctober,
    11 => l10n.monthsNovember,
    _ => l10n.monthsDecember,
  };
}

String _weekdayShort(BuildContext context, int weekday) {
  final l10n = AppLocalizations.of(context);
  final value = switch (weekday) {
    1 => l10n.weekdaysMonday,
    2 => l10n.weekdaysTuesday,
    3 => l10n.weekdaysWednesday,
    4 => l10n.weekdaysThursday,
    5 => l10n.weekdaysFriday,
    6 => l10n.weekdaysSaturday,
    _ => l10n.weekdaysSunday,
  };
  if (value.length <= 3) return value;
  return value.substring(0, 3);
}

String _getConsistencyPercentage(AttendanceStats stats) {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final passedWeeks = (now.difference(startOfYear).inDays / 7).ceil();

  if (passedWeeks <= 0) return '0%';

  // Estimate weeks with attendance based on total attendance count
  // This is an approximation since we don't have week-by-week data
  // Assume average 2-3 visits per week for regular gym-goers
  final estimatedWeeksWithAttendance = (stats.yearlyCount / 2.5).ceil().clamp(
    0,
    passedWeeks,
  );
  final consistencyPercentage =
      (estimatedWeeksWithAttendance / passedWeeks * 100).round();
  return '$consistencyPercentage%';
}

String _formatDateRange(BuildContext context, String start, String end) {
  if (start.isEmpty || end.isEmpty) return '';
  String fmt(d) {
    final date = DateTime.parse(d);
    return '${date.day} ${_monthShort(context, date.month)} ${date.year}';
  }

  return '${fmt(start)} → ${fmt(end)}';
}
