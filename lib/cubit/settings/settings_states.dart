part of 'settings_cubit.dart';

class SettingsReadyState extends BaseState {
  const SettingsReadyState({required this.appVersion});

  final String appVersion;

  @override
  List<Object?> get props => [appVersion];
}
