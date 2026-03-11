part of 'health_cubit.dart';

class HealthDayEntriesLoadedState extends BaseState {
  const HealthDayEntriesLoadedState({
    required this.entries,
    required this.date,
  });

  final List<SupplementLog> entries;
  final String date;

  @override
  List<Object?> get props => [entries, date];
}

class HealthMonthEntriesLoadedState extends BaseState {
  const HealthMonthEntriesLoadedState({required this.entries});

  final List<SupplementLog> entries;

  @override
  List<Object?> get props => [entries];
}

class HealthProductsLoadedState extends BaseState {
  const HealthProductsLoadedState({required this.products});

  final List<SupplementProduct> products;

  @override
  List<Object?> get props => [products];
}

class HealthEntryLoggedState extends BaseState {
  const HealthEntryLoggedState({required this.id});

  final String id;

  @override
  List<Object?> get props => [id];
}

class HealthEntryDeletedState extends BaseState {
  const HealthEntryDeletedState();
}
