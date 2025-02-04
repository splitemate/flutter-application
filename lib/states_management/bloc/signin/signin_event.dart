part of 'signin_bloc.dart';

abstract class SignInEvent extends Equatable {}

class LoginEmailChanged extends SignInEvent {
  LoginEmailChanged({this.email});
  final String? email;

  @override
  List<Object?> get props => [email];
}

class LoginPasswordChanged extends SignInEvent {
  LoginPasswordChanged({this.password});
  final String? password;

  @override
  List<Object?> get props => [password];
}

class LoginSubmitted extends SignInEvent {
  @override
  List<Object?> get props => [];
}