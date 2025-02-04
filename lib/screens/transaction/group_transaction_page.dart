import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/screens/home/home_router.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/utils/time.dart';
import 'package:splitemate/widgets/cards/transaction_card.dart';
import 'package:splitemate/widgets/common/empty_transactions.dart';

class GroupTransactionPage extends StatefulWidget {
  final CurrentUser me;
  final IHomeRouter router;

  const GroupTransactionPage(
      {super.key, required this.me, required this.router});

  @override
  State<GroupTransactionPage> createState() => _GroupTransactionPageState();
}

class _GroupTransactionPageState extends State<GroupTransactionPage> {
  var ledgers = [];

  @override
  void initState() {
    context.read<LedgersCubit>().ledgers(LedgerType.group);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return BlocBuilder<LedgersCubit, List<Ledger>>(builder: (__, ledgers) {
      this.ledgers = ledgers;
      if (this.ledgers.isEmpty)
        return const EmptyTransactions(
          isPersonal: false,
        );

      return BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, transactionState) {
          if (transactionState is TransactionReceivedSuccess) {
            print(
                "New transaction received: ${transactionState.transactionWrapper}");
          }
          return _buildListView(size);
        },
      );
    });
  }

  _buildListView(size) {
    return Padding(
      padding: EdgeInsets.only(top: size.width * 0.044),
      child: ListView.builder(
        itemCount: ledgers.length,
        itemBuilder: (context, index) {
          final item = ledgers[index];
          return GestureDetector(
            child: TransactionCard(
              name: item.name,
              time: getTimeInLocalZone(item.updatedAt),
              amount: item.amount,
              imageUrl:
                  'https://img.freepik.com/free-photo/closeup-shot-lion-s-face-isolated-dark_181624-35975.jpg?t=st=1732968582~exp=1732972182~hmac=dcac81866b958c362076383c025353c8c83e9f949f1382840e973539d0d3fa1f&w=1060',
              isPositive: item.amount > 0,
            ),
            onTap: () async {
              final cubit = context.read<LedgersCubit>();
              List<User> demoUsers = [
                User(
                    email: 'user1@example.com', name: 'User One', imageUrl: ''),
              ];
              await widget.router.onShowTransactionThread(
                  context, demoUsers, widget.me, item, LedgerType.group);
              if (!mounted) return;
              await cubit.ledgers(LedgerType.group);
            },
          );
        },
      ),
    );
  }
}
