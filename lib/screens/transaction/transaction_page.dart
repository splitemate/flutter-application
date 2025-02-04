import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/screens/home/home_router.dart';
import 'package:splitemate/screens/transaction/group_transaction_page.dart';
import 'package:splitemate/screens/transaction/personal_transaction_page.dart';
import 'package:splitemate/states_management/bloc/bnb/bnb_bloc.dart';
import 'package:splitemate/widgets/common/transaction_toggle_button.dart';

class TransactionPage extends StatefulWidget {
  final CurrentUser me;
  final IHomeRouter router;

  const TransactionPage({super.key, required this.me, required this.router});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
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
        title: Text(
          'Transaction',
          style: TextStyle(
              color: kBlackColor,
              fontWeight: FontWeight.bold,
              fontSize: size.width * 0.0667,
              fontFamily: 'Lexend'),
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
          horizontal: size.width * 0.0444,
        ),
        child: Column(
          children: [
            BlocBuilder<BnbBloc, BnbState>(
              builder: (context, state) {
                return Container(
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
