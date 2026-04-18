import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:gym_tracker/core/app_version_status.dart';
import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/model/app_config.dart';
import 'package:gym_tracker/presentation/helpers/locale_helper.dart';
import 'package:gym_tracker/presentation/helpers/onboarding_helper.dart';
import 'package:gym_tracker/presentation/helpers/version_comparator.dart';
import 'package:gym_tracker/service/app_config/app_config_service.dart';
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'splash_states.dart';

/// Orchestrates the cold-launch splash flow.
///
/// Responsibilities:
///   * Run the remote-config version gate ([AppConfigService] + current
///     [PackageInfo] version) and classify the result into maintenance /
///     force-update / soft-update / ok.
///   * Enforce a minimum on-screen duration so the intro animation always
///     completes, regardless of how fast the remote config resolves.
///   * Populate [AppVersionStatus] on the ok path so [MainShellPage] can
///     render the soft-update banner.
///   * Pick the post-splash destination (maintenance / force-update /
///     no-connection / onboarding / main-shell / login) and emit it as a
///     terminal navigation state.
///
/// The page layer is therefore purely UI: animations + a [BlocListener] that
/// calls `context.router.replaceAll([...])` based on the emitted state.
@injectable
class SplashCubit extends BaseCubit {
  SplashCubit(this._configService, this._onboardingHelper, this._localeHelper, this._authInstance, this._versionStatus);

  final AppConfigService _configService;
  final OnboardingHelper _onboardingHelper;
  final LocaleHelper _localeHelper;
  final FirebaseAuth _authInstance;
  final AppVersionStatus _versionStatus;

  /// Minimum time the splash stays on screen so the intro animation can play
  /// even when the remote config check resolves quickly.
  static const Duration defaultMinSplashDuration = Duration(milliseconds: 2800);

  /// Reads [PackageInfo] for the current app version. Overridable in tests.
  @visibleForTesting
  Future<PackageInfo> packageInfo() => PackageInfo.fromPlatform();

  /// Returns the current platform flag. Overridable in tests.
  @visibleForTesting
  bool get isAndroid => Platform.isAndroid;

  /// Kicks off the splash flow. Emits [PendingState] immediately, then the
  /// resolved terminal navigation state once both the minimum splash delay
  /// and the config check have completed.
  Future<void> start({Duration minSplashDuration = defaultMinSplashDuration}) async {
    safeEmit(const PendingState());

    final results = await Future.wait([Future<void>.delayed(minSplashDuration), _resolveNavigation()]);

    final next = results[1] as BaseState;
    safeEmit(next);
  }

  /// Runs the version gate and, on ok, the onboarding/auth decision tree.
  /// Returns the navigation state to emit; does not emit itself.
  Future<BaseState> _resolveNavigation() async {
    final AppConfig config;
    final String currentVersion;
    try {
      final info = await packageInfo();
      currentVersion = info.version;
      config = await _configService.getAppConfig();
    } catch (_) {
      return const SplashNavigateNoConnectionState();
    }

    if (config.maintenanceMode) {
      final message = config.messageFor(_localeHelper.locale.languageCode);
      return SplashNavigateMaintenanceState(message: message);
    }

    final storeUrl = isAndroid ? config.androidStoreUrl : config.iosStoreUrl;

    if (VersionComparator.isBelow(currentVersion, config.minRequiredVersion)) {
      return SplashNavigateForceUpdateState(
        currentVersion: currentVersion,
        requiredVersion: config.minRequiredVersion,
        storeUrl: storeUrl,
      );
    }

    final bigUpdateAvailable = VersionComparator.isBigJump(currentVersion, config.latestVersion);
    _versionStatus.getAppVersionDetails(
      bigUpdateAvailable: bigUpdateAvailable,
      latestVersion: config.latestVersion,
      storeUrl: storeUrl,
    );

    if (_onboardingHelper.isFirstLaunch) {
      return const SplashNavigateOnboardingState();
    }
    if (_authInstance.currentUser != null) {
      return const SplashNavigateMainShellState();
    }
    return const SplashNavigateLoginState();
  }
}
