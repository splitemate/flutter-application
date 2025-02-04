import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'bnb_event.dart';

part 'bnb_state.dart';

class BnbBloc extends Bloc<BnbEvent, BnbState> {
  BnbBloc() : super(const BnbState(tabIndex: 0, toggleIndex: 0)) {
    on<BnbEvent>((event, emit) {
      if (event is TabChange) {
        emit(state.copyWith(tabIndex: event.tabIndex));
      } else if (event is ToggleButtonPressed) {
        emit(state.copyWith(toggleIndex: event.toggleIndex));
      }
    });
  }
}
