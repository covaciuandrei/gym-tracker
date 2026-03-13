part of 'calendar_cubit.dart';

class CalendarMonthLoadedState extends BaseState {
  const CalendarMonthLoadedState({
    required this.days,
    required this.healthLogs,
    required this.products,
    required this.workoutTypes,
    required this.year,
    required this.month,
  });

  final List<AttendanceDay> days;
  final List<SupplementLog> healthLogs;
  final List<SupplementProduct> products;
  final List<TrainingType> workoutTypes;
  final int year;
  final int month;

  @override
  List<Object?> get props => [
    days,
    healthLogs,
    products,
    workoutTypes,
    year,
    month,
  ];
}

class CalendarYearLoadedState extends BaseState {
  const CalendarYearLoadedState({
    required this.attendanceByMonth,
    required this.supplementsByMonth,
    required this.workoutTypes,
    required this.year,
  });

  final Map<int, List<AttendanceDay>> attendanceByMonth;
  final Map<int, List<SupplementLog>> supplementsByMonth;
  final List<TrainingType> workoutTypes;
  final int year;

  @override
  List<Object?> get props => [
    attendanceByMonth,
    supplementsByMonth,
    workoutTypes,
    year,
  ];
}

class CalendarDayMarkedState extends BaseState {
  const CalendarDayMarkedState({required this.day});

  final AttendanceDay day;

  @override
  List<Object?> get props => [day];
}

class CalendarDayClearedState extends BaseState {
  const CalendarDayClearedState({required this.date});

  final String date;

  @override
  List<Object?> get props => [date];
}

class CalendarSupplementLoggedState extends BaseState {
  const CalendarSupplementLoggedState({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class CalendarSupplementDeletedState extends BaseState {
  const CalendarSupplementDeletedState();
}
