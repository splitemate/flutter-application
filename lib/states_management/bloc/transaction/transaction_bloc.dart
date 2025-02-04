import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/service/message_stream_service.dart';

part 'transaction_event.dart';

part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final MessageStreamService messageStreamService;

  StreamSubscription<Map<String, dynamic>>? _subscription;

  TransactionBloc(this.messageStreamService) : super(TransactionInitial()) {
    on<TransactionSubscribed>(_onSubscribed);
    on<_TransactionReceived>(_onReceived);
    on<TransactionSent>(_onSent);
  }

  Future<void> _onSubscribed(
      TransactionSubscribed event, Emitter<TransactionState> emit) async {
    emit(TransactionListening());
    print('Subscribing to the WebSocket channel...');
    _subscription = messageStreamService.transactionStream.listen(
      (message) {
        print('Message received >>>>: $message');
        final transaction = _parseTransaction(message);
        add(_TransactionReceived(transaction!));
      },
      onError: (error) {
        print('Error in WebSocket subscription: $error');
        emit(TransactionError(error.toString()));
      },
      cancelOnError: true,
    );
  }

  void _onReceived(_TransactionReceived event, Emitter<TransactionState> emit) {
    emit(TransactionReceivedSuccess(event.transactionWrapper));
  }

  Future<void> _onSent(
      TransactionSent event, Emitter<TransactionState> emit) async {
    try {
      // final message = _serializeTransaction(event.transaction);
      // await  .sendMessage(message);
      emit(TransactionSentSuccess(event.transactionWrapper));
    } catch (error) {
      print('Error sending transaction: $error');
      emit(TransactionError(error.toString()));
    }
  }

  @override
  Future<void> close() {
    print('Closing');
    _subscription?.cancel();
    return super.close();
  }

  TransactionWrapper? _parseTransaction(Map<String, dynamic> message) {
    var transactionWrapper = message['data'];
    try {
      return TransactionWrapper.fromJson(transactionWrapper);
    } catch (e) {
      print('Failed to parse transaction: $e');
      return null;
    }
  }
}
