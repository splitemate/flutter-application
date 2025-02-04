part of 'forgot_pw_bloc.dart';

class ForgotPwStates extends Equatable {
  const ForgotPwStates({
    this.email = '',
    this.appStatus = const InitialStatus(),
  });

  final String email;
  final AppSubmissionStatus appStatus;

  ForgotPwStates copyWith({String? email, AppSubmissionStatus? appStatus}) {
    return ForgotPwStates(
      email: email ?? this.email,
      appStatus: appStatus ?? this.appStatus,
    );
  }

  @override
  List<Object?> get props => [email, appStatus];
}
