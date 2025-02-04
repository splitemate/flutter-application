import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/receipt.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/viewmodels/base_view_model.dart';

class LedgerViewModel extends BaseViewModel {
  final IDatasource datasource;
  String _ledgerId = '';
  int otherMessages = 0;

  String get ledgerId => _ledgerId;

  LedgerViewModel(this.datasource) : super(datasource);

  Future<List<LocalTransaction>> getTransaction(String ledgerId, LedgerType ledgerType) async {
    final transaction = await datasource.findTransaction(ledgerId, ledgerType);
    if (transaction.isNotEmpty) _ledgerId = ledgerId;
    return transaction;
  }

  Future<void> sentTransaction(TransactionWrapper transactionWrapper) async {
    // final ledgerId = transaction.groupId != null
    //     ? transaction.groupId!
    //     : transaction.payerId;
    //
    // LocalTransaction localTransaction = LocalTransaction(
    //   ledgerId: ledgerId,
    //   transaction: transaction,
    //   receipt: ReceiptStatus.sent,
    // );
    // if (_ledgerId.isNotEmpty) {
    //   return await datasource.addTransaction(localTransaction);
    // }
    // _ledgerId = localTransaction.ledgerId;
    await addTransaction(transactionWrapper);
  }

  Future<void> receivedTransaction(TransactionWrapper transactionWrapper) async {
    // final ledgerId = transaction.groupId != null
    //     ? transaction.groupId!
    //     : transaction.payerId;
    // LocalTransaction localTransaction = LocalTransaction(
    //     ledgerId: ledgerId,
    //     transaction: transaction,
    //     receipt: ReceiptStatus.delivered);
    // if (_ledgerId.isEmpty) _ledgerId = localTransaction.ledgerId;
    // if (localTransaction.ledgerId != _ledgerId) otherMessages++;
    await addTransaction(transactionWrapper);
  }

  Future<void> updateTransactionReceipt(Receipt receipt) async {
    await datasource.updateTransactionReceipt(
        receipt.transactionId, receipt.status);
  }
}
