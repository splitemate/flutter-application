part of 'forgot_pw_bloc.dart';

abstract class ForgotPwEvent extends Equatable {}

class ForgotPwEmailChanged extends ForgotPwEvent {
  ForgotPwEmailChanged({this.email});

  final String? email;

  @override
  List<Object?> get props => [email];
}

class ForgotPwEmailChangedSubmitted extends ForgotPwEvent {
  @override
  List<Object?> get props => [];
}
