part of 'change_pw_bloc.dart';

class ChangePWStates extends Equatable {
  const ChangePWStates({
    this.password = '',
    this.uid = '',
    this.token = '',
    this.appStatus = const InitialStatus(),
  });

  final String password;
  final String uid;
  final String token;
  final AppSubmissionStatus appStatus;

  ChangePWStates copyWith(
      {String? password,
      String? confirmPW,
      String? uid,
      String? token,
      AppSubmissionStatus? appStatus}) {
    return ChangePWStates(
      password: password ?? this.password,
      uid: uid ?? this.uid,
      token: token ?? this.token,
      appStatus: appStatus ?? this.appStatus,
    );
  }

  @override
  List<Object?> get props => [password, uid, token, appStatus];
}
