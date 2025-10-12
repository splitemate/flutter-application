import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/screens/home/home_router.dart';
import 'package:splitemate/screens/transaction/group_transaction_page.dart';
import 'package:splitemate/screens/transaction/personal_transaction_page.dart';
import 'package:splitemate/states_management/bloc/bnb/bnb_bloc.dart';
import 'package:splitemate/widgets/common/transaction_toggle_button.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/widgets/common/unread_count_badge.dart';
import 'package:splitemate/models/ledger.dart';

class TransactionPage extends StatefulWidget {
  final CurrentUser me;
  final IHomeRouter router;

  const TransactionPage({super.key, required this.me, required this.router});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load ledgers for both types to get unread counts
    context.read<LedgersCubit>().ledgers(LedgerType.individual);
    context.read<LedgersCubit>().ledgers(LedgerType.group);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh ledgers when app becomes active
      context.read<LedgersCubit>().ledgers(LedgerType.individual);
      context.read<LedgersCubit>().ledgers(LedgerType.group);
    }
  }

  int _getTotalUnreadCount() {
    final ledgersCubit = context.read<LedgersCubit>();
    final individualLedgers = ledgersCubit.state.where((l) => l.type == LedgerType.individual).toList();
    final groupLedgers = ledgersCubit.state.where((l) => l.type == LedgerType.group).toList();
    
    final individualUnread = individualLedgers.fold<int>(0, (sum, ledger) => sum + ledger.unread);
    final groupUnread = groupLedgers.fold<int>(0, (sum, ledger) => sum + ledger.unread);
    
    return individualUnread + groupUnread;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> transactionWidgetList = [
      PersonalTransactionPage(
        me: widget.me,
        router: widget.router,
      ),
      GroupTransactionPage(
        me: widget.me,
        router: widget.router,
      )
    ];
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: kStockColor,
        forceMaterialTransparency: true,
        titleSpacing: 0,
        title: Row(
          children: [
            Text(
              'Transaction',
              style: TextStyle(
                  color: kBlackColor,
                  fontWeight: FontWeight.bold,
                  fontSize: size.width * 0.0667,
                  fontFamily: 'Lexend'),
            ),
            const SizedBox(width: 8),
            BlocBuilder<LedgersCubit, List<Ledger>>(
              builder: (context, ledgers) {
                final unreadCount = _getTotalUnreadCount();
                return UnreadCountBadge(
                  count: unreadCount,
                  size: 18,
                );
              },
            ),
          ],
        ),
        leading: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(Icons.arrow_back_ios_outlined),
          onPressed: () {
            BlocProvider.of<BnbBloc>(context).add(TabChange(tabIndex: 0));
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search_outlined, color: kBlackColor),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.width * 0.033,
        ),
        child: Column(
          children: [
            BlocBuilder<BnbBloc, BnbState>(
              builder: (context, state) {
                return Container(
                  margin: EdgeInsets.symmetric(horizontal: size.width * 0.0444),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(size.width * 0.0333),
                    color: kWhiteColor,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(size.width * 0.0167),
                    child: Row(
                      children: [
                        TransactionToggleButton(
                          text: 'Personal',
                          toggleIndex: 0,
                          currentIndex: state.toggleIndex,
                          onTap: () => BlocProvider.of<BnbBloc>(context)
                              .add(ToggleButtonPressed(toggleIndex: 0)),
                        ),
                        TransactionToggleButton(
                          text: 'Group',
                          toggleIndex: 1,
                          currentIndex: state.toggleIndex,
                          onTap: () => BlocProvider.of<BnbBloc>(context)
                              .add(ToggleButtonPressed(toggleIndex: 1)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            BlocConsumer<BnbBloc, BnbState>(
              listener: (context, state) {},
              buildWhen: (current, previous) =>
                  current.toggleIndex != previous.toggleIndex,
              builder: (context, state) {
                return Expanded(
                  child: transactionWidgetList.elementAt(state.toggleIndex),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
