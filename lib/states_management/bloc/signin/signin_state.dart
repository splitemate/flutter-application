part of 'signin_bloc.dart';

class SignInStates extends Equatable {
  const SignInStates({
    this.email = '',
    this.password = '',
    this.appStatus = const InitialStatus(),
  });

  final String email;
  final String password;
  final AppSubmissionStatus appStatus;

  SignInStates copyWith(
      {String? email, String? password, AppSubmissionStatus? appStatus}) {
    return SignInStates(
      email: email ?? this.email,
      password: password ?? this.password,
      appStatus: appStatus ?? this.appStatus,
    );
  }

  @override
  List<Object?> get props => [email, password, appStatus];
}
