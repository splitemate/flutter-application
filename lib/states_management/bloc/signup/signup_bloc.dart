import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/repository/auth_repository.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/providers/user_provider.dart';

part 'signup_event.dart';

part 'signup_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpStates> {
  final AuthRepository? authRepo;
  final UserProvider userProvider;

  SignUpBloc({this.authRepo, required this.userProvider})
      : super(const SignUpStates()) {
    on<SignUpEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  Future mapEventToState(SignUpEvent event, Emitter<SignUpStates> emit) async {
    if (event is RegisterNameChanged) {
      emit(state.copyWith(name: event.name));
    } else if (event is RegisterEmailChanged) {
      emit(state.copyWith(email: event.email));
    } else if (event is RegisterPasswordChanged) {
      emit(state.copyWith(password: event.password));
    } else if (event is RegisterSubmitted) {
      emit(state.copyWith(appStatus: FormSubmitting()));

      try {
        final user = await authRepo?.signUpWithEmail(
            name: state.name, email: state.email, password: state.password);
        if (user != null) {
          userProvider.setUser(CurrentUser(
              id: user['id'],
              name: user['name'],
              email: user['email'],
              imageUrl: user['image_url'],
              totalDue: user['balance']['total_due'],
              totalOwed: user['balance']['total_owed'],
              netBalance: user['balance']['net_balance'],
              accessToken: '',
              refreshToken: ''));
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
