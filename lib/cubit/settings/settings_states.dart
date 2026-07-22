part of 'settings_cubit.dart';

abstract class SettingsDataState extends BaseState {
  const SettingsDataState({required this.appVersion, required this.currency});

  final String appVersion;
  final String currency;

  @override
  List<Object?> get props => [appVersion, currency];
}

class SettingsReadyState extends SettingsDataState {
  const SettingsReadyState({required super.appVersion, required super.currency});
}

class SettingsCurrencyUpdatedState extends SettingsDataState {
  const SettingsCurrencyUpdatedState({required super.appVersion, required super.currency});
}
