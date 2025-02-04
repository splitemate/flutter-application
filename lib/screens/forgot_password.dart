import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/repository/repository_store.dart';
import 'package:splitemate/widgets/common/back_to_login.dart';
import 'package:splitemate/states_management/bloc/forgot_pw/forgot_pw_bloc.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/widgets/auth_input/email_forgot_pw.dart';
import 'package:splitemate/widgets/auth_input/forgot_password.dart';
import 'package:splitemate/widgets/popup/display_unknown_error.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late TextEditingController emailController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var horizontalPadding = size.width * 0.1;
    var topPadding = size.height * 0.05;
    final repositoryStore = RepositoryStore(context: context);

    return Scaffold(
      backgroundColor: kStockColor,
      body: BlocProvider(
        create: (context) =>
            ForgotPWBloc(authRepo: repositoryStore.authRepository),
        child: BlocListener<ForgotPWBloc, ForgotPwStates>(
          listenWhen: (previous, current) =>
              previous.appStatus != current.appStatus,
          listener: (context, state) {
            final formStatus = state.appStatus;
            if (formStatus is SubmissionFailed) {
              if (formStatus.exception is UserNotFound) {
                simpleAlertBox(context, 'Email Address Unrecognized',
                    'We couldn’t find an account with that email. Please verify your email address or sign up for a new account.',
                    size: size,
                    buttonText: 'Understood',
                    onTap: () => Navigator.of(context).pop());
              } else {
                displayUnknownError(context);
              }
            }
            if (formStatus is SubmissionSuccess) {
              Navigator.pushReplacementNamed(
                context,
                otpPageRoute,
                arguments: {
                  'reason': 'forgot_password',
                  'email': state.email,
                },
              );
            }
          },
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
                                'Forgot Password?',
                                style: TextStyle(
                                  fontSize: size.width * 0.08,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: size.height * 0.02),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: size.height * 0.017),
                                child: Text(
                                  'Enter your email, and we’ll send you a OTP to reset your password',
                                  style: TextStyle(
                                    fontSize: size.width * 0.0445,
                                    fontFamily: 'roboto',
                                    color: kGreyColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(height: size.height * 0.03),
                              EmailForgotPw(
                                emailController: emailController,
                              ),
                              SizedBox(height: size.height * 0.03),
                              ForgotPWButton(
                                formKey: _formKey,
                              ),
                              SizedBox(height: size.height * 0.03),
                              const BackToLogin()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
