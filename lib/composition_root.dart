import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/router_generator.dart';
import 'package:splitemate/screens/dashboard.dart';
import 'package:splitemate/states_management/bloc/bnb/bnb_bloc.dart';
import 'package:splitemate/states_management/bloc/change_pw/change_pw_bloc.dart';
import 'package:splitemate/states_management/bloc/external_auth/external_auth_bloc.dart';
import 'package:splitemate/states_management/bloc/forgot_pw/forgot_pw_bloc.dart';
import 'package:splitemate/states_management/bloc/otp/otp_bloc.dart';
import 'package:splitemate/states_management/bloc/signin/signin_bloc.dart';
import 'package:splitemate/states_management/bloc/splash/splash_bloc.dart';
import 'package:splitemate/data/factories/db_factory.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/data/datasource/sqflite_datasource.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/models/ledger.dart';
import 'package:splitemate/models/user.dart';
import 'package:splitemate/repository/repository_store.dart';
import 'package:splitemate/service/init_auth.dart';
import 'package:splitemate/service/ws/ws_service.dart';
import 'package:splitemate/service/message_stream_service.dart';
import 'package:splitemate/screens/home/home_router.dart';
import 'package:splitemate/screens/on_boarding.dart';
import 'package:splitemate/screens/transaction_thread/transaction_thread.dart';
import 'package:splitemate/states_management/bloc/transaction/transaction_bloc.dart';
import 'package:splitemate/states_management/home/ledgers_cubit.dart';
import 'package:splitemate/states_management/home/transaction_thread_cubit.dart';
import 'package:splitemate/viewmodels/ledgers_view_model.dart';
import 'package:splitemate/viewmodels/ledger_view_model.dart';

class CompositionRoot extends StatefulWidget {
  const CompositionRoot({super.key});

  @override
  State<CompositionRoot> createState() => _CompositionRootState();
}

class _CompositionRootState extends State<CompositionRoot> {
  late InitAuthService _authService;
  late Future<void> _initFuture;
  late String _accessToken;
  late Database db;
  late IDatasource datasource;
  late LedgersViewModel viewModel;
  late LedgersCubit ledgersCubit;
  CurrentUser selfUser = CurrentUser.empty();
  late MessageStreamService messageStreamService;
  Map<String, dynamic> userDetailsMap = {};

  @override
  void initState() {
    super.initState();
    _initFuture = _init();
  }

  Future<void> _init() async {
    _authService = InitAuthService();
    _accessToken = (await _authService.getValidTokenOnLogin()) ?? '';

    db = await LocalDatabaseFactory().createDatabase();
    datasource = SqfliteDatasource(db);
    viewModel = LedgersViewModel(datasource);

    final ws = WebSocketService.getInstance();
    messageStreamService = MessageStreamService(ws);
    ledgersCubit = LedgersCubit(viewModel);

    if (_accessToken.isNotEmpty) {
      try {
        userDetailsMap = await _authService.getUserDetails(_accessToken);
        selfUser = _authService.getCurrentUser(userDetailsMap);
      } catch (e) {
        userDetailsMap = {};
        selfUser = CurrentUser.empty();
      }
    } else {
      selfUser = CurrentUser.empty();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture, // Use stored future
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildLoadingScreen(context);
        }
        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error);
        }
        return _buildApp();
      },
    );
  }

  Widget _buildApp() {
    final repositoryStore = RepositoryStore(context: context);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: ledgersCubit),
        BlocProvider.value(value: TransactionBloc(messageStreamService)),
        BlocProvider<SignInBloc>(
          create: (_) => SignInBloc(
            authRepo: repositoryStore.authRepository,
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
        BlocProvider<OtpBloc>(
          create: (_) => OtpBloc(
            authRepo: repositoryStore.authRepository,
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
        BlocProvider<ChangePWBloc>(
          create: (_) => ChangePWBloc(authRepo: repositoryStore.authRepository),
        ),
        BlocProvider<ForgotPWBloc>(
          create: (_) => ForgotPWBloc(authRepo: repositoryStore.authRepository),
        ),
        BlocProvider<ExternalAuthBloc>(
          create: (_) => ExternalAuthBloc(
            authRepo: repositoryStore.authRepository,
            userProvider: Provider.of<UserProvider>(context, listen: false),
          ),
        ),
        BlocProvider<SplashBloc>(create: (_) => SplashBloc()),
        BlocProvider<BnbBloc>(create: (_) => BnbBloc()),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..setUser(selfUser),
        ),
        Provider<HomeRouter>(
          create: (_) => HomeRouter(),
        ),
      ],
      child: MaterialApp(
        title: 'Splitemate',
        debugShowCheckedModeBanner: false,
        theme: lightTheme(context),
        darkTheme: darkTheme(context),
        onGenerateRoute: RouterNavigator.generateRoute,
        home: _accessToken.isNotEmpty
            ? Dashboard(
                accessToken: _accessToken,
                me: selfUser,
              )
            : OnboardingPage(),
      ),
    );
  }
}

Widget _buildLoadingScreen(BuildContext context) {
  return MaterialApp(
    title: 'Splitemate',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildGlowingOrb(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Initializing Splitemate...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedDots(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildGlowingOrb() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.8, end: 1.2),
    duration: const Duration(seconds: 1),
    curve: Curves.easeInOut,
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      );
    },
    onEnd: () {
      Future.delayed(const Duration(milliseconds: 500), () {
        _buildGlowingOrb();
      });
    },
  );
}

Widget _buildAnimatedDots() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(seconds: 1),
    builder: (context, opacity, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Opacity(
              opacity: opacity * (index + 1) / 3,
              child: const Icon(Icons.circle, color: Colors.blue, size: 12),
            ),
          );
        }),
      );
    },
  );
}

Widget _buildErrorScreen(Object? error) {
  return MaterialApp(
    title: 'Splitemate',
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 10),
              const Text(
                "Oops! Something went wrong.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                error.toString(), // ✅ Show error message dynamically
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
