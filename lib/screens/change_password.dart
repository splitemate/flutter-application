import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/widgets/common/back_to_login.dart';
import 'package:splitemate/widgets/auth_input/change_password_field.dart';
import 'package:splitemate/widgets/auth_input/change_password_button.dart';
import 'package:splitemate/widgets/auth_input/re_type_password_input_gradiant.dart';
import 'package:splitemate/states_management/bloc/change_pw/change_pw_bloc.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/widgets/popup/display_unknown_error.dart';
import 'package:splitemate/repository/repository_store.dart';

class ChangePassword extends StatefulWidget {
  final String uid;
  final String token;

  const ChangePassword({super.key, required this.uid, required this.token});

  @override
  State<ChangePassword> createState() => _changePasswordState();
}

class _changePasswordState extends State<ChangePassword> {
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
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
            ChangePWBloc(authRepo: repositoryStore.authRepository),
        child: BlocListener<ChangePWBloc, ChangePWStates>(
          listenWhen: (previous, current) =>
              previous.appStatus != current.appStatus,
          listener: (context, state) {
            final formStatus = state.appStatus;
            if (formStatus is SubmissionSuccess) {
              simpleAlertBox(context, 'Password Updated!',
                  'Your password is now fresh and secure. Back to login!',
                  size: size,
                  svgIconPath: 'assets/images/verified.svg',
                  buttonText: 'Go to Login', onTap: () {
                navigateToLogin(context);
              });
            } else if (formStatus is SubmissionFailed) {
              displayUnknownError(context);
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
                                      "Set New Password",
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
                                      'Design your new password and confirm it.',
                                      style: TextStyle(
                                        fontSize: size.width * 0.0445,
                                        fontFamily: 'roboto',
                                        color: kGreyColor,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.03),
                                  Form(
                                      key: _formKey,
                                      child: Column(
                                        children: <Widget>[
                                          ChangePasswordField(
                                              passwordController:
                                                  passwordController,
                                              labelText: 'New Password'),
                                          SizedBox(height: size.height * 0.02),
                                          ReTypePasswordGradiantInput(
                                            labelText: 'Confirm New Password',
                                            passwordController:
                                                passwordController,
                                            confirmPasswordController:
                                                confirmPasswordController,
                                          ),
                                          SizedBox(height: size.height * 0.02),
                                          ChangePasswordButton(
                                            buttonText: 'Change Password',
                                            gradColors: kGradColors,
                                            formKey: _formKey,
                                            uid: widget.uid,
                                            token: widget.token,
                                          ),
                                        ],
                                      )),
                                  SizedBox(height: size.height * 0.03),
                                  const BackToLogin(),
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
