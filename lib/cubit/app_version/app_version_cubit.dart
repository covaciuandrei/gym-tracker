import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:gym_tracker/presentation/helpers/version_comparator.dart';
import 'package:gym_tracker/service/app_config/app_config_service.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'app_version_states.dart';

/// Drives the cold-launch version/maintenance gate.
///
/// Reads the current app version from [PackageInfo] and the remote
/// [AppConfig] from [AppConfigService], then emits one of:
///   * [AppVersionMaintenanceState]  — maintenance mode toggled on
///   * [AppVersionForceUpdateState]  — current version below the minimum
///   * [AppVersionOkState]           — up-to-date or soft update available
///   * [AppVersionNetworkErrorState] — config unavailable (no offline support)
@injectable
class AppVersionCubit extends BaseCubit {
  AppVersionCubit(this._configService);

  final AppConfigService _configService;

  /// Reads [PackageInfo] for a platform check. Overridable in tests.
  @visibleForTesting
  Future<PackageInfo> packageInfo() => PackageInfo.fromPlatform();

  /// Returns the current platform (overridable in tests).
  @visibleForTesting
  bool get isAndroid => Platform.isAndroid;

  /// Runs the gate. Emits [PendingState] immediately, then a terminal state.
  Future<void> check() async {
    await guardedAction(() async {
      try {
        final info = await packageInfo();
        final currentVersion = info.version;
        final config = await _configService.getAppConfig();

        if (config.maintenanceMode) {
          safeEmit(AppVersionMaintenanceState(config: config));
          return;
        }

        if (VersionComparator.isBelow(
          currentVersion,
          config.minRequiredVersion,
        )) {
          safeEmit(
            AppVersionForceUpdateState(
              currentVersion: currentVersion,
              requiredVersion: config.minRequiredVersion,
              storeUrl: _storeUrlFor(config),
            ),
          );
          return;
        }

        final softUpdateAvailable = VersionComparator.isBelow(
          currentVersion,
          config.latestVersion,
        );
        safeEmit(
          AppVersionOkState(
            currentVersion: currentVersion,
            latestVersion: config.latestVersion,
            softUpdateAvailable: softUpdateAvailable,
            storeUrl: _storeUrlFor(config),
          ),
        );
      } catch (_) {
        safeEmit(const AppVersionNetworkErrorState());
      }
    });
  }

  String _storeUrlFor(AppConfig config) =>
      isAndroid ? config.androidStoreUrl : config.iosStoreUrl;
}
