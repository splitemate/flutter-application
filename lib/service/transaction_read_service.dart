import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/ledger.dart';

class TransactionReadService {
  final IDatasource _datasource;

  TransactionReadService(this._datasource);

  /// Mark a transaction as read
  Future<void> markTransactionAsRead(String transactionId) async {
    try {
      await _datasource.updateTransactionReceipt(transactionId, ReceiptStatus.read);
    } catch (e) {
      print('Error marking transaction as read: $e');
    }
  }

  /// Mark all transactions in a ledger as read
  Future<void> markAllTransactionsAsRead(String ledgerId) async {
    try {
      // Get all transactions for the ledger (try both individual and group types)
      List<LocalTransaction> transactions = [];
      try {
        transactions = await _datasource.findTransaction(ledgerId, LedgerType.individual);
      } catch (e) {
        // If individual fails, try group
        transactions = await _datasource.findTransaction(ledgerId, LedgerType.group);
      }
      
      // Mark each transaction as read
      for (final transaction in transactions) {
        if (transaction.receipt == ReceiptStatus.delivered) {
          await _datasource.updateTransactionReceipt(transaction.id!, ReceiptStatus.read);
        }
      }
    } catch (e) {
      print('Error marking all transactions as read: $e');
    }
  }

  /// Mark multiple transactions as read
  Future<void> markTransactionsAsRead(List<String> transactionIds) async {
    try {
      for (final transactionId in transactionIds) {
        await _datasource.updateTransactionReceipt(transactionId, ReceiptStatus.read);
      }
    } catch (e) {
      print('Error marking transactions as read: $e');
    }
  }

  /// Get unread count for a specific ledger
  Future<int> getUnreadCount(String ledgerId) async {
    try {
      List<LocalTransaction> transactions = [];
      try {
        transactions = await _datasource.findTransaction(ledgerId, LedgerType.individual);
      } catch (e) {
        // If individual fails, try group
        transactions = await _datasource.findTransaction(ledgerId, LedgerType.group);
      }
      return transactions.where((t) => t.receipt == ReceiptStatus.delivered).length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
} 