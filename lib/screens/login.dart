import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/data/datasource/datasource_contract.dart';
import 'package:splitemate/data/datasource/sqflite_datasource.dart';
import 'package:splitemate/data/factories/db_factory.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/service/init_auth.dart';
import 'package:splitemate/service/sync_service.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/widgets/auth_input/password_input_gradiant.dart';
import 'package:splitemate/widgets/common/gradient_text_line_button.dart';
import 'package:splitemate/repository/repository_store.dart';
import 'package:splitemate/widgets/auth_input/auth_button.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/widgets/auth_input/google_auth_button.dart';
import 'package:splitemate/widgets/auth_input/email_gradiant_input.dart';
import 'package:splitemate/states_management/bloc/signin/signin_bloc.dart';
import 'package:splitemate/states_management/bloc/external_auth/external_auth_bloc.dart';
import 'package:splitemate/widgets/popup/display_unknown_error.dart';
import 'package:sqflite/sqflite.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var horizontalPadding = size.width * 0.1;
    var topPadding = size.height * 0.05;
    final userProvider = Provider.of<UserProvider>(context);
    final repositoryStore = RepositoryStore(context: context);

    return Scaffold(
      backgroundColor: kStockColor,
      body: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => SignInBloc(
                authRepo: repositoryStore.authRepository,
                userProvider: userProvider),
          ),
          BlocProvider(
              create: (context) => ExternalAuthBloc(
                  authRepo: repositoryStore.authRepository,
                  userProvider: userProvider))
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<SignInBloc, SignInStates>(
              listenWhen: (previous, current) =>
                  previous.appStatus != current.appStatus,
              listener: (context, state) {
                final formStatus = state.appStatus;
                if (formStatus is SubmissionFailed) {
                  if (formStatus.exception is UnAuthorized) {
                    simpleAlertBox(context, 'Whoops!',
                        'Hmm, we couldn\'t locate your account. Make sure your email and password is correct, and try logging in again.',
                        size: size,
                        buttonText: 'Understood',
                        onTap: () => Navigator.of(context).pop());
                  } else if (formStatus.exception is UserIsNotVerified) {
                    Navigator.pushReplacementNamed(
                      context,
                      otpPageRoute,
                      arguments: {
                        'reason': 'registration',
                        'email': state.email,
                      },
                    );
                  } else {
                    displayUnknownError(context);
                  }
                }
                if (formStatus is SubmissionSuccess) {
                  _goToHome(
                      context, userProvider.user.accessToken, userProvider);
                }
              },
            ),
            BlocListener<ExternalAuthBloc, ExternalAuthState>(
              listenWhen: (previous, current) =>
                  previous.appStatus != current.appStatus,
              listener: (context, state) {
                final formStatus = state.appStatus;
                if (formStatus is OAuthRequestSuccess) {
                  _goToHome(
                      context, userProvider.user.accessToken, userProvider);
                } else if (formStatus is OAuthRequestFailed) {
                  displayUnknownError(context);
                }
              },
            ),
          ],
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/images/logo.svg',
                    ),
                    SizedBox(height: size.height * 0.04),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size.width * 0.03),
                        color: kWhiteColor,
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: topPadding / 2,
                          left: size.width * 0.05,
                          right: size.width * 0.05,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              SizedBox(height: size.height * 0.01),
                              Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: size.width * 0.08,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              EmailGradiantInput(
                                  emailController: emailController,
                                  isLogin: true),
                              SizedBox(height: size.height * 0.02),
                              PasswordGradiantInput(
                                  passwordController: passwordController,
                                  isLogin: true),
                              SizedBox(height: size.height * 0.02),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, forgotPasswordPageRoute);
                                  },
                                  child: const Text(
                                    'Forgotten Password?',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              AuthButton(
                                isLogin: true,
                                formKey: _formKey,
                              ),
                              SizedBox(height: size.height * 0.02),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.03),
                    const Row(children: <Widget>[
                      Expanded(child: Divider()),
                      Text("  Login With  "),
                      Expanded(child: Divider()),
                    ]),
                    SizedBox(height: size.height * 0.03),
                    const GoogleAuthButton(),
                    SizedBox(height: size.height * 0.02),
                    GradientTextLineButton(
                      baseText: 'Don\'t have an account? ',
                      gradientText: 'Sign up',
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Roboto',
                          color: kGreyColor),
                      gradientColors: kGradColors,
                      onTap: () {
                        Navigator.pushReplacementNamed(
                            context, signUpPageRoute);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context, accessToken, userProvider) async {
    final Database db = await LocalDatabaseFactory().getDatabase();
    final IDatasource datasource = SqfliteDatasource(db);
    final SyncService syncService = SyncService(authService: InitAuthService(), datasource: datasource);
    await syncService.syncData();
    Navigator.pushNamedAndRemoveUntil(
        context, dashboardPageRoute, (route) => false,
        arguments: {'me': userProvider.user, 'access_token': accessToken});
  }
}
