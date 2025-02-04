part of 'signup_bloc.dart';

class SignUpStates extends Equatable {
  const SignUpStates({
    this.name = '',
    this.email = '',
    this.password = '',
    this.appStatus = const InitialStatus(),
  });

  final String name;
  final String email;
  final String password;
  final AppSubmissionStatus appStatus;

  SignUpStates copyWith(
      {String? name, String? email, String? password, AppSubmissionStatus? appStatus}) {
    return SignUpStates(
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      appStatus: appStatus ?? this.appStatus,
    );
  }

  @override
  List<Object?> get props => [name, email, password, appStatus];
}