import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gym_tracker/cubit/base_state.dart';

class BaseCubit extends Cubit<BaseState> {
  BaseCubit() : super(const InitialState());

  void safeEmit(BaseState state) {
    if (!isClosed) {
      emit(state);
    }
  }
}
