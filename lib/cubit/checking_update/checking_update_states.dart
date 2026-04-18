part of 'checking_update_cubit.dart';

/// Emitted when the sheet should not be presented (no big update, still in
/// cool-down, or error during evaluation). Default idle state after
/// [CheckingUpdateCubit.evaluate] resolves unsuccessfully.
class CheckingUpdateIdleState extends BaseState {
  const CheckingUpdateIdleState();
}

/// Emitted when the main shell should present the big-update bottom sheet.
/// [latestVersion] is shown inside the sheet copy.
class CheckingUpdateShowSheetState extends BaseState {
  const CheckingUpdateShowSheetState({required this.latestVersion});

  final String latestVersion;

  @override
  List<Object?> get props => [latestVersion];
}

/// Emitted after the user closes the sheet via either action ("Update now"
/// or "Remind me later"). Used by the page's `BlocListener` to guarantee
/// the sheet is not shown twice in the same session.
class CheckingUpdateDismissedState extends BaseState {
  const CheckingUpdateDismissedState();
}
