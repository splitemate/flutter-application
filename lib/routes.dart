import 'package:flutter/material.dart';

const String onBoardingPageRoute = '/on_boarding';
const String signUpPageRoute = '/signup';
const String logInPageRoute = '/login';
const String forgotPasswordPageRoute = '/forgot_password';
const String changePasswordPageRoute = '/change_password';
const String otpPageRoute = '/otp';
const String dashboardPageRoute = '/dashboard';
const String errorPageRoute = '/error';

void navigateToLogin(BuildContext context) {
  Navigator.pushReplacementNamed(context, logInPageRoute);
}
