part of 'calendar_cubit.dart';

class CalendarMonthLoadedState extends BaseState {
  const CalendarMonthLoadedState({
    required this.days,
    required this.year,
    required this.month,
  });

  final List<AttendanceDay> days;
  final int year;
  final int month;

  @override
  List<Object?> get props => [days, year, month];
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
