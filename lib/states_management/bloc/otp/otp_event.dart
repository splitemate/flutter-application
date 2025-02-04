part of 'otp_bloc.dart';

abstract class OtpEvent extends Equatable {}

class OtpChanged extends OtpEvent {
  OtpChanged({this.code});

  final String? code;

  @override
  List<Object?> get props => [code];
}

class OtpUidEmailReasonChanged extends OtpEvent {
  OtpUidEmailReasonChanged({this.userId, this.reason, this.email});

  final String? reason;
  final String? userId;
  final String? email;

  @override
  List<Object?> get props => [userId, email, reason];
}

class OtpRequested extends OtpEvent {
  OtpRequested();

  @override
  List<Object?> get props => [];
}

class OtpSubmitted extends OtpEvent {
  OtpSubmitted();

  @override
  List<Object?> get props => [];
}
