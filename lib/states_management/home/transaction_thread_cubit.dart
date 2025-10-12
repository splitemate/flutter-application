import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/viewmodels/ledger_view_model.dart';
import 'package:splitemate/service/transaction_read_service.dart';

class TransactionThreadState {
  final List<LocalTransaction> transactions;
  final int unreadCount;
  final bool hasNewMessages;
  final bool isLoading;
  final String? error;

  TransactionThreadState({
    required this.transactions,
    this.unreadCount = 0,
    this.hasNewMessages = false,
    this.isLoading = false,
    this.error,
  });

  TransactionThreadState copyWith({
    List<LocalTransaction>? transactions,
    int? unreadCount,
    bool? hasNewMessages,
    bool? isLoading,
    String? error,
  }) {
    return TransactionThreadState(
      transactions: transactions ?? this.transactions,
      unreadCount: unreadCount ?? this.unreadCount,
      hasNewMessages: hasNewMessages ?? this.hasNewMessages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class TransactionThreadCubit extends Cubit<TransactionThreadState> {
  final LedgerViewModel viewModel;
  final TransactionReadService _readService;
  StreamSubscription<TransactionWrapper>? _transactionSubscription;
  String? _currentLedgerId;
  LedgerType? _currentLedgerType;
  Function(String, LedgerType)? _onUnreadCountChanged;

  TransactionThreadCubit(this.viewModel) 
      : _readService = TransactionReadService(viewModel.datasource),
        super(TransactionThreadState(transactions: []));

  // Set callback to notify parent when unread count changes
  void setUnreadCountChangedCallback(Function(String, LedgerType)? callback) {
    _onUnreadCountChanged = callback;
  }

Future<void> transactions(String ledgerId, LedgerType ledgerType) async {
    _currentLedgerId = ledgerId;
    _currentLedgerType = ledgerType;
    
    emit(state.copyWith(isLoading: true));
    
    try {
      final transactions = await viewModel.getTransaction(ledgerId, ledgerType);
      
      // Sort transactions by transaction date chronologically (oldest -> newest)
      transactions.sort((a, b) => a.transaction.transactionDate.compareTo(b.transaction.transactionDate));
      
      // Calculate unread count
      final unreadCount = transactions.where((t) => t.receipt == ReceiptStatus.delivered).length;
      
      emit(state.copyWith(
        transactions: transactions,
        unreadCount: unreadCount,
        isLoading: false,
        hasNewMessages: unreadCount > 0,
      ));
      
      // Don't auto-mark transactions as read initially
      // Let the visibility detector in the UI handle read status based on scroll
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  void subscribeToRealTimeUpdates(Stream<TransactionWrapper> transactionStream) {
    _transactionSubscription?.cancel();
    _transactionSubscription = transactionStream.listen(
      (transactionWrapper) {
        handleNewTransaction(transactionWrapper);
      },
      onError: (error) {
        emit(state.copyWith(error: error.toString()));
      },
    );
  }

  // Callback for UI to handle new transactions
  Function(String transactionId)? _onNewTransactionReceived;
  
  void setNewTransactionCallback(Function(String transactionId)? callback) {
    _onNewTransactionReceived = callback;
  }

  void handleNewTransaction(TransactionWrapper transactionWrapper) {
    try {
      // Check if this transaction belongs to the current ledger
      if (_currentLedgerId == null || _currentLedgerType == null) {
        print('TransactionThreadCubit: No current ledger set, skipping transaction');
        return;
      }
      
      final ledgerTransactions = transactionWrapper.generateLedgerWiseTransactions();
      final relevantTransaction = ledgerTransactions.firstWhere(
        (t) => t['ledger_id'] == _currentLedgerId && t['ledger_type'] == _currentLedgerType!.value(),
        orElse: () => <String, dynamic>{},
      );
      
      if (relevantTransaction.isNotEmpty) {
        print('TransactionThreadCubit: Processing transaction for ledger $_currentLedgerId');
        print('TransactionThreadCubit: Transaction data: $relevantTransaction');
        
        // Convert to LocalTransaction
        final newTransaction = LocalTransaction.fromMap(relevantTransaction);
        
        // Check if this transaction already exists to avoid duplicates
        final existingTransaction = state.transactions.firstWhere(
          (t) => t.id == newTransaction.id,
          orElse: () => LocalTransaction(
            ledgerId: '',
            transaction: newTransaction.transaction,
            receipt: ReceiptStatus.sent,
          ),
        );
        
        if (existingTransaction.ledgerId.isEmpty) {
          // Insert transaction in chronological order based on transaction date
          final updatedTransactions = List<LocalTransaction>.from(state.transactions);
          
          // Find the correct position to insert (maintain chronological order by transaction date: oldest -> newest)
          int insertIndex = 0;
          for (int i = 0; i < updatedTransactions.length; i++) {
            // Insert before the first item whose transactionDate is after the new one
            if (updatedTransactions[i].transaction.transactionDate.isAfter(newTransaction.transaction.transactionDate)) {
              insertIndex = i;
              break;
            }
            insertIndex = i + 1;
          }
          
          updatedTransactions.insert(insertIndex, newTransaction);
          
          // Update unread count - only increment if the transaction is unread
          final newUnreadCount = state.unreadCount + (newTransaction.receipt == ReceiptStatus.delivered ? 1 : 0);
          
          emit(state.copyWith(
            transactions: updatedTransactions,
            unreadCount: newUnreadCount,
            hasNewMessages: true,
          ));
          
          print('New transaction added to thread at index $insertIndex: ${newTransaction.id}, unread count: $newUnreadCount');
          
          // Notify UI to scroll to new transaction
          if (_onNewTransactionReceived != null && newTransaction.id != null) {
            _onNewTransactionReceived!(newTransaction.id!);
          }
          
          // Don't auto-mark as read immediately - let user see it first
        } else {
          print('TransactionThreadCubit: Transaction ${newTransaction.id} already exists, skipping');
        }
      } else {
        print('TransactionThreadCubit: No relevant transaction found for ledger $_currentLedgerId');
      }
    } catch (e, stackTrace) {
      print('TransactionThreadCubit: Error handling new transaction: $e');
      print('TransactionThreadCubit: Stack trace: $stackTrace');
      emit(state.copyWith(error: 'Error processing transaction: $e'));
    }
  }

  // Automatically mark transaction as read when user is on the page
  Future<void> _autoMarkAsRead(String transactionId) async {
    try {
      // Add a small delay to ensure the user has seen the transaction
      await Future.delayed(const Duration(milliseconds: 500));
      
      await _readService.markTransactionAsRead(transactionId);
      
      // Update the specific transaction in the state
      final updatedTransactions = state.transactions.map((t) {
        if (t.id == transactionId && t.receipt == ReceiptStatus.delivered) {
          final updatedTransaction = LocalTransaction(
            ledgerId: t.ledgerId,
            transaction: t.transaction,
            receipt: ReceiptStatus.read,
          );
          updatedTransaction.id = t.id; // ✅ Fix: Set the _id
          return updatedTransaction;
        }
        return t;
      }).toList();
      
      // Recalculate unread count
      final newUnreadCount = updatedTransactions.where((t) => t.receipt == ReceiptStatus.delivered).length;
      
      emit(state.copyWith(
        transactions: updatedTransactions,
        unreadCount: newUnreadCount,
      ));
      
      print('Transaction auto-marked as read: $transactionId, new unread count: $newUnreadCount');
    } catch (e) {
      print('Error auto-marking transaction as read: $e');
    }
  }

  Future<void> markAsRead() async {
    if (_currentLedgerId != null) {
      try {
        // Mark all unread transactions as read
        await _readService.markAllTransactionsAsRead(_currentLedgerId!);
        
        // Update the state
        final updatedTransactions = state.transactions.map((t) {
          if (t.receipt == ReceiptStatus.delivered) {
            final updatedTransaction = LocalTransaction(
              ledgerId: t.ledgerId,
              transaction: t.transaction,
              receipt: ReceiptStatus.read,
            );
            updatedTransaction.id = t.id; // ✅ Fix: Set the _id
            return updatedTransaction;
          }
          return t;
        }).toList();
        
        emit(state.copyWith(
          transactions: updatedTransactions,
          unreadCount: 0,
          hasNewMessages: false,
        ));
        
        print('All transactions marked as read for ledger: $_currentLedgerId');
      } catch (e) {
        print('Error marking transactions as read: $e');
      }
    }
  }

  Future<void> markTransactionAsRead(String transactionId) async {
    try {
      await _readService.markTransactionAsRead(transactionId);
      
      // Update the specific transaction in the state
      final updatedTransactions = state.transactions.map((t) {
        if (t.id == transactionId && t.receipt == ReceiptStatus.delivered) {
          final updatedTransaction = LocalTransaction(
            ledgerId: t.ledgerId,
            transaction: t.transaction,
            receipt: ReceiptStatus.read,
          );
          updatedTransaction.id = t.id; // ✅ Fix: Set the _id
          return updatedTransaction;
        }
        return t;
      }).toList();
      
      // Recalculate unread count
      final newUnreadCount = updatedTransactions.where((t) => t.receipt == ReceiptStatus.delivered).length;
      
      emit(state.copyWith(
        transactions: updatedTransactions,
        unreadCount: newUnreadCount,
      ));
      
      print('Transaction marked as read: $transactionId, new unread count: $newUnreadCount');
    } catch (e) {
      print('Error marking transaction as read: $e');
    }
  }

  void clearNewMessageIndicator() {
    emit(state.copyWith(hasNewMessages: false));
  }

  // Mark specific transactions as read when they become visible
  Future<void> markTransactionsAsReadByIds(List<String> transactionIds) async {
    try {
      final transactionsToUpdate = <String>[];
      
      // Only process transactions that are actually unread
      for (final id in transactionIds) {
        final transaction = state.transactions.firstWhere(
          (t) => t.id == id && t.receipt == ReceiptStatus.delivered,
          orElse: () => LocalTransaction(
            ledgerId: '',
            transaction: state.transactions.first.transaction,
            receipt: ReceiptStatus.read,
          ),
        );
        
        if (transaction.ledgerId.isNotEmpty) {
          transactionsToUpdate.add(id);
        }
      }
      
      if (transactionsToUpdate.isEmpty) return;
      
      // Update database
      await _readService.markTransactionsAsRead(transactionsToUpdate);
      
      // Update state
      final updatedTransactions = state.transactions.map((t) {
        if (transactionsToUpdate.contains(t.id) && t.receipt == ReceiptStatus.delivered) {
          final updatedTransaction = LocalTransaction(
            ledgerId: t.ledgerId,
            transaction: t.transaction,
            receipt: ReceiptStatus.read,
          );
          updatedTransaction.id = t.id;
          return updatedTransaction;
        }
        return t;
      }).toList();
      
      // Recalculate unread count
      final newUnreadCount = updatedTransactions.where((t) => t.receipt == ReceiptStatus.delivered).length;
      
      emit(state.copyWith(
        transactions: updatedTransactions,
        unreadCount: newUnreadCount,
        hasNewMessages: newUnreadCount > 0,
      ));
      
      // Notify parent about unread count change
      if (_currentLedgerId != null && _currentLedgerType != null && _onUnreadCountChanged != null) {
        _onUnreadCountChanged!(_currentLedgerId!, _currentLedgerType!);
      }
      
      print('Marked ${transactionsToUpdate.length} transactions as read, new unread count: $newUnreadCount');
    } catch (e) {
      print('Error marking transactions as read by IDs: $e');
    }
  }

  void refreshTransactions() async {
    if (_currentLedgerId != null && _currentLedgerType != null) {
      await transactions(_currentLedgerId!, _currentLedgerType!);
    }
  }

  // ✅ New method to mark visible transactions as read
  Future<void> _markVisibleTransactionsAsRead() async {
    try {
      final unreadTransactions = state.transactions
          .where((t) => t.receipt == ReceiptStatus.delivered)
          .toList();
      
      if (unreadTransactions.isNotEmpty) {
        // Mark all unread transactions as read
        for (final transaction in unreadTransactions) {
          await _readService.markTransactionAsRead(transaction.id!);
        }
        
        // Update the state
        final updatedTransactions = state.transactions.map((t) {
          if (t.receipt == ReceiptStatus.delivered) {
            final updatedTransaction = LocalTransaction(
              ledgerId: t.ledgerId,
              transaction: t.transaction,
              receipt: ReceiptStatus.read,
            );
            updatedTransaction.id = t.id; // ✅ Fix: Set the _id
            return updatedTransaction;
          }
          return t;
        }).toList();
        
        emit(state.copyWith(
          transactions: updatedTransactions,
          unreadCount: 0,
          hasNewMessages: false,
        ));
        
        print('All visible transactions marked as read for ledger: $_currentLedgerId');
      }
    } catch (e) {
      print('Error marking visible transactions as read: $e');
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }
}
