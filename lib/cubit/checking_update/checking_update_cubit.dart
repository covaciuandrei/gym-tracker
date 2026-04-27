import 'package:gym_tracker/cubit/base_cubit.dart';
import 'package:gym_tracker/cubit/base_state.dart';
import 'package:gym_tracker/service/checking_update/checking_update_service.dart';
import 'package:injectable/injectable.dart';

part 'checking_update_states.dart';

/// Drives the "big update available" bottom sheet on [MainShellPage].
///
/// Responsibilities:
///   * [evaluate] — asks [CheckingUpdateService] whether the sheet should be
///     shown on this cold-launch and emits [CheckingUpdateShowSheetState] if
///     so. Called once from the shell's `initState` post-frame callback.
///   * [remindLater] — persists the 3-day cool-down and emits
///     [CheckingUpdateDismissedState].
///   * [updateNow] — launches the store URL and emits
///     [CheckingUpdateDismissedState] (no cool-down persisted).
@injectable
class CheckingUpdateCubit extends BaseCubit {
  CheckingUpdateCubit(this._service);

  final CheckingUpdateService _service;

  /// Delay between the shell mounting and presenting the sheet. Gives the
  /// home tab a moment to paint so the sheet slides in over a settled UI.
  static const Duration defaultPresentationDelay = Duration(seconds: 2);

  /// Runs the eligibility check and, when eligible, waits
  /// [presentationDelay] before emitting [CheckingUpdateShowSheetState].
  Future<void> evaluate({
    Duration presentationDelay = defaultPresentationDelay,
  }) async {
    try {
      final shouldShow = await _service.shouldShowBigUpdate();
      if (!shouldShow) {
        safeEmit(const CheckingUpdateIdleState());
        return;
      }
      await Future<void>.delayed(presentationDelay);
      safeEmit(
        CheckingUpdateShowSheetState(latestVersion: _service.latestVersion),
      );
    } catch (_) {
      safeEmit(const CheckingUpdateIdleState());
    }
  }

  /// Persists the per-version dismissal so the sheet stays hidden for the
  /// 3-day cool-down.
  Future<void> remindLater() async {
    await guardedAction(() async {
      try {
        await _service.rememberDismissal();
      } catch (_) {
        // Persist failures are non-fatal; the sheet is still dismissed visually.
      }
      safeEmit(const CheckingUpdateDismissedState());
    });
  }

  /// Launches the external store URL. Does not persist a dismissal — the
  /// user is assumed to be updating.
  Future<void> updateNow() async {
    await guardedAction(() async {
      try {
        await _service.launchStoreUrl();
      } catch (_) {
        // Swallow launcher errors; the sheet closes either way.
      }
      safeEmit(const CheckingUpdateDismissedState());
    });
  }
}
