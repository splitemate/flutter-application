part of 'external_auth_bloc.dart';

class ExternalAuthState extends Equatable {
  const ExternalAuthState({
    this.appStatus = const InitialStatus(),
  });

  final AppSubmissionStatus appStatus;

  ExternalAuthState copyWith({AppSubmissionStatus? appStatus}) {
    return ExternalAuthState(
      appStatus: appStatus ?? this.appStatus,
    );
  }

  @override
  List<Object?> get props => [appStatus];
}
