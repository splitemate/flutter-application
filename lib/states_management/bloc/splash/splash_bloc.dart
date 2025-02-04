import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'splash_event.dart';

part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashState(tabIndex: 0)) {
    on<SplashEvent>((event, emit) {
      if (event is TabChange) {
        emit(state.copyWith(tabIndex: event.tabIndex));
      }
    });
  }
}
