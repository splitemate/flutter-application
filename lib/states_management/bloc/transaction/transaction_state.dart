part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionListening extends TransactionState {}

class TransactionSentSuccess extends TransactionState {
  final TransactionWrapper transactionWrapper;

  const TransactionSentSuccess(this.transactionWrapper);

  @override
  List<Object> get props => [transactionWrapper];
}

class TransactionReceivedSuccess extends TransactionState {
  final TransactionWrapper transactionWrapper;

  const TransactionReceivedSuccess(this.transactionWrapper);

  @override
  List<Object> get props => [transactionWrapper];
}

class TransactionError extends TransactionState {
  final String error;

  const TransactionError(this.error);

  @override
  List<Object> get props => [error];
}
