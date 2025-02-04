part of 'change_pw_bloc.dart';

abstract class ChangePwEvent extends Equatable {}

class PasswordChanged extends ChangePwEvent {
  PasswordChanged({this.password});

  final String? password;

  @override
  List<Object?> get props => [password];
}

class UIDAdded extends ChangePwEvent {
  UIDAdded({this.uid});

  final String? uid;

  @override
  List<Object?> get props => [uid];
}

class TokenAdded extends ChangePwEvent {
  TokenAdded({this.token});

  final String? token;

  @override
  List<Object?> get props => [token];
}

class EmailSubmitted extends ChangePwEvent {
  @override
  List<Object?> get props => [];
}
