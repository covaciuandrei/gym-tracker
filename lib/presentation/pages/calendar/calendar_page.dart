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
import 'package:gym_tracker/presentation/controls/gym_app_bar.dart';
import 'package:gym_tracker/presentation/controls/option_toggle.dart';
import 'package:gym_tracker/presentation/validators/number_validator.dart';
import 'package:gym_tracker/service/health/health_service.dart';

@RoutePage()
class CalendarPage extends StatefulWidget implements AutoRouteWrapper {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<CalendarCubit>(create: (_) => getIt<CalendarCubit>(), child: this);
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
    context.read<CalendarCubit>().loadMonth(userId: userId, year: _year.value, month: _month.value);
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

  Future<void> _showDaySheet(BuildContext context, DateTime date, BaseState state) async {
    final userId = _userId;
    if (userId == null) return;

    List<AttendanceDay> days = [];
    List<SupplementLog> healthLogs = [];
    List<SupplementProduct> products = [];
    List<TrainingType> workoutTypes = [];

    if (state is CalendarMonthLoadedState) {
      days = state.days;
      healthLogs = state.healthLogs;
      products = state.products;
      workoutTypes = state.workoutTypes;
    } else if (state is CalendarYearLoadedState) {
      final monthDays = state.attendanceByMonth[date.month] ?? [];
      final monthSupplements = state.supplementsByMonth[date.month] ?? [];
      days = monthDays;
      healthLogs = monthSupplements;
      workoutTypes = state.workoutTypes;

      try {
        products = await getIt<HealthService>().watchAllProducts().first;
      } catch (_) {
        products = [];
      }
    }

    final dateKey = _dateKey(date);
    final attendance = days.where((d) => d.date == dateKey).firstOrNull;
    final dayLogs = healthLogs.where((log) => log.date == dateKey).toList();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      builder: (_) => _CalendarDaySheet(
        date: date,
        initialAttendance: attendance,
        initialLogs: dayLogs,
        products: products,
        types: workoutTypes,
        onMarkAttended: (typeId, duration) async {
          final day = AttendanceDay(
            date: dateKey,
            timestamp: DateTime.now(),
            trainingTypeId: typeId,
            durationMinutes: duration,
          );
          await context.read<CalendarCubit>().markDay(userId: userId, day: day);
        },
        onUpdateAttendance: (typeId, duration) async {
          final day = AttendanceDay(
            date: dateKey,
            timestamp: attendance?.timestamp ?? DateTime.now(),
            trainingTypeId: typeId,
            durationMinutes: duration,
          );
          await context.read<CalendarCubit>().markDay(userId: userId, day: day);
        },
        onClearAttendance: () async {
          await context.read<CalendarCubit>().clearDay(userId: userId, date: dateKey);
        },
        onAddSupplement: (product) async {
          final log = SupplementLog(
            id: '',
            date: dateKey,
            timestamp: DateTime.now(),
            productId: product.id,
            productName: product.name,
            servingsTaken: 1,
          );
          await context.read<CalendarCubit>().logSupplement(userId: userId, model: log);
        },
        onDeleteSupplement: (log) async {
          await context.read<CalendarCubit>().deleteSupplementEntry(userId: userId, date: dateKey, entryId: log.id);
        },
      ),
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
          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(l10n.errorsUnknown)));
        }
      },
      builder: (ctx, state) {
        return Scaffold(
          backgroundColor: _calendarPageBackground(context),
          appBar: GymAppBar(title: l10n.calendarTitle, showBackButton: false),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ListenableBuilder(
                listenable: Listenable.merge([_yearlyView, _year, _month]),
                builder: (_, _) {
                  final yearly = _yearlyView.value;
                  final selectedYear = _year.value;
                  final selectedMonth = _month.value;

                  final monthState = state is CalendarMonthLoadedState ? state : null;
                  final yearState = state is CalendarYearLoadedState ? state : null;

                  final title = yearly ? '$selectedYear' : '${_monthName(context, selectedMonth)} $selectedYear';

                  Widget content;
                  if (state is PendingState) {
                    content = const Center(child: CircularProgressIndicator());
                  } else if (yearly && yearState != null) {
                    content = _CalendarYearView(
                      year: selectedYear,
                      attendanceByMonth: yearState.attendanceByMonth,
                      supplementsByMonth: yearState.supplementsByMonth,
                      workoutTypes: yearState.workoutTypes,
                      onDayTap: (date) => _showDaySheet(context, date, yearState),
                    );
                  } else if (!yearly && monthState != null) {
                    content = _CalendarMonthView(
                      year: selectedYear,
                      month: selectedMonth,
                      days: monthState.days,
                      supplementDates: monthState.healthLogs.map((log) => log.date).toSet(),
                      workoutTypes: monthState.workoutTypes,
                      onDayTap: (date) => _showDaySheet(context, date, monthState),
                    );
                  } else {
                    content = const Center(child: CircularProgressIndicator());
                  }

                  return Column(
                    children: [
                      _CalendarHeader(title: title, onPrevious: () => _navigate(-1), onNext: () => _navigate(1)),
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
                            OptionToggleItem(value: 'monthly', label: l10n.calendarMonthly),
                            OptionToggleItem(value: 'yearly', label: l10n.calendarYearly),
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
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: _calendarMutedText(context), fontWeight: FontWeight.w600),
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
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        final month = index + 1;
        final monthDays = attendanceByMonth[month] ?? const <AttendanceDay>[];
        final supplements = supplementsByMonth[month] ?? const <SupplementLog>[];
        final supplementDates = supplements.map((log) => log.date).toSet();
        final attendanceByDate = {for (final day in monthDays) day.date: day};
        final cells = _buildMonthCells(
          year: year,
          month: month,
          attendanceByDate: attendanceByDate,
          supplementDates: supplementDates,
        );

        return Container(
          decoration: BoxDecoration(color: _calendarPanelBackground(context), borderRadius: BorderRadius.circular(14)),
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
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                        : _typeById(workoutTypes, cell.attendance!.trainingTypeId!);

                    return _CalendarDayCell(cell: cell, workoutType: workoutType, onTap: () => onDayTap(cell.date));
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
  const _CalendarDayCell({required this.cell, required this.workoutType, required this.onTap});

  final _CalendarCell cell;
  final TrainingType? workoutType;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasWorkout = cell.attendance != null;
    final hasSupplement = cell.hasSupplement;
    final isActive = hasWorkout || hasSupplement;
    final baseTextColor = cell.isCurrentMonth ? cs.onSurface : _calendarMutedText(context);
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
            Text('${cell.date.day}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (workoutType != null)
                  Text(workoutType!.icon ?? '•', style: const TextStyle(fontSize: 12))
                else if (hasWorkout)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFFFFFFFF) : cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                if (hasSupplement) ...[const SizedBox(width: 4), const Text('💊', style: TextStyle(fontSize: 12))],
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

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.title, required this.onPrevious, required this.onNext});

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CalendarNavButton(icon: Icons.chevron_left, onTap: onPrevious),
        Expanded(
          child: Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleLarge),
        ),
        _CalendarNavButton(icon: Icons.chevron_right, onTap: onNext),
      ],
    );
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
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline),
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

  final Future<void> Function(String? typeId, int? durationMinutes) onMarkAttended;
  final Future<void> Function(String? typeId, int? durationMinutes) onUpdateAttendance;
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
  bool _hasValidationError = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _supplementFormKey = GlobalKey<FormState>();

  // Current state that can be updated when data changes
  late AttendanceDay? _currentAttendance;
  List<SupplementLog> _currentLogs = [];

  @override
  void initState() {
    super.initState();
    _currentAttendance = widget.initialAttendance;
    _currentLogs = List.from(widget.initialLogs);
    _selectedTypeId = ValueNotifier<String?>(widget.initialAttendance?.trainingTypeId);
    _selectedProductId = ValueNotifier<String?>(null);
    _durationController = TextEditingController(text: widget.initialAttendance?.durationMinutes?.toString() ?? '');
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

  int? _parseDuration() {
    final raw = _durationController?.text.trim() ?? '';
    if (raw.isEmpty) return null;
    final value = int.tryParse(raw);
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _submitWorkout() async {
    if (_busy) return;

    // Validate the form
    final isValid = _formKey.currentState!.validate();
    setState(() {
      _hasValidationError = !isValid;
    });

    if (!isValid) {
      return;
    }

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
    // Update local state instead of closing
    if (mounted) {
      setState(() {
        _currentAttendance = null;
        _editingWorkout = false;
        _busy = false;
        _selectedTypeId?.value = null;
        _durationController?.text = '';
      });
    }
  }

  Future<void> _addSupplement() async {
    if (_busy) return;

    // Validate the supplement form
    final isSupplementValid = _supplementFormKey.currentState?.validate() ?? false;
    if (!isSupplementValid) {
      setState(() {
        _hasValidationError = true;
      });
      return;
    }

    final productId = _selectedProductId?.value;
    if (productId == null) return;
    final product = _productById(widget.products, productId);
    if (product == null) return;

    setState(() => _busy = true);

    // Create the new supplement log
    final dateKey = _dateKey(widget.date);
    final newLog = SupplementLog(
      id: '', // Will be set by the service
      date: dateKey,
      timestamp: DateTime.now(),
      productId: product.id,
      productName: product.name,
      servingsTaken: 1,
    );

    await widget.onAddSupplement(product);

    // Update local state with the new supplement
    if (mounted) {
      setState(() {
        _currentLogs.add(newLog);
        _busy = false;
        _selectedProductId?.value = null;
        _hasValidationError = false;

        // If we now have 3+ supplements, reset page index to show the new supplement
        // Only animate if the PageController is attached (i.e., carousel is visible)
        if (_currentLogs.length >= 3 && _supplementPageController?.hasClients == true) {
          _supplementPageIndex = (_currentLogs.length - 1) ~/ 2;
          _supplementPageController?.animateToPage(
            _supplementPageIndex,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _deleteSupplement(SupplementLog log) async {
    if (_busy) return;
    setState(() => _busy = true);
    await widget.onDeleteSupplement(log);
    // Update local state instead of closing
    if (mounted) {
      setState(() {
        _currentLogs.remove(log);
        _busy = false;
        // Adjust page index if necessary - only if carousel is still visible
        if (_currentLogs.length >= 3 && _supplementPageController?.hasClients == true) {
          if (_supplementPageIndex > 0 && _supplementPageIndex >= (_currentLogs.length / 2).ceil() - 1) {
            _supplementPageIndex = math.max(0, (_currentLogs.length / 2).ceil() - 1);
            _supplementPageController?.animateToPage(
              _supplementPageIndex,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }
  }

  String _formatDuration(int? minutes) {
    if (minutes == null || minutes <= 0) return '';
    if (minutes < 60) return '${minutes}min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final selectedTypeId = _selectedTypeId;
    final selectedProductId = _selectedProductId;
    final durationController = _durationController;
    if (selectedTypeId == null || selectedProductId == null || durationController == null) {
      return const SizedBox.shrink();
    }

    final dateTitle = '${widget.date.day} ${_monthShort(context, widget.date.month)} ${widget.date.year}';

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: _dialogMaxHeightWithValidation(context, _currentAttendance, _currentLogs, _hasValidationError),
        ),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(color: cs.surface, borderRadius: BorderRadius.circular(20)),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTabController(
                length: 2,
                child: Builder(
                  builder: (tabContext) {
                    final tabController = DefaultTabController.of(tabContext);
                    return Column(
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
                            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: TabBar(
                            dividerHeight: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            controller: tabController,
                            labelColor: Theme.of(context).colorScheme.onPrimaryContainer,

                            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                            indicatorColor: Theme.of(context).colorScheme.primary,
                            indicatorWeight: 0,
                            labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                            unselectedLabelStyle: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                            indicatorSize: TabBarIndicatorSize.tab,
                            indicator: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tabs: [
                              Tab(text: l10n.calendarWorkoutTab, height: 28),
                              Tab(text: l10n.calendarHealthTab, height: 28),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        Expanded(
                          child: TabBarView(
                            children: [
                              SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (_currentAttendance != null && !_editingWorkout) ...[
                                      Center(
                                        child: Text(
                                          '${l10n.calendarWentToGym} 💪',
                                          style: tt.titleLarge?.copyWith(color: cs.onSurfaceVariant),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      ValueListenableBuilder<String?>(
                                        valueListenable: selectedTypeId,
                                        builder: (_, typeId, _) {
                                          final type = typeId == null ? null : _typeById(widget.types, typeId);

                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(14),
                                            decoration: BoxDecoration(
                                              color: cs.surfaceContainerHighest,
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
                                            ),
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(type?.icon ?? '🏋️', style: const TextStyle(fontSize: 21)),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        type?.name ?? l10n.calendarNoType,
                                                        style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (_currentAttendance?.durationMinutes != null)
                                                        Text(
                                                          '⏱ ${_formatDuration(_currentAttendance!.durationMinutes)}',
                                                          style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                IconButton(
                                                  visualDensity: VisualDensity.compact,
                                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
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
                                            backgroundColor: const Color(0xFFEF4444),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            side: BorderSide(color: cs.outlineVariant),
                                            foregroundColor: cs.onSurface,
                                          ),
                                          onPressed: _busy ? null : () => Navigator.of(context).pop(),
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                    ] else ...[
                                      Form(
                                        key: _formKey,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Text(
                                                'Did you go to the gym?',
                                                style: tt.titleLarge?.copyWith(
                                                  color: cs.onSurfaceVariant,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            ValueListenableBuilder<String?>(
                                              valueListenable: selectedTypeId,
                                              builder: (_, typeId, _) {
                                                final uniqueTypes = <String, TrainingType>{
                                                  for (final t in widget.types) t.id: t,
                                                }.values.toList(growable: false);
                                                final safeTypeId = uniqueTypes.any((t) => t.id == typeId)
                                                    ? typeId
                                                    : null;
                                                final pickerMaxHeight = math.min(
                                                  400.0,
                                                  MediaQuery.of(context).size.height * 0.4,
                                                );

                                                return DropdownButtonFormField<String>(
                                                  initialValue: safeTypeId,
                                                  decoration: InputDecoration(
                                                    hintText: '-- Select type --',
                                                    labelText: 'Select Workout Type (optional)',
                                                    filled: true,
                                                    fillColor: cs.surfaceContainerHighest,
                                                    contentPadding: const EdgeInsets.symmetric(
                                                      horizontal: 14,
                                                      vertical: 12,
                                                    ),
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: BorderSide(color: cs.outlineVariant),
                                                    ),
                                                    enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: BorderSide(
                                                        color: cs.outlineVariant.withValues(alpha: 0.6),
                                                      ),
                                                    ),
                                                  ),
                                                  menuMaxHeight: pickerMaxHeight,
                                                  borderRadius: BorderRadius.circular(16),
                                                  items: [
                                                    DropdownMenuItem<String>(
                                                      value: null,
                                                      child: Text('-- Select type --'),
                                                    ),
                                                    ...uniqueTypes.map(
                                                      (type) => DropdownMenuItem<String>(
                                                        value: type.id,
                                                        child: Text('${type.icon ?? ''} ${type.name}'.trim()),
                                                      ),
                                                    ),
                                                  ],
                                                  onChanged: _busy
                                                      ? null
                                                      : (value) {
                                                          selectedTypeId.value = value;
                                                        },
                                                );
                                              },
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Duration:',
                                              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: TextFormField(
                                                    controller: durationController,
                                                    enabled: !_busy,
                                                    keyboardType: TextInputType.number,
                                                    validator: NumberValidator.validatePositiveNumber,
                                                    onChanged: (value) {
                                                      // Trigger form validation on change to clear error when input becomes valid/empty
                                                      final isValid = _formKey.currentState?.validate() ?? false;
                                                      setState(() {
                                                        _hasValidationError = !isValid;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText: 'e.g. 60',
                                                      labelText: 'Duration (optional)',
                                                      filled: true,
                                                      fillColor: cs.surfaceContainerHighest,
                                                      contentPadding: const EdgeInsets.symmetric(
                                                        horizontal: 14,
                                                        vertical: 12,
                                                      ),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: BorderSide(color: cs.outlineVariant),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: BorderSide(
                                                          color: cs.outlineVariant.withValues(alpha: 0.6),
                                                        ),
                                                      ),
                                                      errorBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: BorderSide(
                                                          color: Theme.of(context).colorScheme.error,
                                                        ),
                                                      ),
                                                      focusedErrorBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                        borderSide: BorderSide(
                                                          color: Theme.of(context).colorScheme.error,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text('min', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                                              ],
                                            ),
                                            const SizedBox(height: 24),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                      side: BorderSide(color: cs.outlineVariant),
                                                      foregroundColor: cs.onSurface,
                                                    ),
                                                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                                                    child: const Text(
                                                      'Cancel',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                                      foregroundColor: Colors.white,
                                                      side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(10),
                                                      ),
                                                    ),
                                                    onPressed: _busy ? null : _submitWorkout,
                                                    child: _busy
                                                        ? const SizedBox(
                                                            width: 22,
                                                            height: 22,
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2.5,
                                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                            ),
                                                          )
                                                        : const Text(
                                                            'Add',
                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SingleChildScrollView(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_currentLogs.isNotEmpty) ...[
                                      Center(
                                        child: Text(
                                          'Supplements taken 💊',
                                          style: tt.titleMedium?.copyWith(color: cs.onSurfaceVariant),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      if (_currentLogs.length <= 2)
                                        ..._currentLogs.map(
                                          (log) => _SupplementCard(
                                            log: log,
                                            busy: _busy,
                                            onRemove: () => _deleteSupplement(log),
                                          ),
                                        )
                                      else
                                        _SupplementCarousel(
                                          logs: _currentLogs,
                                          busy: _busy,
                                          pageController: _supplementPageController!,
                                          currentPage: _supplementPageIndex,
                                          onPageChanged: (i) => setState(() => _supplementPageIndex = i),
                                          onRemove: _deleteSupplement,
                                        ),
                                      const SizedBox(height: 4),
                                    ],
                                    ValueListenableBuilder<String?>(
                                      valueListenable: selectedProductId,
                                      builder: (_, productId, _) {
                                        final uniqueProducts = <String, SupplementProduct>{
                                          for (final p in widget.products) p.id: p,
                                        }.values.toList(growable: false);
                                        final safeProductId = uniqueProducts.any((p) => p.id == productId)
                                            ? productId
                                            : null;

                                        if (productId != null && safeProductId == null) {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            if (selectedProductId.value != null) {
                                              selectedProductId.value = null;
                                            }
                                          });
                                        }

                                        if (uniqueProducts.isEmpty) {
                                          return Text(
                                            'No supplement products available.',
                                            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                          );
                                        }

                                        final pickerMaxHeight = math.min(
                                          400.0,
                                          MediaQuery.of(context).size.height * 0.4,
                                        );

                                        return Form(
                                          key: _supplementFormKey,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.stretch,
                                            children: [
                                              if (_currentLogs.isEmpty) ...[
                                                Center(
                                                  child: Text(
                                                    'Did you take any supplements?',
                                                    style: tt.titleLarge?.copyWith(
                                                      color: cs.onSurfaceVariant,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                              ],
                                              Text(
                                                'Add Supplement:',
                                                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                                              ),
                                              const SizedBox(height: 6),
                                              DropdownButtonFormField<String>(
                                                initialValue: safeProductId,
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please select a supplement';
                                                  }
                                                  return null;
                                                },
                                                onChanged: _busy
                                                    ? null
                                                    : (value) {
                                                        selectedProductId.value = value;
                                                        // Reset validation error state when user makes a selection
                                                        if (_hasValidationError) {
                                                          setState(() {
                                                            _hasValidationError = false;
                                                          });
                                                        }
                                                      },
                                                decoration: InputDecoration(
                                                  hintText: 'Select a supplement...',
                                                  filled: true,
                                                  fillColor: cs.surfaceContainerHighest,
                                                  contentPadding: const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color: cs.outlineVariant),
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(
                                                      color: cs.outlineVariant.withValues(alpha: 0.6),
                                                    ),
                                                  ),
                                                  errorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                                  ),
                                                  focusedErrorBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
                                                  ),
                                                ),
                                                menuMaxHeight: pickerMaxHeight,
                                                borderRadius: BorderRadius.circular(16),
                                                items: uniqueProducts
                                                    .map(
                                                      (product) => DropdownMenuItem<String>(
                                                        value: product.id,
                                                        child: Text(product.name),
                                                      ),
                                                    )
                                                    .toList(growable: false),
                                              ),
                                              const SizedBox(height: 16),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                        side: BorderSide(color: cs.outlineVariant),
                                                        foregroundColor: cs.onSurface,
                                                      ),
                                                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                                                      child: const Text(
                                                        'Cancel',
                                                        style: TextStyle(fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    flex: 1,
                                                    child: OutlinedButton(
                                                      style: OutlinedButton.styleFrom(
                                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                                        foregroundColor: Colors.white,
                                                        side: BorderSide(color: Theme.of(context).colorScheme.primary),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10),
                                                        ),
                                                      ),
                                                      onPressed: _busy || widget.products.isEmpty
                                                          ? null
                                                          : _addSupplement,
                                                      child: _busy
                                                          ? const SizedBox(
                                                              width: 22,
                                                              height: 22,
                                                              child: CircularProgressIndicator(
                                                                strokeWidth: 2.5,
                                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                              ),
                                                            )
                                                          : Text(
                                                              'Add',
                                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
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
    final date = DateTime(year, month, daysInMonth + (cells.length - (startOffset + daysInMonth)) + 1);
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

double _dialogMaxHeightWithValidation(
  BuildContext context,
  AttendanceDay? initialAttendance,
  List<SupplementLog> initialLogs,
  bool hasValidationError,
) {
  final screenHeight = MediaQuery.of(context).size.height;
  final hasWorkout = initialAttendance != null;
  final supplementCount = initialLogs.length;

  // Base height calculation
  double baseHeight;

  // Case 0: 3+ supplements - largest height to display all content without scroll
  if (supplementCount >= 3) {
    baseHeight = math.min(600, screenHeight * 0.6);
  }
  // Case 1: 2 supplements - large height to display all content without scroll
  else if (supplementCount == 2) {
    baseHeight = math.min(500, screenHeight * 0.6);
  }
  // Case 2: 1 workout OR 1 supplement OR workout+supplement - medium height
  else if (hasWorkout || supplementCount == 1) {
    baseHeight = math.min(424, screenHeight * 0.58);
  }
  // Case 3: No workout AND no supplement - smallest height
  else {
    baseHeight = math.min(424, screenHeight * 0.5);
  }

  // Add extra height for validation errors to prevent scrolling
  if (hasValidationError) {
    baseHeight += 20; // Add 60px for error message display
  }

  return baseHeight;
}

class _SupplementCard extends StatelessWidget {
  const _SupplementCard({required this.log, required this.busy, required this.onRemove});

  final SupplementLog log;
  final bool busy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hh = log.timestamp?.hour.toString().padLeft(2, '0') ?? '';
    final mm = log.timestamp?.minute.toString().padLeft(2, '0') ?? '';
    final timeText = log.timestamp != null ? '$hh:$mm' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💊', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.productName ?? '-',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('⏱ $timeText', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
            onPressed: busy ? null : onRemove,
            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
          ),
        ],
      ),
    );
  }
}

class _SupplementCarousel extends StatelessWidget {
  const _SupplementCarousel({
    required this.logs,
    required this.busy,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.onRemove,
  });

  final List<SupplementLog> logs;
  final bool busy;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final Future<void> Function(SupplementLog) onRemove;

  static const int _perPage = 2;
  static const double _cardHeight = 80.0;

  List<List<SupplementLog>> get _pages {
    final result = <List<SupplementLog>>[];
    for (int i = 0; i < logs.length; i += _perPage) {
      result.add(logs.skip(i).take(_perPage).toList(growable: false));
    }
    return result;
  }

  List<int> _windowedDots(int total, int current) {
    if (total <= 3) return List<int>.generate(total, (i) => i);
    if (current <= 0) return [0, 1, 2];
    if (current >= total - 1) return [total - 3, total - 2, total - 1];
    return [current - 1, current, current + 1];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pages = _pages;
    final totalPages = pages.length;
    final pageHeight = _perPage * _cardHeight + (_perPage - 1) * 8;

    return Column(
      children: [
        SizedBox(
          height: pageHeight,
          child: PageView.builder(
            controller: pageController,
            itemCount: totalPages,
            onPageChanged: onPageChanged,
            itemBuilder: (_, pageIndex) {
              final pageLogs = pages[pageIndex];
              return Column(
                children: [
                  for (int i = 0; i < pageLogs.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    SizedBox(
                      height: _cardHeight,
                      child: _SupplementCard(log: pageLogs[i], busy: busy, onRemove: () => onRemove(pageLogs[i])),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _windowedDots(totalPages, currentPage)
              .map((index) {
                final active = currentPage == index;
                return GestureDetector(
                  onTap: () => pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: active ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ],
    );
  }
}

Color _calendarPageBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF08193F) : const Color(0xFFF1F3F7);
}

Color _calendarPanelBackground(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A2A49) : const Color(0xFFF8F9FB);
}

Color _calendarMutedText(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF86A0C6) : const Color(0xFF7D8798);
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
  return Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white;
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
