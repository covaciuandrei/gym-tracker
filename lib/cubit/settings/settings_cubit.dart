import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:gym_tracker/core/constants/currencies.dart';
import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/service/auth/auth_service.dart';
import 'package:gym_tracker/service/user/user_service.dart';

part 'settings_states.dart';

@injectable
class SettingsCubit extends BaseCubit {
  SettingsCubit(this._authService, this._userService);

  final AuthService _authService;
  final UserService _userService;

  String _appVersion = '-';
  String _currency = fallbackCurrencyCode;

  String get appVersion => _appVersion;
  String get currency => _currency;

  Future<void> init() async {
    safeEmit(const PendingState());

    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
    } catch (_) {
      _appVersion = '-';
    }

    final userId = _authService.currentUserId;
    if (userId != null) {
      try {
        final user = await _userService.getById(userId: userId);
        _currency = normalizeCurrencyCode(user?.currency);
      } catch (_) {
        _currency = fallbackCurrencyCode;
      }
    }

    safeEmit(SettingsReadyState(appVersion: _appVersion, currency: _currency));
  }

  Future<void> setCurrency({required String currency}) async {
    final normalized = currency.trim().toUpperCase();
    if (!supportedCurrencyCodes.contains(normalized)) {
      safeEmit(const SomethingWentWrongState());
      return;
    }
    if (_currency == normalized) return;

    await guardedAction(() async {
      try {
        final userId = _authService.currentUserId;
        if (userId == null) {
          safeEmit(const SomethingWentWrongState());
          return;
        }

        await _userService.updateCurrency(userId: userId, currency: normalized);
        _currency = normalized;
        safeEmit(SettingsCurrencyUpdatedState(appVersion: _appVersion, currency: _currency));
      } catch (_) {
        safeEmit(const SomethingWentWrongState());
      }
    });
  }
}
