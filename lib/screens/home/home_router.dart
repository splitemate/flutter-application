import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/screens/transaction_thread/transaction_thread.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/states_management/home/transaction_thread_cubit.dart';
import 'package:splitemate/viewmodels/ledger_view_model.dart';

abstract class IHomeRouter {
  Future<void> onShowTransactionThread(BuildContext context,
      List<User> receivers, CurrentUser me, Ledger ledger, LedgerType ledgerType);
}

class HomeRouter extends IHomeRouter {
  @override
  Future<void> onShowTransactionThread(BuildContext context,
      List<User> receivers, CurrentUser me, Ledger ledger, LedgerType ledgerType) {
    LedgerViewModel ledgerViewModel =
        LedgerViewModel(context.read<LedgersCubit>().viewModel.datasource);

    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => TransactionThreadCubit(ledgerViewModel),
            ),
          ],
          child: TransactionThread(
            receivers: receivers,
            me: me,
            ledger: ledger,
            ledgersCubit: context.read<LedgersCubit>(),
            ledgerType: ledgerType,
          ),
        ),
      ),
    );
  }
}
