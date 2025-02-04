import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/local_transactions.dart';
import 'package:splitemate/viewmodels/ledger_view_model.dart';

class TransactionThreadCubit extends Cubit<List<LocalTransaction>> {
  final LedgerViewModel viewModel;
  TransactionThreadCubit(this.viewModel) : super([]);

  Future<void> transactions(String ledgerId, LedgerType ledgerType) async {
    final transactions = await viewModel.getTransaction(ledgerId, ledgerType);
    emit(transactions);
  }
}
