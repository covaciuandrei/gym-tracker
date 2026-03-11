import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

class InitialState extends BaseState {
  const InitialState();
}

class PendingState extends BaseState {
  const PendingState();
}

class SomethingWentWrongState extends BaseState {
  const SomethingWentWrongState();
}
