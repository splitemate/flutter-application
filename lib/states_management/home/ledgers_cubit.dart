import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/viewmodels/ledgers_view_model.dart';

class LedgersCubit extends Cubit<List<Ledger>> {
  final LedgersViewModel viewModel ;
  LedgersCubit(this.viewModel) : super([]);

  Future<void> ledgers(LedgerType ledgerType) async {
    final ledgers = await viewModel.getLedgers(ledgerType);
    emit(ledgers);
  }
}
