part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();
}

class TransactionSubscribed extends TransactionEvent {
  const TransactionSubscribed();

  @override
  List<Object> get props => [];
}

class TransactionSent extends TransactionEvent {
  final TransactionWrapper transactionWrapper;

  const TransactionSent(this.transactionWrapper);

  @override
  List<Object> get props => [transactionWrapper];
}

class _TransactionReceived extends TransactionEvent {
  final TransactionWrapper transactionWrapper;

  const _TransactionReceived(this.transactionWrapper);

  @override
  List<Object> get props => [transactionWrapper];
}
