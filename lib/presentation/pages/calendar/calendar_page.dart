import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/calendar/calendar_cubit.dart';
import 'package:gym_tracker/cubit/health/health_cubit.dart';
import 'package:gym_tracker/cubit/workout/workout_cubit.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

enum _ViewMode { monthly, yearly }

Color _hexToColor(String hex) {
  try {
    return Color(int.parse('FF${hex.replaceAll('#', '')}', radix: 16));
  } catch (_) {
    return Colors.grey;
  }
}

String _pad2(int n) => n.toString().padLeft(2, '0');

/// Returns "YYYY-MM-DD" for a given [date].
String _dateKey(DateTime date) =>
    '${date.year}-${_pad2(date.month)}-${_pad2(date.day)}';

String _monthName(int month, AppLocalizations l10n) {
  switch (month) {
    case 1:  return l10n.monthsJanuary;
    case 2:  return l10n.monthsFebruary;
    case 3:  return l10n.monthsMarch;
    case 4:  return l10n.monthsApril;
    case 5:  return l10n.monthsMay;
    case 6:  return l10n.monthsJune;
    case 7:  return l10n.monthsJuly;
    case 8:  return l10n.monthsAugust;
    case 9:  return l10n.monthsSeptember;
    case 10: return l10n.monthsOctober;
    case 11: return l10n.monthsNovember;
    case 12: return l10n.monthsDecember;
    default: return '';
  }
}

/// Returns 42 [DateTime] cells for a Mon–Sun, 6-row monthly grid,
/// including padding days from the previous and next month.
List<DateTime> _buildMonthCells(int year, int month) {
  final firstDay = DateTime(year, month, 1);
  // Dart: weekday 1 = Mon, 7 = Sun → leading offset = weekday - 1
  final leading = firstDay.weekday - 1;
  final daysInMonth = DateTime(year, month + 1, 0).day;

  final cells = <DateTime>[];
  for (int i = leading; i > 0; i--) {
    cells.add(firstDay.subtract(Duration(days: i)));
  }
  for (int d = 1; d <= daysInMonth; d++) {
    cells.add(DateTime(year, month, d));
  }
  int trailing = 1;
  while (cells.length < 42) {
    cells.add(DateTime(year, month + 1, trailing++));
  }
  return cells;
}

// ─── Page ─────────────────────────────────────────────────────────────────────

@RoutePage()
class CalendarPage extends StatefulWidget implements AutoRouteWrapper {
  const CalendarPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CalendarCubit>(create: (_) => getIt<CalendarCubit>()),
        BlocProvider<WorkoutCubit>(create: (_) => getIt<WorkoutCubit>()),
        // Month-level health indicators (kept alive in the page)
        BlocProvider<HealthCubit>(create: (_) => getIt<HealthCubit>()),
      ],
      child: this,
    );
  }

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final DateTime _today = DateTime.now();
  late int _displayYear;
  late int _displayMonth;
  _ViewMode _viewMode = _ViewMode.monthly;

  List<AttendanceDay> _days = [];
  List<TrainingType> _trainingTypes = [];
  Set<String> _healthDates = {};

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _displayYear = _today.year;
    _displayMonth = _today.month;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllData());
  }

  void _loadAllData() {
    if (!mounted) return;
    context.read<CalendarCubit>().loadMonth(
          userId: _userId,
          year: _displayYear,
          month: _displayMonth,
        );
    context.read<WorkoutCubit>().loadTypes(_userId);
    context.read<HealthCubit>().loadMonthEntries(
          userId: _userId,
          year: _displayYear,
          month: _displayMonth,
        );
  }

  void _navigateMonth(int delta) {
    var m = _displayMonth + delta;
    var y = _displayYear;
    if (m > 12) { m = 1; y++; }
    else if (m < 1) { m = 12; y--; }
    setState(() {
      _displayYear = y;
      _displayMonth = m;
      _days = [];
      _healthDates = {};
    });
    context.read<CalendarCubit>().loadMonth(
          userId: _userId, year: y, month: m);
    context.read<HealthCubit>().loadMonthEntries(
          userId: _userId, year: y, month: m);
  }

  void _navigateYear(int delta) => setState(() => _displayYear += delta);

  void _goToMonth(int month) {
    setState(() {
      _displayMonth = month;
      _viewMode = _ViewMode.monthly;
      _days = [];
      _healthDates = {};
    });
    context.read<CalendarCubit>().loadMonth(
          userId: _userId, year: _displayYear, month: month);
    context.read<HealthCubit>().loadMonthEntries(
          userId: _userId, year: _displayYear, month: month);
  }

  void _openDayPopup(DateTime date) {
    final dateKey = _dateKey(date);
    final existingDay = _days.where((d) => d.date == dateKey).firstOrNull;
    final calendarCubit = context.read<CalendarCubit>();
    final workoutCubit = context.read<WorkoutCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return MultiBlocProvider(
          providers: [
            BlocProvider<CalendarCubit>.value(value: calendarCubit),
            BlocProvider<WorkoutCubit>.value(value: workoutCubit),
            // Fresh HealthCubit for day-level data — separate from page's month one
            BlocProvider<HealthCubit>(create: (_) => getIt<HealthCubit>()),
          ],
          child: _DayPopup(
            date: date,
            initialDay: existingDay,
            trainingTypes: _trainingTypes,
            userId: _userId,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final headerTitle = _viewMode == _ViewMode.monthly
        ? '${_monthName(_displayMonth, l10n)} $_displayYear'
        : '$_displayYear';

    return MultiBlocListener(
      listeners: [
        BlocListener<CalendarCubit, BaseState>(
          listener: (ctx, state) {
            if (state is CalendarMonthLoadedState) {
              setState(() => _days = state.days);
            }
            if (state is SomethingWentWrongState) {
              ScaffoldMessenger.of(ctx).showSnackBar(
                SnackBar(content: Text(l10n.errorsUnknown)),
              );
            }
          },
        ),
        BlocListener<WorkoutCubit, BaseState>(
          listener: (ctx, state) {
            if (state is WorkoutTypesLoadedState) {
              setState(() => _trainingTypes = state.types);
            }
          },
        ),
        BlocListener<HealthCubit, BaseState>(
          listener: (ctx, state) {
            if (state is HealthMonthEntriesLoadedState) {
              setState(
                  () => _healthDates = state.entries.map((e) => e.date).toSet());
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.calendarTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SegmentedButton<_ViewMode>(
                segments: [
                  ButtonSegment(
                      value: _ViewMode.monthly,
                      label: Text(l10n.calendarMonthly)),
                  ButtonSegment(
                      value: _ViewMode.yearly,
                      label: Text(l10n.calendarYearly)),
                ],
                selected: {_viewMode},
                onSelectionChanged: (v) =>
                    setState(() => _viewMode = v.first),
                style: const ButtonStyle(
                    visualDensity: VisualDensity.compact),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // ── Navigation row ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _viewMode == _ViewMode.monthly
                        ? () => _navigateMonth(-1)
                        : () => _navigateYear(-1),
                  ),
                  Expanded(
                    child: Text(
                      headerTitle,
                      textAlign: TextAlign.center,
                      style: tt.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _viewMode == _ViewMode.monthly
                        ? () => _navigateMonth(1)
                        : () => _navigateYear(1),
                  ),
                ],
              ),
            ),
            // ── Calendar body ──────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<CalendarCubit, BaseState>(
                builder: (ctx, state) {
                  final typeMap = {
                    for (final t in _trainingTypes) t.id: t
                  };
                  return Stack(
                    children: [
                      if (_viewMode == _ViewMode.monthly)
                        _MonthlyView(
                          year: _displayYear,
                          month: _displayMonth,
                          today: _today,
                          days: _days,
                          typeMap: typeMap,
                          healthDates: _healthDates,
                          onDayTap: _openDayPopup,
                        )
                      else
                        _YearlyView(
                          year: _displayYear,
                          onMonthTap: _goToMonth,
                        ),
                      if (state is PendingState)
                        const Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black26,
                            child: Center(
                                child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Monthly view ──────────────────────────────────────────────────────────────

class _MonthlyView extends StatelessWidget {
  const _MonthlyView({
    required this.year,
    required this.month,
    required this.today,
    required this.days,
    required this.typeMap,
    required this.healthDates,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final DateTime today;
  final List<AttendanceDay> days;
  final Map<String, TrainingType> typeMap;
  final Set<String> healthDates;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final cells = _buildMonthCells(year, month);
    final attendanceMap = {for (final d in days) d.date: d};

    return Column(
      children: [
        _WeekdayHeaders(),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: cells.length,
            itemBuilder: (_, i) {
              final date = cells[i];
              final isCurrentMonth = date.month == month;
              final dateKey = _dateKey(date);
              final attendanceDay = attendanceMap[dateKey];
              final trainingType = attendanceDay?.trainingTypeId != null
                  ? typeMap[attendanceDay!.trainingTypeId!]
                  : null;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              return _DayCell(
                date: date,
                isCurrentMonth: isCurrentMonth,
                isToday: isToday,
                attendanceDay: attendanceDay,
                trainingType: trainingType,
                hasHealthLog: healthDates.contains(dateKey),
                onTap: isCurrentMonth ? () => onDayTap(date) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Weekday headers ───────────────────────────────────────────────────────────

class _WeekdayHeaders extends StatelessWidget {
  const _WeekdayHeaders();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final labels = [
      l10n.weekdaysMiniMon, l10n.weekdaysMiniTue, l10n.weekdaysMiniWed,
      l10n.weekdaysMiniThu, l10n.weekdaysMiniFri,
      l10n.weekdaysMiniSat, l10n.weekdaysMiniSun,
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: labels
            .map((lbl) => Expanded(
                  child: Text(
                    lbl,
                    textAlign: TextAlign.center,
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

// ─── Day cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.attendanceDay,
    required this.trainingType,
    required this.hasHealthLog,
    this.onTap,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final AttendanceDay? attendanceDay;
  final TrainingType? trainingType;
  final bool hasHealthLog;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isAttended = attendanceDay != null;
    final typeColor =
        trainingType != null ? _hexToColor(trainingType!.color) : cs.primary;
    final dimAlpha = isCurrentMonth ? 1.0 : 0.3;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: isAttended
              ? typeColor.withValues(alpha: isCurrentMonth ? 0.22 : 0.08)
              : null,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: cs.primary, width: 2)
              : null,
        ),
        child: Stack(
          children: [
            // ── Day number + activity indicator ────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${date.day}',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: dimAlpha),
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isAttended && isCurrentMonth) ...[
                    const SizedBox(height: 1),
                    trainingType?.icon != null
                        ? Text(
                            trainingType!.icon!,
                            style: tt.bodyLarge,
                          )
                        : Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: typeColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ],
                ],
              ),
            ),
            // ── Health indicator dot (bottom-right) ────────────────────────
            if (hasHealthLog && isCurrentMonth)
              Positioned(
                bottom: 3,
                right: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: cs.tertiary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Yearly view ───────────────────────────────────────────────────────────────

class _YearlyView extends StatelessWidget {
  const _YearlyView({
    required this.year,
    required this.onMonthTap,
  });

  final int year;
  final ValueChanged<int> onMonthTap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: 12,
      itemBuilder: (_, i) => _YearMonthCard(
        year: year,
        month: i + 1,
        onTap: () => onMonthTap(i + 1),
      ),
    );
  }
}

class _YearMonthCard extends StatelessWidget {
  const _YearMonthCard({
    required this.year,
    required this.month,
    required this.onTap,
  });

  final int year;
  final int month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final cells = _buildMonthCells(year, month);
    final today = DateTime.now();

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _monthName(month, l10n),
                style: tt.labelMedium?.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                  ),
                  itemCount: cells.length,
                  itemBuilder: (_, i) {
                    final date = cells[i];
                    final isCurrentMonth = date.month == month;
                    final isToday = date.year == today.year &&
                        date.month == today.month &&
                        date.day == today.day;
                    return Container(
                      decoration: BoxDecoration(
                        color: isToday ? cs.primary.withValues(alpha: 0.3) : null,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: tt.bodySmall?.copyWith(
                            fontSize: 7,
                            color: isCurrentMonth
                                ? cs.onSurface
                                : cs.onSurface.withValues(alpha: 0.25),
                          ),
                        ),
                      ),
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
}

// ─── Day popup ─────────────────────────────────────────────────────────────────

class _DayPopup extends StatefulWidget {
  const _DayPopup({
    required this.date,
    required this.initialDay,
    required this.trainingTypes,
    required this.userId,
  });

  final DateTime date;
  final AttendanceDay? initialDay;
  final List<TrainingType> trainingTypes;
  final String userId;

  @override
  State<_DayPopup> createState() => _DayPopupState();
}

class _DayPopupState extends State<_DayPopup>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final dayNum = widget.date.day;
    final monthStr = _monthName(widget.date.month, l10n);
    final yearStr = widget.date.year;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: Column(
          children: [
            // ── Drag handle ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // ── Date title ────────────────────────────────────────────────
            Text(
              '$dayNum $monthStr $yearStr',
              style: tt.headlineLarge,
            ),
            const SizedBox(height: 8),
            // ── Tab bar ───────────────────────────────────────────────────
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: l10n.calendarWorkoutTab),
                Tab(text: l10n.calendarHealthTab),
              ],
            ),
            // ── Tab content ───────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _WorkoutTab(
                    date: widget.date,
                    initialDay: widget.initialDay,
                    trainingTypes: widget.trainingTypes,
                    userId: widget.userId,
                  ),
                  _HealthTab(
                    date: widget.date,
                    userId: widget.userId,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Workout tab ───────────────────────────────────────────────────────────────

class _WorkoutTab extends StatefulWidget {
  const _WorkoutTab({
    required this.date,
    required this.initialDay,
    required this.trainingTypes,
    required this.userId,
  });

  final DateTime date;
  final AttendanceDay? initialDay;
  final List<TrainingType> trainingTypes;
  final String userId;

  @override
  State<_WorkoutTab> createState() => _WorkoutTabState();
}

class _WorkoutTabState extends State<_WorkoutTab> {
  late AttendanceDay? _localDay;
  String? _selectedTypeId;
  late final TextEditingController _durationController;
  bool _justMarked = false; // true after tapping "Mark as attended"

  @override
  void initState() {
    super.initState();
    _localDay = widget.initialDay;
    _selectedTypeId = widget.initialDay?.trainingTypeId;
    _durationController = TextEditingController(
      text: widget.initialDay?.durationMinutes?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  void _markAttended(CalendarCubit cubit) {
    _justMarked = true;
    cubit.markDay(
      userId: widget.userId,
      day: AttendanceDay(
        date: _dateKey(widget.date),
        timestamp: DateTime.now(),
      ),
    );
  }

  void _save(CalendarCubit cubit) {
    final duration = int.tryParse(_durationController.text.trim());
    cubit.markDay(
      userId: widget.userId,
      day: AttendanceDay(
        date: _dateKey(widget.date),
        timestamp: _localDay?.timestamp ?? DateTime.now(),
        trainingTypeId:
            _selectedTypeId?.isEmpty ?? true ? null : _selectedTypeId,
        durationMinutes: duration,
        notes: _localDay?.notes,
      ),
    );
  }

  void _clear(CalendarCubit cubit) {
    cubit.clearDay(
      userId: widget.userId,
      date: _dateKey(widget.date),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CalendarCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is CalendarDayMarkedState ||
          curr is CalendarDayClearedState ||
          curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is CalendarDayMarkedState) {
          if (_justMarked) {
            setState(() {
              _localDay = state.day;
              _justMarked = false;
            });
          } else {
            Navigator.of(ctx).pop();
          }
        }
        if (state is CalendarDayClearedState) {
          Navigator.of(ctx).pop();
        }
        if (state is SomethingWentWrongState) {
          setState(() => _justMarked = false);
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(l10n.errorsUnknown)),
          );
        }
      },
      builder: (ctx, state) {
        final isLoading = state is PendingState;
        final cubit = ctx.read<CalendarCubit>();

        return Stack(
          children: [
            SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: _localDay == null
                  ? _buildNotAttended(ctx, cubit)
                  : _buildAttended(ctx, l10n, cubit, cs),
            ),
            if (isLoading)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildNotAttended(BuildContext ctx, CalendarCubit cubit) {
    final l10n = AppLocalizations.of(ctx);
    return Column(
      children: [
        const SizedBox(height: 24),
        PrimaryButton(
          label: l10n.calendarMarkAttended,
          onPressed: () => _markAttended(cubit),
        ),
      ],
    );
  }

  Widget _buildAttended(
    BuildContext ctx,
    AppLocalizations l10n,
    CalendarCubit cubit,
    ColorScheme cs,
  ) {
    final typeOptions = <DropdownMenuItem<String?>>[
      DropdownMenuItem<String?>(
        value: null,
        child: Text(l10n.calendarNoType),
      ),
      ...widget.trainingTypes.map(
        (t) => DropdownMenuItem<String?>(
          value: t.id,
          child: Row(
            children: [
              if (t.icon != null)
                Text(t.icon!, style: Theme.of(ctx).textTheme.bodyMedium),
              if (t.icon != null) const SizedBox(width: 8),
              Text(t.name),
            ],
          ),
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        // ── Attended badge ───────────────────────────────────────────────
        Row(
          children: [
            Icon(Icons.check_circle, color: cs.primary, size: 20),
            const SizedBox(width: 8),
            Text(l10n.calendarWentToGym,
                style: Theme.of(ctx)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: cs.primary)),
          ],
        ),
        const SizedBox(height: 16),
        // ── Training type ────────────────────────────────────────────────
        DropdownButtonFormField<String?>(
          key: ValueKey(_selectedTypeId),
          initialValue: _selectedTypeId,
          decoration: InputDecoration(
            labelText: l10n.calendarTrainingType,
          ),
          items: typeOptions,
          onChanged: (v) => setState(() => _selectedTypeId = v),
        ),
        const SizedBox(height: 12),
        // ── Duration ─────────────────────────────────────────────────────
        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: l10n.calendarDurationMinutes,
          ),
        ),
        const SizedBox(height: 20),
        // ── Action buttons ────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _clear(cubit),
                style: OutlinedButton.styleFrom(
                    foregroundColor: cs.error),
                child: Text(l10n.calendarClear),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: PrimaryButton(
                label: l10n.calendarSave,
                onPressed: () => _save(cubit),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── Health tab ────────────────────────────────────────────────────────────────

class _HealthTab extends StatefulWidget {
  const _HealthTab({
    required this.date,
    required this.userId,
  });

  final DateTime date;
  final String userId;

  @override
  State<_HealthTab> createState() => _HealthTabState();
}

class _HealthTabState extends State<_HealthTab> {
  List<SupplementLog>? _entries;
  List<SupplementProduct>? _products;
  String? _selectedProductId;
  final TextEditingController _servingsController =
      TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    final dateKey = _dateKey(widget.date);
    context.read<HealthCubit>().loadDayEntries(
          userId: widget.userId, date: dateKey);
    context.read<HealthCubit>().loadProducts(widget.userId);
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  void _logSupplement(HealthCubit cubit) {
    final productId = _selectedProductId;
    if (productId == null) return;
    final servings = double.tryParse(_servingsController.text.trim()) ?? 1.0;
    final product = _products?.where((p) => p.id == productId).firstOrNull;
    cubit.logSupplement(
      userId: widget.userId,
      model: SupplementLog(
        id: '',
        date: _dateKey(widget.date),
        productId: productId,
        productName: product?.name,
        productBrand: product?.brand,
        servingsTaken: servings,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocConsumer<HealthCubit, BaseState>(
      listener: (ctx, state) {
        if (state is HealthDayEntriesLoadedState) {
          setState(() => _entries = state.entries);
        }
        if (state is HealthProductsLoadedState) {
          setState(() => _products = state.products);
        }
        if (state is HealthEntryLoggedState) {
          setState(() {
            _selectedProductId = null;
            _servingsController.text = '1';
          });
        }
        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(content: Text(l10n.errorsUnknown)),
          );
        }
      },
      builder: (ctx, state) {
        final cubit = ctx.read<HealthCubit>();
        final entries = _entries;
        final products = _products ?? [];

        if (entries == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Existing log entries ───────────────────────────────────────
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.calendarNoHealthLogs,
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ...entries.map(
                (entry) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.medication_outlined),
                    title: Text(
                      entry.productName ?? entry.productId,
                      style: tt.titleSmall,
                    ),
                    subtitle: entry.productBrand != null
                        ? Text(entry.productBrand!,
                            style: tt.bodySmall)
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '× ${entry.servingsTaken.toStringAsFixed(entry.servingsTaken % 1 == 0 ? 0 : 1)}',
                          style: tt.labelMedium,
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline,
                              color: cs.error, size: 20),
                          onPressed: () => cubit.deleteEntry(
                            userId: widget.userId,
                            date: _dateKey(widget.date),
                            entryId: entry.id,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const Divider(height: 24),

            // ── Add supplement form ────────────────────────────────────────
            Text(
              l10n.calendarAddSupplement.toUpperCase(),
              style: tt.labelSmall,
            ),
            const SizedBox(height: 10),

            // Product dropdown
            if (products.isEmpty)
              Text(
                l10n.healthMySupplements,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              )
            else
              DropdownButtonFormField<String?>(
                key: ValueKey(_selectedProductId),
                initialValue: _selectedProductId,
                decoration: InputDecoration(
                  labelText: l10n.calendarSelectProduct,
                  isDense: true,
                ),
                items: [
                  DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.calendarSelectProduct,
                          style: tt.bodySmall
                              ?.copyWith(color: cs.onSurfaceVariant))),
                  ...products.map(
                    (p) => DropdownMenuItem<String?>(
                      value: p.id,
                      child: Text('${p.name} (${p.brand})'),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _selectedProductId = v),
              ),

            const SizedBox(height: 10),

            // Servings field
            TextFormField(
              controller: _servingsController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*'))
              ],
              decoration: InputDecoration(
                labelText: l10n.healthServings,
                isDense: true,
              ),
            ),

            const SizedBox(height: 12),

            PrimaryButton(
              label: l10n.calendarAddSupplement,
              onPressed: _selectedProductId != null
                  ? () => _logSupplement(cubit)
                  : null,
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}

