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
    print('Dashboard initState');
    super.initState();
    context.read<ActivitiesCubit>().activities();
    _webSocketService = WebSocketService.getInstance();
    messageStreamService = MessageStreamService(_webSocketService);
    _initializeWebSocketAndBloc();
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
    print('Dashboard dispose');
    super.dispose();
  }

  void _listenToTransactionUpdates() {
    final ledgersCubit = context.read<LedgersCubit>();
    final activitiesCubit = context.read<ActivitiesCubit>();

    context.read<TransactionBloc>().stream.listen((state) async {
      if (state is TransactionReceivedSuccess) {
        print("New transaction received: ${state.transactionWrapper}");
        await ledgersCubit.viewModel
            .receivedTransaction(state.transactionWrapper);
      }
    });

    context.read<ActivityBloc>().stream.listen((state) async {
      if (state is ActivityReceivedSuccess) {
        print("New activity received: ${state.activity}");
        await activitiesCubit.viewModel.receivedActivity(state.activity);
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
