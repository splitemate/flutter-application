import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/repository/auth_repository.dart';

part 'change_pw_event.dart';

part 'change_pw_state.dart';

class ChangePWBloc extends Bloc<ChangePwEvent, ChangePWStates> {
  final AuthRepository? authRepo;

  ChangePWBloc({this.authRepo}) : super(const ChangePWStates()) {
    on<ChangePwEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  Future mapEventToState(
      ChangePwEvent event, Emitter<ChangePWStates> emit) async {
    if (event is PasswordChanged) {
      emit(state.copyWith(password: event.password));
    } else if (event is UIDAdded) {
      emit(state.copyWith(uid: event.uid));
    } else if (event is TokenAdded) {
      emit(state.copyWith(token: event.token));
    } else if (event is EmailSubmitted) {
      emit(state.copyWith(appStatus: FormSubmitting()));
      try {
        final user = await authRepo?.changePassword(
            password: state.password, uid: state.uid, token: state.token);
        if (user != null) {
          emit(state.copyWith(appStatus: const SubmissionSuccess()));
        } else {
          emit(state.copyWith(
              appStatus: SubmissionFailed("Unable to create an account")));
        }
      } catch (e) {
        emit(state.copyWith(appStatus: SubmissionFailed(e)));
      }
    }
  }
}
