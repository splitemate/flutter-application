import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/states_management/bloc/signup/signup_bloc.dart';
import 'package:splitemate/states_management/bloc/external_auth/external_auth_bloc.dart';
import 'package:splitemate/widgets/common/gradient_text_line_button.dart';
import 'package:splitemate/widgets/auth_input/google_auth_button.dart';
import 'package:splitemate/widgets/auth_input/name_gradiant_input.dart';
import 'package:splitemate/widgets/auth_input/auth_button.dart';
import 'package:splitemate/repository/repository_store.dart';
import 'package:splitemate/widgets/auth_input/re_type_password_input_gradiant.dart';
import 'package:splitemate/widgets/auth_input/email_gradiant_input.dart';
import 'package:splitemate/widgets/auth_input/password_input_gradiant.dart';
import 'package:splitemate/widgets/popup/display_unknown_error.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
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
              create: (context) => SignUpBloc(
                  authRepo: repositoryStore.authRepository,
                  userProvider: userProvider)),
          BlocProvider(
              create: (context) => ExternalAuthBloc(
                  authRepo: repositoryStore.authRepository,
                  userProvider: userProvider))
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<SignUpBloc, SignUpStates>(
                listenWhen: (previous, current) =>
                    previous.appStatus != current.appStatus,
                listener: (context, state) {
                  final formStatus = state.appStatus;

                  if (formStatus is SubmissionFailed) {
                    if (formStatus.exception is UserAlreadyCreated) {
                      simpleAlertBox(context, 'Whoops!',
                          'Looks like you\'re already part of the club! An account with this email already exists. Try logging in or resetting your password if you\'ve forgotten it.',
                          size: size,
                          buttonText: 'Understood',
                          onTap: () => Navigator.of(context).pop());
                    } else {
                      displayUnknownError(context);
                    }
                  }
                  if (formStatus is SubmissionSuccess) {
                    Navigator.pushNamed(
                      context,
                      otpPageRoute,
                      arguments: {
                        'reason': 'registration',
                        'email': '',
                      },
                    );
                  }
                }),
            BlocListener<ExternalAuthBloc, ExternalAuthState>(
              listenWhen: (previous, current) =>
                  previous.appStatus != current.appStatus,
              listener: (context, state) {
                final formStatus = state.appStatus;
                if (formStatus is OAuthRequestSuccess) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    dashboardPageRoute,
                    (route) => false,
                    arguments: {
                      'access_token': userProvider.user.accessToken,
                      'me': userProvider.user,
                    },
                  );
                } else if (formStatus is OAuthRequestFailed) {
                  displayUnknownError(context);
                }
              },
            )
          ],
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPadding / 2),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: size.height * 0.01),
                        SvgPicture.asset(
                          'assets/images/logo.svg',
                        ),
                        SizedBox(height: size.height * 0.04),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(size.width * 0.03),
                            color: kWhiteColor,
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: topPadding / 2,
                                left: size.width * 0.05,
                                right: size.width * 0.05),
                            child: Column(children: <Widget>[
                              Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: size.width * 0.08,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              NameGradiantInput(nameController: nameController),
                              SizedBox(height: size.height * 0.02),
                              EmailGradiantInput(
                                  emailController: emailController,
                                  isLogin: false),
                              SizedBox(height: size.height * 0.02),
                              PasswordGradiantInput(
                                  passwordController: passwordController,
                                  isLogin: false),
                              SizedBox(height: size.height * 0.02),
                              ReTypePasswordGradiantInput(
                                labelText: 'Re-Type Password',
                                passwordController: passwordController,
                                confirmPasswordController:
                                    confirmPasswordController,
                              ),
                              SizedBox(height: size.height * 0.04),
                              AuthButton(
                                isLogin: false,
                                formKey: _formKey,
                              ),
                              SizedBox(height: size.height * 0.02),
                            ]),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        const Row(children: <Widget>[
                          Expanded(child: Divider()),
                          Text("  Sign Up With  "),
                          Expanded(child: Divider()),
                        ]),
                        SizedBox(height: size.height * 0.03),
                        const GoogleAuthButton(),
                        SizedBox(height: size.height * 0.02),
                        GradientTextLineButton(
                          baseText: 'Already Have An Account? ',
                          gradientText: 'Log In',
                          style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Roboto',
                              color: kGreyColor),
                          gradientColors: kGradColors,
                          onTap: () {
                            navigateToLogin(context);
                          },
                        ),
                        SizedBox(height: size.height * 0.02),
                      ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
