part of 'activity_bloc.dart';

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();
}

class ActivitySubscribed extends ActivityEvent {
  const ActivitySubscribed();

  @override
  List<Object> get props => [];
}

class _ActivityReceived extends ActivityEvent {
  final Activity activity;

  const _ActivityReceived(this.activity);

  @override
  List<Object> get props => [activity];
}
