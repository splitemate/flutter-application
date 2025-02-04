import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/routes.dart';
import 'package:provider/provider.dart';
import 'package:splitemate/exceptions/exceptions.dart';
import 'package:splitemate/providers/user_provider.dart';
import 'package:splitemate/states_management/bloc/otp/otp_bloc.dart';
import 'package:splitemate/widgets/auth_input/otp_field.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/widgets/auth_input/otp_resend_button.dart';
import 'package:splitemate/repository/repository_store.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/widgets/auth_input/otp_submit_button.dart';
import 'package:splitemate/widgets/common/back_to_login.dart';
import 'package:splitemate/widgets/popup/display_unknown_error.dart';

class Otp extends StatefulWidget {
  final String reason;
  final String email;

  const Otp({super.key, required this.reason, required this.email});

  @override
  State<Otp> createState() => _otpState();
}

class _otpState extends State<Otp> {
  final _otpPinFieldController = GlobalKey<OtpPinFieldState>();

  final Map<String, Map<String, dynamic>> reasonsMap = {
    'registration': {
      'header': 'Verify your email',
      'reason_code': 'EV',
      'alert_header': 'Email Verified!',
      'alert_message':
          'Welcome aboard to SpliteMate! Your email is now verified.',
      'alert_button_name': 'Get Started',
      'use_id': true
    },
    'forgot_password': {
      'header': 'Reset your password',
      'reason_code': 'PR',
      'use_id': false
    },
  };

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var horizontalPadding = size.width * 0.1;
    var topPadding = size.height * 0.05;

    final userProvider = Provider.of<UserProvider>(context);
    final repositoryStore = RepositoryStore(context: context);
    final reasonDetails = reasonsMap[widget.reason] ?? {};

    return Scaffold(
      backgroundColor: kStockColor,
      body: BlocProvider(
        create: (context) => OtpBloc(
            authRepo: repositoryStore.authRepository,
            userProvider: userProvider),
        child: BlocListener<OtpBloc, OtpStates>(
          listenWhen: (previous, current) =>
              previous.appStatus != current.appStatus,
          listener: (context, state) {
            final formStatus = state.appStatus;
            if (formStatus is SubmissionSuccess) {
              if (widget.reason == "forgot_password") {
                Navigator.pushReplacementNamed(context, changePasswordPageRoute,
                    arguments: {'uid': state.uid, 'token': state.token});
              } else {
                simpleAlertBox(context, reasonDetails['alert_header'],
                    reasonDetails['alert_message'],
                    size: size,
                    svgIconPath: 'assets/images/verified.svg',
                    buttonText: reasonDetails['alert_button_name'], onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    dashboardPageRoute,
                    (route) => false,
                    arguments: {
                      'access_token': userProvider.user.accessToken,
                      'me': userProvider.user,
                    },
                  );
                });
              }
            } else if (formStatus is SubmissionFailed) {
              if (formStatus.exception is InvalidOTP) {
                simpleAlertBox(context, 'Oops! Wrong Code',
                    'The OTP you’ve entered is not correct. Please check your code and try again.',
                    size: size,
                    buttonText: 'Understood',
                    onTap: () => Navigator.of(context).pop());
              } else {
                displayUnknownError(context);
              }
            } else if (formStatus is OtpSentSuccess) {
              const snackBar = SnackBar(
                  content: Text(
                      'We’ve sent a new OTP to your email. Check it out!'));
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            } else if (formStatus is OtpSentFailed) {
              if (formStatus.exception is OtpLimitExceed) {
                const snackBar = SnackBar(
                    content:
                        Text('Too many attempts. Please try again later.'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                displayUnknownError(context);
              }
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
                              borderRadius:
                                  BorderRadius.circular(size.width * 0.03),
                              color: kWhiteColor,
                            ),
                            child: Padding(
                              padding: EdgeInsets.only(
                                top: topPadding / 2,
                                left: size.width * 0.08,
                                right: size.width * 0.08,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: size.height * 0.01),
                                  Center(
                                    child: Text(
                                      reasonDetails['header'],
                                      style: TextStyle(
                                        fontSize: size.width * 0.066,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.height * 0.033),
                                    child: Text(
                                      'We send you a code to verify your Email Address',
                                      style: TextStyle(
                                        fontSize: size.width * 0.0445,
                                        fontFamily: 'roboto',
                                        color: kGreyColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                      colors: kGradColors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ).createShader(bounds),
                                    child: Text(
                                      'Enter the OTP code',
                                      style: TextStyle(
                                        fontSize: size.width * 0.0444,
                                        fontWeight: FontWeight.bold,
                                        color: kWhiteColor,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  OtpPinFieldWidget(
                                    size: size,
                                    otpPinFieldController:
                                        _otpPinFieldController,
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  VerifyOtpButton(
                                    reasonCode: reasonDetails['reason_code'],
                                    userId: userProvider.user.id,
                                    email: widget.email,
                                    buttonText: 'Verify',
                                    gradColors: kGradColors,
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Center(
                                    child: Column(
                                      children: [
                                        ResendOtpButton(
                                          baseText:
                                              'Didn’t receive the code yet? ',
                                          gradientText: 'Resend',
                                          gradientColors: kGradColors,
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: 'Roboto',
                                              color: kGreyColor),
                                          onTap: () {},
                                          userId: userProvider.user.id,
                                          reasonCode:
                                              reasonDetails['reason_code'],
                                        ),
                                        SizedBox(height: size.height * 0.03),
                                        const BackToLogin()
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ))
                      ])),
            ),
          ),
        ),
      ),
    );
  }
}
