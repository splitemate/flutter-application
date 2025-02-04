part of 'otp_bloc.dart';

class OtpStates extends Equatable {
  const OtpStates({
    this.userId = '',
    this.email = '',
    this.code = '',
    this.reason = '',
    this.uid = '',
    this.token = '',
    this.appStatus = const InitialStatus(),
  });

  final String userId;
  final String email;
  final String code;
  final String reason;
  final String uid;
  final String token;
  final AppSubmissionStatus appStatus;

  OtpStates copyWith(
      {String? userId,
      String? email,
      String? code,
      String? reason,
      String? uid,
      String? token,
      AppSubmissionStatus? appStatus}) {
    return OtpStates(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      code: code ?? this.code,
      reason: reason ?? this.reason,
      uid: uid ?? this.uid,
      token: token ?? this.token,
      appStatus: appStatus ?? this.appStatus,
    );
  }

  @override
  List<Object?> get props =>
      [userId, email, code, reason, uid, token, appStatus];
}
