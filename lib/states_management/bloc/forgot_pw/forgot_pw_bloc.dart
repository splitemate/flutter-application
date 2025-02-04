import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/repository/auth_repository.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';

part 'forgot_pw_event.dart';

part 'forgot_pw_state.dart';

class ForgotPWBloc extends Bloc<ForgotPwEvent, ForgotPwStates> {
  final AuthRepository? authRepo;

  ForgotPWBloc({this.authRepo}) : super(const ForgotPwStates()) {
    on<ForgotPwEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  Future mapEventToState(
      ForgotPwEvent event, Emitter<ForgotPwStates> emit) async {
    if (event is ForgotPwEmailChanged) {
      emit(state.copyWith(email: event.email));
    } else if (event is ForgotPwEmailChangedSubmitted) {
      emit(state.copyWith(appStatus: FormSubmitting()));

      try {
        final response = await authRepo?.forgotPw(email: state.email);
        if (response != null) {
          emit(state.copyWith(appStatus: const SubmissionSuccess()));
        } else {
          emit(state.copyWith(
              appStatus: SubmissionFailed("Unable to fetch User API")));
        }
      } catch (e) {
        emit(state.copyWith(appStatus: SubmissionFailed(e)));
      }
    }
  }
}
