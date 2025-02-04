import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/models/transaction_wrapper.dart';
import 'package:splitemate/viewmodels/base_view_model.dart';


class LedgersViewModel extends BaseViewModel {
  final IDatasource _datasource;

  LedgersViewModel(this._datasource) : super(_datasource);

  IDatasource get datasource => _datasource;

  Future<List<Ledger>> getLedgers(LedgerType ledgerType) async {
    final ledgers = await _datasource.findAllLedgers(ledgerType);
    return ledgers;
  }

  getTransactions() {}

  Future<void> receivedTransaction(TransactionWrapper transactionWrapper) async {
    await addTransaction(transactionWrapper);
  }
}
