import 'package:flutter/material.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/screens/change_password.dart';
import 'package:splitemate/screens/dashboard.dart';
import 'package:splitemate/screens/error.dart';
import 'package:splitemate/screens/forgot_password.dart';
import 'package:splitemate/screens/login.dart';
import 'package:splitemate/screens/on_boarding.dart';
import 'package:splitemate/screens/otp.dart';
import 'package:splitemate/screens/signup.dart';

class RouterNavigator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboardPageRoute:
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
              builder: (_) => Dashboard(
                    me: args['me'],
                    accessToken: args['access_token'],
                  ));
        } else {
          return MaterialPageRoute(builder: (_) => const ErrorPage());
        }

      case logInPageRoute:
        return MaterialPageRoute(builder: (_) => const Login());

      case signUpPageRoute:
        return MaterialPageRoute(builder: (_) => const SignUp());

      case otpPageRoute:
        if (settings.arguments is Map<String, String>) {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (_) => Otp(
              reason: args['reason']!,
              email: args['email']!,
            ),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const ErrorPage());
        }

      case onBoardingPageRoute:
        return MaterialPageRoute(builder: (_) => OnboardingPage());

      case forgotPasswordPageRoute:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());

      case changePasswordPageRoute:
        if (settings.arguments is Map<String, String>) {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (_) => ChangePassword(
              uid: args['uid']!,
              token: args['token']!,
            ),
          );
        } else {
          return MaterialPageRoute(builder: (_) => const ErrorPage());
        }

      default:
        return MaterialPageRoute(builder: (_) => OnboardingPage());
    }
  }
}
