import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';

part 'settings_states.dart';

@injectable
class SettingsCubit extends BaseCubit {
  Future<void> init() async {
    safeEmit(const PendingState());
    try {
      final info = await PackageInfo.fromPlatform();
      safeEmit(SettingsReadyState(appVersion: info.version));
    } catch (_) {
      safeEmit(const SettingsReadyState(appVersion: '-'));
    }
  }
}
