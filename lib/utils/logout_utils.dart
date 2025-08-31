import 'package:flutter/material.dart';
import 'package:splitemate/service/logout_service.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/widgets/popup/simple_alert_box.dart';
import 'package:splitemate/colors.dart';

class LogoutUtils {
  /// Quick logout method that can be called from anywhere
  static Future<void> quickLogout(BuildContext context) async {
    try {
      // Perform comprehensive logout
      await LogoutService().performLogout(context);

      // Navigate to onboarding page and clear all routes
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          onBoardingPageRoute,
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          onBoardingPageRoute,
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  /// Logout with confirmation dialog
  static void logoutWithConfirmation(BuildContext context) {
    simpleAlertBox(
      context,
      'Confirm Logout',
      'Are you sure you want to logout?',
      size: MediaQuery.of(context).size,
      buttonText: 'Cancel',
      onTap: () => Navigator.of(context).pop(),
      secondButtonText: 'Logout',
      onSecondButtonTap: () {
        Navigator.of(context).pop();
        quickLogout(context);
      },
      secondButtonColors: [kRedColor, kRedColor],
      secondButtonTextColor: kWhiteColor,
    );
  }
}
