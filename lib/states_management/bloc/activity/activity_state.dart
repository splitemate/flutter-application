part of 'activity_bloc.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object> get props => [];
}

class ActivityInitial extends ActivityState {}

class ActivityListening extends ActivityState {}

class ActivityReceivedSuccess extends ActivityState {
  final Activity activity;

  const ActivityReceivedSuccess(this.activity);

  @override
  List<Object> get props => [activity];
}

class ActivityError extends ActivityState {
  final String error;

  const ActivityError(this.error);

  @override
  List<Object> get props => [error];
}
