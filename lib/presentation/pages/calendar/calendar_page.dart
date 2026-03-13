import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gym_tracker/assets/localization/app_localizations.dart';
import 'package:gym_tracker/core/app_router.gr.dart';
import 'package:gym_tracker/core/injection.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/cubit/calendar/calendar_cubit.dart';
import 'package:gym_tracker/model/attendance_day.dart';
import 'package:gym_tracker/model/supplement_log.dart';
import 'package:gym_tracker/model/supplement_product.dart';
import 'package:gym_tracker/model/training_type.dart';
import 'package:gym_tracker/presentation/controls/option_toggle.dart';
import 'package:gym_tracker/presentation/controls/primary_button.dart';

@RoutePage()
class CalendarPage extends StatefulWidget implements AutoRouteWrapper {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<CalendarCubit>(
      create: (_) => getIt<CalendarCubit>(),
      child: this,
    );
  }
}

class _CalendarPageState extends State<CalendarPage> {
  final ValueNotifier<bool> _yearlyView = ValueNotifier<bool>(false);
  final ValueNotifier<int> _year = ValueNotifier<int>(DateTime.now().year);
  final ValueNotifier<int> _month = ValueNotifier<int>(DateTime.now().month);

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final userId = _userId;
      if (userId == null) return;
      _loadMonth(userId);
    });
  }

  @override
  void dispose() {
    _yearlyView.dispose();
    _year.dispose();
    _month.dispose();
    super.dispose();
  }

  void _loadMonth(String userId) {
    context.read<CalendarCubit>().loadMonth(
      userId: userId,
      year: _year.value,
      month: _month.value,
    );
  }

  void _loadYear(String userId) {
    context.read<CalendarCubit>().loadYear(userId: userId, year: _year.value);
  }

  Future<void> _navigate(int delta) async {
    final userId = _userId;
    if (userId == null) return;

    if (_yearlyView.value) {
      _year.value = _year.value + delta;
      _loadYear(userId);
      return;
    }

    final next = DateTime(_year.value, _month.value + delta, 1);
    _year.value = next.year;
    _month.value = next.month;
    _loadMonth(userId);
  }

  Future<void> _toggleMode(bool yearly) async {
    final userId = _userId;
    if (userId == null) return;
    _yearlyView.value = yearly;
    if (yearly) {
      _loadYear(userId);
      return;
    }
    _loadMonth(userId);
  }

  Future<void> _openDaySheet(
    DateTime date, {
    required AttendanceDay? attendance,
    required List<SupplementLog> logs,
    required List<SupplementProduct> products,
    required List<TrainingType> types,
  }) async {
    final userId = _userId;
    if (userId == null) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return _CalendarDaySheet(
          date: date,
          initialAttendance: attendance,
          initialLogs: logs,
          products: products,
          types: types,
          onMarkAttended: (typeId, duration) {
            return context.read<CalendarCubit>().markAttended(
              userId: userId,
              date: _dateKey(date),
              workoutTypeId: typeId,
              durationMinutes: duration,
            );
          },
          onUpdateAttendance: (typeId, duration) {
            return context.read<CalendarCubit>().updateDay(
              userId: userId,
              date: _dateKey(date),
              workoutTypeId: typeId,
              durationMinutes: duration,
            );
          },
          onClearAttendance: () {
            return context.read<CalendarCubit>().clearDay(
              userId: userId,
              date: _dateKey(date),
            );
          },
          onAddSupplement: (product) {
            return context.read<CalendarCubit>().logSupplement(
              userId: userId,
              model: SupplementLog(
                id: '',
                date: _dateKey(date),
                productId: product.id,
                productName: product.name,
                productBrand: product.brand,
                servingsTaken: product.servingsPerDayDefault <= 0
                    ? 1
                    : product.servingsPerDayDefault,
                timestamp: DateTime.now(),
              ),
            );
          },
          onDeleteSupplement: (log) {
            return context.read<CalendarCubit>().deleteSupplementEntry(
              userId: userId,
              date: log.date,
              entryId: log.id,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = _userId;
    if (userId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.router.replace(const LoginRoute());
        }
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<CalendarCubit, BaseState>(
      listenWhen: (_, curr) =>
          curr is CalendarMonthLoadedState ||
          curr is CalendarYearLoadedState ||
          curr is CalendarDayMarkedState ||
          curr is CalendarDayClearedState ||
          curr is CalendarSupplementLoggedState ||
          curr is CalendarSupplementDeletedState ||
          curr is SomethingWentWrongState,
      listener: (ctx, state) {
        if (state is CalendarDayMarkedState ||
            state is CalendarDayClearedState ||
            state is CalendarSupplementLoggedState ||
            state is CalendarSupplementDeletedState) {
          if (_yearlyView.value) {
            _loadYear(userId);
          } else {
            _loadMonth(userId);
          }
          return;
        }

        if (state is SomethingWentWrongState) {
          ScaffoldMessenger.of(
            ctx,
          ).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: _calendarPageBackground(context),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListenableBuilder(
                listenable: Listenable.merge([_yearlyView, _year, _month]),
                builder: (_, __) {
                  final yearly = _yearlyView.value;
                  final selectedYear = _year.value;
                  final selectedMonth = _month.value;

                  final monthState = state is CalendarMonthLoadedState
                      ? state
                      : null;
                  final yearState = state is CalendarYearLoadedState
                      ? state
                      : null;

                  final title = yearly
                      ? '$selectedYear'
                      : '${_monthName(context, selectedMonth)} $selectedYear';

                  Widget content;
                  if (state is PendingState) {
                    content = const Center(child: CircularProgressIndicator());
                  } else if (yearly && yearState != null) {
                    content = _CalendarYearView(
                      year: selectedYear,
                      attendanceByMonth: yearState.attendanceByMonth,
                      supplementsByMonth: yearState.supplementsByMonth,
                      workoutTypes: yearState.workoutTypes,
                      onDayTap: (_) {},
                    );
                  } else if (!yearly && monthState != null) {
                    content = _CalendarMonthView(
                      year: selectedYear,
                      month: selectedMonth,
                      days: monthState.days,
                      supplementDates: monthState.healthLogs
                          .map((log) => log.date)
                          .toSet(),
                      workoutTypes: monthState.workoutTypes,
                      onDayTap: (_) {},
                    );
                  } else {
                    content = const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _CalendarNavButton(
                            icon: Icons.chevron_left,
                            onTap: () => _navigate(-1),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          _CalendarNavButton(
                            icon: Icons.chevron_right,
                            onTap: () => _navigate(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: _calendarPanelBackground(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: OptionToggle(
                          selectedValue: yearly ? 'yearly' : 'monthly',
                          items: [
                            OptionToggleItem(
                              value: 'monthly',
                              label: l10n.calendarMonthly,
                            ),
                            OptionToggleItem(
                              value: 'yearly',
                              label: l10n.calendarYearly,
                            ),
                          ],
                          onSelect: (value) => _toggleMode(value == 'yearly'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(child: content),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CalendarMonthView extends StatelessWidget {
  const _CalendarMonthView({
    required this.year,
    required this.month,
    required this.days,
    required this.supplementDates,
    required this.workoutTypes,
    required this.onDayTap,
  });

  final int year;
  final int month;
  final List<AttendanceDay> days;
  final Set<String> supplementDates;
  final List<TrainingType> workoutTypes;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final attendanceByDate = {for (final day in days) day.date: day};
    final cells = _buildMonthCells(
      year: year,
      month: month,
      attendanceByDate: attendanceByDate,
      supplementDates: supplementDates,
    );

    return Column(
      children: [
        Row(
          children: List.generate(7, (index) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  _weekdayShort(context, index + 1),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: _calendarMutedText(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }),
        ),
        Expanded(
          child: GridView.builder(
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemBuilder: (_, index) {
              final cell = cells[index];
              return _CalendarDayCell(
                cell: cell,
                workoutType: cell.attendance?.trainingTypeId == null
                    ? null
                    : _typeById(workoutTypes, cell.attendance!.trainingTypeId!),
                onTap: () => onDayTap(cell.date),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CalendarYearView extends StatelessWidget {
  const _CalendarYearView({
    required this.year,
    required this.attendanceByMonth,
    required this.supplementsByMonth,
    required this.workoutTypes,
    required this.onDayTap,
  });

  final int year;
  final Map<int, List<AttendanceDay>> attendanceByMonth;
  final Map<int, List<SupplementLog>> supplementsByMonth;
  final List<TrainingType> workoutTypes;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 12,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final month = index + 1;
        final monthDays = attendanceByMonth[month] ?? const <AttendanceDay>[];
        final supplements =
            supplementsByMonth[month] ?? const <SupplementLog>[];
        final supplementDates = supplements.map((log) => log.date).toSet();
        final attendanceByDate = {for (final day in monthDays) day.date: day};
        final cells = _buildMonthCells(
          year: year,
          month: month,
          attendanceByDate: attendanceByDate,
          supplementDates: supplementDates,
        );

        return Container(
          decoration: BoxDecoration(
            color: _calendarPanelBackground(context),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
            child: Column(
              children: [
                Text(
                  _monthName(context, month),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(7, (weekday) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          _weekdayShort(context, weekday + 1),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: _calendarMutedText(context),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 4),
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: cells.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 3,
                    mainAxisSpacing: 3,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (_, i) {
                    final cell = cells[i];
                    final workoutType = cell.attendance?.trainingTypeId == null
                        ? null
                        : _typeById(
                            workoutTypes,
                            cell.attendance!.trainingTypeId!,
                          );

                    return _CalendarDayCell(
                      cell: cell,
                      workoutType: workoutType,
                      onTap: () => onDayTap(cell.date),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.cell,
    required this.workoutType,
    required this.onTap,
  });

  final _CalendarCell cell;
  final TrainingType? workoutType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasWorkout = cell.attendance != null;
    final hasSupplement = cell.hasSupplement;
    final isActive = hasWorkout || hasSupplement;
    final baseTextColor = cell.isCurrentMonth
        ? cs.onSurface
        : _calendarMutedText(context);
    final textColor = isActive ? const Color(0xFFFFFFFF) : baseTextColor;

    Widget tile = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: _calendarDayBackground(
            context,
            isCurrentMonth: cell.isCurrentMonth,
            hasWorkout: hasWorkout,
            hasSupplement: hasSupplement,
          ),
          border: cell.isToday ? Border.all(color: cs.primary, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${cell.date.day}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (workoutType != null)
                  Text(
                    workoutType!.icon ?? '•',
                    style: const TextStyle(fontSize: 11),
                  )
                else if (hasWorkout)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFFFFF) : cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasSupplement) ...[
                  const SizedBox(width: 2),
                  const Text('💊', style: TextStyle(fontSize: 10)),
                ],
              ],
            ),
          ],
        ),
      ),
    );

    if (!cell.isCurrentMonth) {
      tile = Opacity(opacity: 0.3, child: tile);
    }

    return tile;
  }
}

class _CalendarNavButton extends StatelessWidget {
  const _CalendarNavButton({required this.icon, required this.onTap});

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
          color: _calendarPanelBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withValues(alpha: 0.28)),
        ),
        child: Icon(icon),
      ),
    );
  }
}

class _CalendarDaySheet extends StatefulWidget {
  const _CalendarDaySheet({
    required this.date,
    required this.initialAttendance,
    required this.initialLogs,
    required this.products,
    required this.types,
    required this.onMarkAttended,
    required this.onUpdateAttendance,
    required this.onClearAttendance,
    required this.onAddSupplement,
    required this.onDeleteSupplement,
  });

  final DateTime date;
  final AttendanceDay? initialAttendance;
  final List<SupplementLog> initialLogs;
  final List<SupplementProduct> products;
  final List<TrainingType> types;

  final Future<void> Function(String? typeId, int? durationMinutes)
  onMarkAttended;
  final Future<void> Function(String? typeId, int? durationMinutes)
  onUpdateAttendance;
  final Future<void> Function() onClearAttendance;
  final Future<void> Function(SupplementProduct product) onAddSupplement;
  final Future<void> Function(SupplementLog log) onDeleteSupplement;

  @override
  State<_CalendarDaySheet> createState() => _CalendarDaySheetState();
}

class _CalendarDaySheetState extends State<_CalendarDaySheet> {
  ValueNotifier<String?>? _selectedTypeId;
  ValueNotifier<String?>? _selectedProductId;
  TextEditingController? _durationController;
  PageController? _supplementPageController;
  int _supplementPageIndex = 0;
  bool _editingWorkout = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _selectedTypeId = ValueNotifier<String?>(
      widget.initialAttendance?.trainingTypeId,
    );
    _selectedProductId = ValueNotifier<String?>(null);
    _durationController = TextEditingController(
      text: widget.initialAttendance?.durationMinutes?.toString() ?? '',
    );
    _supplementPageController = PageController();
  }

  @override
  void dispose() {
    _selectedTypeId?.dispose();
    _selectedProductId?.dispose();
    _durationController?.dispose();
    _supplementPageController?.dispose();
    super.dispose();
  }

  List<List<SupplementLog>> _supplementPages(List<SupplementLog> logs) {
    const perPage = 2;
    if (logs.isEmpty) return const <List<SupplementLog>>[];
    final pages = <List<SupplementLog>>[];
    for (int i = 0; i < logs.length; i += perPage) {
      pages.add(logs.skip(i).take(perPage).toList(growable: false));
    }
    return pages;
  }

  List<int> _visibleSupplementDots(int totalPages, int currentPage) {
    if (totalPages <= 3) {
      return List<int>.generate(totalPages, (index) => index);
    }
    if (currentPage <= 0) {
      return const <int>[0, 1, 2];
    }
    if (currentPage >= totalPages - 1) {
      return <int>[totalPages - 3, totalPages - 2, totalPages - 1];
    }
    return <int>[currentPage - 1, currentPage, currentPage + 1];
  }

  String _formatSupplementTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final hh = dateTime.hour.toString().padLeft(2, '0');
    final mm = dateTime.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  int? _parseDuration() {
    final raw = _durationController?.text.trim() ?? '';
    if (raw.isEmpty) return null;
    final value = int.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _submitWorkout() async {
    if (_busy) return;
    setState(() => _busy = true);
    final duration = _parseDuration();
    final typeId = _selectedTypeId?.value;

    if (widget.initialAttendance == null) {
      await widget.onMarkAttended(typeId, duration);
    } else {
      await widget.onUpdateAttendance(typeId, duration);
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _clearWorkout() async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onClearAttendance();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _addSupplement() async {
    if (_busy) return;
    final productId = _selectedProductId?.value;
    if (productId == null) return;
    final product = _productById(widget.products, productId);
    if (product == null) return;

    setState(() => _busy = true);
    await widget.onAddSupplement(product);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteSupplement(SupplementLog log) async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onDeleteSupplement(log);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selectedTypeId = _selectedTypeId;
    final selectedProductId = _selectedProductId;
    final durationController = _durationController;
    if (selectedTypeId == null ||
        selectedProductId == null ||
        durationController == null) {
      return const SizedBox.shrink();
    }

    final dateTitle =
        '${widget.date.day} ${_monthShort(context, widget.date.month)} ${widget.date.year}';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: math.min(500.0, MediaQuery.of(context).size.height * 0.6),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            dateTitle,
                            style: tt.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TabBar(
                      tabs: [
                        Tab(text: l10n.calendarWorkoutTab),
                        Tab(text: l10n.calendarHealthTab),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.initialAttendance != null &&
                                    !_editingWorkout) ...[
                                  Center(
                                    child: Text(
                                      '${l10n.calendarWentToGym} 💪',
                                      style: tt.titleLarge?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ValueListenableBuilder<String?>(
                                    valueListenable: selectedTypeId,
                                    builder: (_, typeId, __) {
                                      final type = typeId == null
                                          ? null
                                          : _typeById(widget.types, typeId);
                                      final durationText = durationController
                                          .text
                                          .trim();

                                      return Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: cs.outlineVariant.withValues(
                                              alpha: 0.65,
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type?.icon ?? '🏋️',
                                              style: const TextStyle(
                                                fontSize: 21,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    type?.name ??
                                                        l10n.calendarNoType,
                                                    style: tt.titleLarge
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  if (durationText.isNotEmpty)
                                                    Text(
                                                      '⏱ ${durationText}min',
                                                      style: tt.bodyLarge
                                                          ?.copyWith(
                                                            color: cs
                                                                .onSurfaceVariant,
                                                          ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              visualDensity:
                                                  VisualDensity.compact,
                                              constraints: const BoxConstraints(
                                                minWidth: 28,
                                                minHeight: 28,
                                              ),
                                              padding: EdgeInsets.zero,
                                              onPressed: _busy
                                                  ? null
                                                  : () {
                                                      setState(() {
                                                        _editingWorkout = true;
                                                      });
                                                    },
                                              icon: Icon(
                                                Icons.edit_outlined,
                                                size: 16,
                                                color: const Color(0xFFF2A07F),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFFEF4444,
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      onPressed: _busy ? null : _clearWorkout,
                                      child: const Text('Remove'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        side: BorderSide(
                                          color: cs.outlineVariant,
                                        ),
                                        foregroundColor: cs.onSurface,
                                      ),
                                      onPressed: _busy
                                          ? null
                                          : () => Navigator.of(context).pop(),
                                      child: const Text('Cancel'),
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    widget.initialAttendance == null
                                        ? l10n.calendarMarkAttended
                                        : l10n.calendarWentToGym,
                                    style: tt.titleMedium,
                                  ),
                                  const SizedBox(height: 12),
                                  ValueListenableBuilder<String?>(
                                    valueListenable: selectedTypeId,
                                    builder: (_, typeId, __) {
                                      final uniqueTypes =
                                          <String, TrainingType>{
                                            for (final t in widget.types)
                                              t.id: t,
                                          }.values.toList(growable: false);
                                      final safeTypeId =
                                          uniqueTypes.any((t) => t.id == typeId)
                                          ? typeId
                                          : null;
                                      final pickerMaxHeight = math.min(
                                        400.0,
                                        MediaQuery.of(context).size.height *
                                            0.4,
                                      );

                                      return Align(
                                        alignment: Alignment.center,
                                        child: FractionallySizedBox(
                                          widthFactor: 0.7,
                                          child: DropdownButtonFormField<String>(
                                            initialValue: safeTypeId,
                                            decoration: InputDecoration(
                                              labelText:
                                                  l10n.calendarTrainingType,
                                            ),
                                            menuMaxHeight: pickerMaxHeight,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            items: [
                                              DropdownMenuItem<String>(
                                                value: null,
                                                child: Text(
                                                  l10n.calendarNoType,
                                                ),
                                              ),
                                              ...uniqueTypes.map(
                                                (
                                                  type,
                                                ) => DropdownMenuItem<String>(
                                                  value: type.id,
                                                  child: Text(
                                                    '${type.icon ?? ''} ${type.name}'
                                                        .trim(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                            onChanged: _busy
                                                ? null
                                                : (value) {
                                                    selectedTypeId.value =
                                                        value;
                                                  },
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: durationController,
                                    enabled: !_busy,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: l10n.calendarDurationMinutes,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      if (widget.initialAttendance != null) ...[
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: _busy
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _editingWorkout = false;
                                                    });
                                                  },
                                            child: const Text('Cancel'),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                      ],
                                      Expanded(
                                        child: PrimaryButton(
                                          label: l10n.calendarSave,
                                          isLoading: _busy,
                                          onPressed: _busy
                                              ? null
                                              : _submitWorkout,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.initialLogs.isEmpty)
                                  Text(
                                    l10n.calendarNoHealthLogs,
                                    style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  )
                                else ...[
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        'Supplements taken 💊',
                                        style: tt.titleMedium,
                                      ),
                                    ),
                                  ),
                                  Builder(
                                    builder: (_) {
                                      final pages = _supplementPages(
                                        widget.initialLogs,
                                      );
                                      final controller =
                                          _supplementPageController;
                                      if (pages.isEmpty || controller == null) {
                                        return const SizedBox.shrink();
                                      }

                                      const double cardHeight = 128;
                                      final pageHeight = pages.first.length > 1
                                          ? (cardHeight * 2) + 8
                                          : cardHeight;

                                      return Column(
                                        children: [
                                          SizedBox(
                                            height: pageHeight,
                                            child: PageView.builder(
                                              controller: controller,
                                              itemCount: pages.length,
                                              onPageChanged: (index) {
                                                if (!mounted) return;
                                                setState(() {
                                                  _supplementPageIndex = index;
                                                });
                                              },
                                              itemBuilder: (_, pageIndex) {
                                                final pageLogs =
                                                    pages[pageIndex];
                                                return Column(
                                                  children: pageLogs
                                                      .map(
                                                        (log) => Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                bottom:
                                                                    log ==
                                                                        pageLogs
                                                                            .last
                                                                    ? 0
                                                                    : 8,
                                                              ),
                                                          padding:
                                                              const EdgeInsets.all(
                                                                12,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: cs
                                                                .surfaceContainerHighest,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                            border: Border.all(
                                                              color: cs
                                                                  .outlineVariant,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Padding(
                                                                padding:
                                                                    EdgeInsets.only(
                                                                      top: 2,
                                                                    ),
                                                                child: Text(
                                                                  '💊',
                                                                  style:
                                                                      TextStyle(
                                                                        fontSize:
                                                                            20,
                                                                      ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                width: 10,
                                                              ),
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      log.productName ??
                                                                          '-',
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: tt
                                                                          .titleMedium,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 2,
                                                                    ),
                                                                    Text(
                                                                      '⏱ ${_formatSupplementTime(log.timestamp)}',
                                                                      style: tt
                                                                          .bodyMedium,
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                    SizedBox(
                                                                      width: double
                                                                          .infinity,
                                                                      child: FilledButton(
                                                                        style: FilledButton.styleFrom(
                                                                          backgroundColor: const Color(
                                                                            0xFFEF4444,
                                                                          ),
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius: BorderRadius.circular(
                                                                              8,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            _busy
                                                                            ? null
                                                                            : () => _deleteSupplement(
                                                                                log,
                                                                              ),
                                                                        child: const Text(
                                                                          'Remove',
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                      .toList(growable: false),
                                                );
                                              },
                                            ),
                                          ),
                                          if (pages.length > 1) ...[
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children:
                                                  _visibleSupplementDots(
                                                        pages.length,
                                                        _supplementPageIndex,
                                                      )
                                                      .map((index) {
                                                        final active =
                                                            _supplementPageIndex ==
                                                            index;
                                                        return GestureDetector(
                                                          onTap: () {
                                                            final controller =
                                                                _supplementPageController;
                                                            if (controller ==
                                                                null) {
                                                              return;
                                                            }
                                                            controller.animateToPage(
                                                              index,
                                                              duration:
                                                                  const Duration(
                                                                    milliseconds:
                                                                        220,
                                                                  ),
                                                              curve: Curves
                                                                  .easeOut,
                                                            );
                                                          },
                                                          child: AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      200,
                                                                ),
                                                            margin:
                                                                const EdgeInsets.symmetric(
                                                                  horizontal: 3,
                                                                ),
                                                            width: active
                                                                ? 18
                                                                : 8,
                                                            height: 8,
                                                            decoration: BoxDecoration(
                                                              color: active
                                                                  ? Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary
                                                                  : cs.outlineVariant,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    999,
                                                                  ),
                                                            ),
                                                          ),
                                                        );
                                                      })
                                                      .toList(growable: false),
                                            ),
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                                const SizedBox(height: 12),
                                ValueListenableBuilder<String?>(
                                  valueListenable: selectedProductId,
                                  builder: (_, productId, __) {
                                    final uniqueProducts =
                                        <String, SupplementProduct>{
                                          for (final p in widget.products)
                                            p.id: p,
                                        }.values.toList(growable: false);
                                    final safeProductId =
                                        uniqueProducts.any(
                                          (p) => p.id == productId,
                                        )
                                        ? productId
                                        : null;

                                    if (productId != null &&
                                        safeProductId == null) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            if (selectedProductId.value !=
                                                null) {
                                              selectedProductId.value = null;
                                            }
                                          });
                                    }

                                    if (uniqueProducts.isEmpty) {
                                      return Text(
                                        'No supplement products available.',
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      );
                                    }

                                    final pickerMaxHeight = math.min(
                                      400.0,
                                      MediaQuery.of(context).size.height * 0.4,
                                    );

                                    return Align(
                                      alignment: Alignment.center,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.7,
                                        child: DropdownButtonFormField<String>(
                                          initialValue: safeProductId,
                                          decoration: InputDecoration(
                                            labelText:
                                                l10n.calendarSelectProduct,
                                          ),
                                          menuMaxHeight: pickerMaxHeight,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          items: uniqueProducts
                                              .map(
                                                (product) =>
                                                    DropdownMenuItem<String>(
                                                      value: product.id,
                                                      child: Text(product.name),
                                                    ),
                                              )
                                              .toList(growable: false),
                                          onChanged: _busy
                                              ? null
                                              : (value) {
                                                  selectedProductId.value =
                                                      value;
                                                },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 12),
                                PrimaryButton(
                                  label: l10n.calendarAddSupplement,
                                  isLoading: _busy,
                                  onPressed: _busy || widget.products.isEmpty
                                      ? null
                                      : _addSupplement,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarCell {
  const _CalendarCell({
    required this.date,
    required this.isCurrentMonth,
    required this.isToday,
    required this.attendance,
    required this.hasSupplement,
  });

  final DateTime date;
  final bool isCurrentMonth;
  final bool isToday;
  final AttendanceDay? attendance;
  final bool hasSupplement;
}

List<_CalendarCell> _buildMonthCells({
  required int year,
  required int month,
  required Map<String, AttendanceDay> attendanceByDate,
  required Set<String> supplementDates,
}) {
  final firstDay = DateTime(year, month, 1);
  final daysInMonth = DateTime(year, month + 1, 0).day;
  final startOffset = (firstDay.weekday + 6) % 7;

  final cells = <_CalendarCell>[];
  final today = DateTime.now();

  for (int i = startOffset; i > 0; i--) {
    final date = DateTime(year, month, 1 - i);
    final key = _dateKey(date);
    cells.add(
      _CalendarCell(
        date: date,
        isCurrentMonth: false,
        isToday: _isSameDate(date, today),
        attendance: attendanceByDate[key],
        hasSupplement: supplementDates.contains(key),
      ),
    );
  }

  for (int day = 1; day <= daysInMonth; day++) {
    final date = DateTime(year, month, day);
    final key = _dateKey(date);
    cells.add(
      _CalendarCell(
        date: date,
        isCurrentMonth: true,
        isToday: _isSameDate(date, today),
        attendance: attendanceByDate[key],
        hasSupplement: supplementDates.contains(key),
      ),
    );
  }

  while (cells.length < 42) {
    final date = DateTime(
      year,
      month,
      daysInMonth + (cells.length - (startOffset + daysInMonth)) + 1,
    );
    final key = _dateKey(date);
    cells.add(
      _CalendarCell(
        date: date,
        isCurrentMonth: false,
        isToday: _isSameDate(date, today),
        attendance: attendanceByDate[key],
        hasSupplement: supplementDates.contains(key),
      ),
    );
  }

  return cells;
}

Color _calendarPageBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF08193F)
      : const Color(0xFFF1F3F7);
}

Color _calendarPanelBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1A2A49)
      : const Color(0xFFF8F9FB);
}

Color _calendarMutedText(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF86A0C6)
      : const Color(0xFF7D8798);
}

Color _calendarDayBackground(
  BuildContext context, {
  required bool isCurrentMonth,
  required bool hasWorkout,
  required bool hasSupplement,
}) {
  if (hasWorkout && hasSupplement) {
    return const Color(0xFF06B6D4);
  }
  if (hasWorkout) {
    return const Color(0xFF3B82F6);
  }
  if (hasSupplement) {
    return const Color(0xFF10B981);
  }
  return Theme.of(context).brightness == Brightness.dark
      ? const Color(0xFF1E293B)
      : Colors.white;
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _monthName(BuildContext context, int month) {
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

String _monthShort(BuildContext context, int month) {
  final value = _monthName(context, month);
  if (value.length <= 3) return value;
  return value.substring(0, 3);
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

TrainingType? _typeById(List<TrainingType> types, String id) {
  for (final type in types) {
    if (type.id == id) return type;
  }
  return null;
}

SupplementProduct? _productById(List<SupplementProduct> products, String id) {
  for (final product in products) {
    if (product.id == id) return product;
  }
  return null;
}

AttendanceDay? _findAttendanceForDate(
  DateTime date,
  Map<int, List<AttendanceDay>> attendanceByMonth,
) {
  final key = _dateKey(date);
  final monthData = attendanceByMonth[date.month] ?? const <AttendanceDay>[];
  for (final day in monthData) {
    if (day.date == key) return day;
  }
  return null;
}

List<SupplementLog> _findLogsForDate(
  DateTime date,
  Map<int, List<SupplementLog>> supplementsByMonth,
) {
  final key = _dateKey(date);
  final monthData = supplementsByMonth[date.month] ?? const <SupplementLog>[];
  return monthData.where((log) => log.date == key).toList(growable: false);
}
