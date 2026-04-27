import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/cubit/base_state.dart';

class BaseCubit extends Cubit<BaseState> {
  BaseCubit() : super(const InitialState());

  void safeEmit(BaseState state) {
    if (!isClosed) {
      emit(state);
    }
  }

  /// Guards against duplicate or re-entrant mutation calls.
  ///
  /// If the cubit is already in [PendingState] the call is a no-op — the
  /// [action] is never invoked.  Otherwise, [PendingState] is emitted first
  /// and then [action] is awaited.  [action] is responsible for emitting its
  /// own terminal success/error state via [safeEmit].
  Future<void> guardedAction(Future<void> Function() action) async {
    if (state is PendingState) return;
    safeEmit(const PendingState());
    await action();
  }
}
