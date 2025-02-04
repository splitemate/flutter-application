import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/repository/auth_repository.dart';

part 'otp_event.dart';

part 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpStates> {
  final UserProvider userProvider;
  final AuthRepository? authRepo;

  OtpBloc({this.authRepo, required this.userProvider})
      : super(const OtpStates()) {
    on<OtpEvent>((event, emit) async {
      await mapEventToState(event, emit);
    });
  }

  Future mapEventToState(OtpEvent event, Emitter<OtpStates> emit) async {
    if (event is OtpChanged) {
      emit(state.copyWith(code: event.code));
    } else if (event is OtpUidEmailReasonChanged) {
      emit(state.copyWith(
          userId: event.userId, email: event.email, reason: event.reason));
    } else if (event is OtpRequested) {
      emit(state.copyWith(appStatus: OtpRequestedState()));
      try {
        final bool useID = (state.email.isEmpty) ? true : false;
        final response = await authRepo?.resendOtp(
            userId: state.userId,
            email: state.email,
            reason: state.reason,
            useId: useID);
        if (response != null) {
          emit(state.copyWith(appStatus: OtpSentSuccess()));
        } else {
          emit(state.copyWith(
              appStatus: OtpSentFailed("Unable to send the OTP")));
        }
      } catch (e) {
        emit(state.copyWith(appStatus: OtpSentFailed(e)));
      }
    } else if (event is OtpSubmitted) {
      emit(state.copyWith(appStatus: FormSubmitting()));
      try {
        final bool useID = (state.email.isEmpty) ? true : false;
        final response = await authRepo?.validateOtp(
            userId: state.userId,
            email: state.email,
            code: state.code,
            reason: state.reason,
            useId: useID);
        if (response != null) {
          if (state.reason == "PR") {
            final String uid = response['uid'];
            final String token = response['token'];
            emit(state.copyWith(
              uid: uid,
              token: token,
              appStatus: const SubmissionSuccess(),
            ));
          } else {
            userProvider.setUser(CurrentUser(
                id: response['id'],
                name: response['name'],
                email: response['email'],
                imageUrl: response['image_url'],
                totalDue: response['balance']['total_due'],
                totalOwed: response['balance']['total_owed'],
                netBalance: response['balance']['net_balance'],
                accessToken: response['tokens']['access'],
                refreshToken: response['tokens']['refresh']));
            emit(state.copyWith(appStatus: const SubmissionSuccess()));
          }
        } else {
          emit(
              state.copyWith(appStatus: SubmissionFailed("Failed to sign in")));
        }
      } catch (e) {
        emit(state.copyWith(appStatus: SubmissionFailed(e)));
      }
    }
  }
}
