part of 'signup_bloc.dart';

abstract class SignUpEvent extends Equatable {}

class RegisterNameChanged extends SignUpEvent {
  RegisterNameChanged({this.name});
  final String? name;

  @override
  List<Object?> get props => [name];
}

class RegisterEmailChanged extends SignUpEvent {
  RegisterEmailChanged({this.email});
  final String? email;

  @override
  List<Object?> get props => [email];
}

class RegisterPasswordChanged extends SignUpEvent {
  RegisterPasswordChanged({this.password});
  final String? password;

  @override
  List<Object?> get props => [password];
}

class RegisterSubmitted extends SignUpEvent {
  @override
  List<Object?> get props => [];
}