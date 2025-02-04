import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/models/user.dart';

abstract class IDatasource {
  Future<void> addLedger(Ledger ledger);
  Future<void> addTransaction(TransactionWrapper transactionWrapper);
  Future<Ledger?> findLedger(String ledgerId, String ledgerType);
  Future<Ledger> getLedger(String ledgerId, String ledgerType);
  Future<List<Ledger>> findAllLedgers(LedgerType ledgerType);
  Future<void> updateTransaction(LocalTransaction transaction);
  Future<List<LocalTransaction>> findTransaction(String transactionId, LedgerType ledgerType);
  Future<void> deleteLedger(String ledgerId, LedgerType ledgerType);
  Future<void> updateTransactionReceipt(String transactionId, ReceiptStatus status);
  Future<void> updateExistingLedger(Ledger ledger);
  Future<void> insertUsers(List<User> users);
  Future<List<User>> fetchUsersByIds(List<String> ids);
}
