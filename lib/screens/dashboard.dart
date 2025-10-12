import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/states_management/bloc/activity/activity_bloc.dart';
import 'package:splitemate/states_management/home/activity_cubit.dart';
import 'package:splitemate/utils/const.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/service/message_stream_service.dart';
import 'package:splitemate/states_management/bloc/bnb/bnb_bloc.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:splitemate/screens/profile.dart';
import 'package:splitemate/screens/home.dart';
import 'package:splitemate/screens/statistics/statistics.dart';
import 'package:splitemate/screens/transaction/transaction_page.dart';
import 'package:splitemate/widgets/bnb/custom_navigation_bar.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/service/ws/ws_service.dart';
import 'package:splitemate/screens/home/home_router.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/models/ledger.dart';

class Dashboard extends StatefulWidget {
  final String accessToken;
  final CurrentUser me;

  const Dashboard({super.key, required this.accessToken, required this.me});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late WebSocketService _webSocketService;
  late MessageStreamService messageStreamService;

  @override
  void initState() {
    super.initState();
    _updateUserProvider();
    context.read<ActivitiesCubit>().activities();
    _webSocketService = WebSocketService.getInstance();
    messageStreamService = MessageStreamService(_webSocketService);
    _initializeWebSocketAndBloc();
  }

  void _updateUserProvider() {
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final userProvider = Provider.of<UserProvider>(context, listen: false);
          
          final updatedUser = CurrentUser(
            id: widget.me.id,
            name: widget.me.name,
            email: widget.me.email,
            imageUrl: widget.me.imageUrl,
            accessToken: widget.accessToken,
            refreshToken: widget.me.refreshToken,
            totalOwed: widget.me.totalOwed,
            totalDue: widget.me.totalDue,
            netBalance: widget.me.netBalance,
            inviteToken: widget.me.inviteToken,
          );
          userProvider.setUser(updatedUser);
        }
      });
    } catch (e) {
      print('Dashboard: Error updating UserProvider: $e');
    }
  }

  Future<void> _initializeWebSocketAndBloc() async {
    final transactionBloc = context.read<TransactionBloc>();
    final activityBloc = context.read<ActivityBloc>();

    try {
      if (_webSocketService.isConnected) {
        transactionBloc.add(const TransactionSubscribed());
        activityBloc.add(const ActivitySubscribed());
        return;
      }

      await _webSocketService.connect(
        wsUrl,
        {'Authorization': 'Bearer ${widget.accessToken}'},
      );
      print('WebSocket connected successfully');

      if (mounted) {
        transactionBloc.add(const TransactionSubscribed());
        activityBloc.add(const ActivitySubscribed());
      }

      _listenToTransactionUpdates();
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _listenToTransactionUpdates() {
    final ledgersCubit = context.read<LedgersCubit>();
    final activitiesCubit = context.read<ActivitiesCubit>();

    context.read<TransactionBloc>().stream.listen((state) async {
      if (state is TransactionReceivedSuccess) {
        print("New transaction received: ${state.transactionWrapper}");
        
        try {
          await ledgersCubit.viewModel
              .receivedTransaction(state.transactionWrapper);
          
          ledgersCubit.ledgers(state.transactionWrapper.type);
          
          final otherType = state.transactionWrapper.type == LedgerType.individual
              ? LedgerType.group 
              : LedgerType.individual;
          ledgersCubit.ledgers(otherType);
          
          if (state.transactionWrapper.userTotalBalance != null) {
            final userProvider = Provider.of<UserProvider>(context, listen: false);
            userProvider.updateUserBalances(
              totalOwed: state.transactionWrapper.userTotalBalance!.totalOwed,
              totalDue: state.transactionWrapper.userTotalBalance!.totalDue,
              netBalance: state.transactionWrapper.userTotalBalance!.netBalance,
            );
            print("User balances updated: ${state.transactionWrapper.userTotalBalance}");
          }
          
          print("Ledgers refreshed after new transaction");
        } catch (e) {
          print("Error handling new transaction: $e");
        }
      }
    });

    context.read<ActivityBloc>().stream.listen((state) async {
      if (state is ActivityReceivedSuccess) {
        print("New activity received: ${state.activity}");
        await activitiesCubit.viewModel.receivedActivity(state.activity);
        activitiesCubit.activities();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeRouter = Provider.of<HomeRouter>(context);

    List<Widget> bottomNavScreen = <Widget>[
      const Home(),
      TransactionPage(me: widget.me, router: homeRouter),
      const Statistics(),
      const Profile(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider<BnbBloc>(
          create: (_) => BnbBloc(),
        ),
      ],
      child: BlocConsumer<BnbBloc, BnbState>(
        listener: (context, state) {},
        listenWhen: (previous, current) =>
            previous.tabIndex != current.tabIndex,
        buildWhen: (previous, current) => previous.tabIndex != current.tabIndex,
        builder: (context, bnbState) {
          return Scaffold(
            body: SafeArea(
              child: bottomNavScreen.elementAt(bnbState.tabIndex),
            ),
            bottomNavigationBar: const CustomBottomNavigationBar(),
          );
        },
      ),
    );
  }
}
