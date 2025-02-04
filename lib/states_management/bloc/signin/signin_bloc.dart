import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/repository/auth_repository.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/providers/user_provider.dart';


part 'signin_event.dart';

part 'signin_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInStates> {
  final AuthRepository? authRepo;
  final UserProvider userProvider;

  SignInBloc({this.authRepo, required this.userProvider})
      : super(const SignInStates()) {
    on<SignInEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  Future mapEventToState(SignInEvent event, Emitter<SignInStates> emit) async {
    if (event is LoginEmailChanged) {
      emit(state.copyWith(email: event.email));
    } else if (event is LoginPasswordChanged) {
      emit(state.copyWith(password: event.password));
    } else if (event is LoginSubmitted) {
      emit(state.copyWith(appStatus: FormSubmitting()));

      try {
        final user = await authRepo?.signInWithEmail(
            email: state.email, password: state.password);
        if (user != null) {
          userProvider.setUser(CurrentUser(
              id: user['id'],
              name: user['name'],
              email: user['email'],
              imageUrl: user['image_url'],
              totalDue: user['balance']['total_due'],
              totalOwed: user['balance']['total_owed'],
              netBalance: user['balance']['net_balance'],
              accessToken: user['tokens']['access'],
              refreshToken: user['tokens']['refresh']));
          emit(state.copyWith(appStatus: const SubmissionSuccess()));
        } else {
          emit(
              state.copyWith(appStatus: SubmissionFailed("Failed to sign in")));
        }
      } catch (e) {
        if (e is UserIsNotVerified) {
          String userId = e.id;
          String userName = e.name;
          String userEmail = e.email;
          userProvider.setUser(CurrentUser(
              id: userId,
              name: userName,
              email: userEmail,
              imageUrl: '',
              totalDue: 0,
              totalOwed: 0,
              netBalance: 0,
              accessToken: '',
              refreshToken: ''));
        }
        emit(state.copyWith(appStatus: SubmissionFailed(e)));
      }
    }
  }
}
