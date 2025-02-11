import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:splitemate/models/activity.dart';
import 'package:splitemate/service/message_stream_service.dart';

part 'activity_event.dart';

part 'activity_state.dart';

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  final MessageStreamService messageStreamService;

  StreamSubscription<Map<String, dynamic>>? _subscription;

  ActivityBloc(this.messageStreamService) : super(ActivityInitial()) {
    on<ActivitySubscribed>(_onSubscribed);
    on<_ActivityReceived>(_onReceived);
  }

  Future<void> _onSubscribed(
      ActivitySubscribed event, Emitter<ActivityState> emit) async {
    emit(ActivityListening());
    print('Subscribing to the WebSocket channel for activity...');
    _subscription = messageStreamService.activityStream.listen(
      (message) {
        print('Activity received >>>>: $message');
        final activity = _parseActivity(message);
        add(_ActivityReceived(activity!));
      },
      onError: (error) {
        print('Error in WebSocket subscription: $error');
        emit(ActivityError(error.toString()));
      },
      cancelOnError: true,
    );
  }

  void _onReceived(_ActivityReceived event, Emitter<ActivityState> emit) {
    emit(ActivityReceivedSuccess(event.activity));
  }

  @override
  Future<void> close() {
    print('Closing');
    _subscription?.cancel();
    return super.close();
  }

  Activity? _parseActivity(Map<String, dynamic> activityMap) {
    try {
      return Activity.fromMap(activityMap);
    } catch (e) {
      print('Failed to parse activity: $e');
      return null;
    }
  }
}
