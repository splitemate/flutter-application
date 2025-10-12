import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitemate/states_management/bloc/external_auth/external_auth_bloc.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/routes.dart';
import 'package:splitemate/models/current_user.dart';
import 'package:splitemate/data/factories/db_factory.dart';
import 'package:sqflite/sqflite.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ExternalAuthBloc, ExternalAuthState>(
      listenWhen: (previous, current) => previous.appStatus != current.appStatus,
      listener: (context, state) {
        final appStatus = state.appStatus;
        if (appStatus is OAuthRequestSuccess) {
          // Navigate to dashboard after successful Google auth
          _navigateToDashboard(context);
        } else if (appStatus is OAuthRequestFailed) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google authentication failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: BlocBuilder<ExternalAuthBloc, ExternalAuthState>(
        builder: (context, state) {
          return TextButton.icon(
            onPressed: state.appStatus is OAuthSubmitted 
                ? null 
                : () => context.read<ExternalAuthBloc>().add(DataSubmitted()),
            icon: SvgPicture.asset(
              'assets/images/google_icon.svg',
              height: 24,
              width: 24,
            ),
            label: Text(
              state.appStatus is OAuthSubmitted 
                  ? 'Signing in...' 
                  : 'Continue with Google'
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 50),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDashboard(BuildContext context) async {
    try {
      // Get the current user from the bloc context
      final externalAuthBloc = context.read<ExternalAuthBloc>();
      final userProvider = externalAuthBloc.userProvider;
      final currentUser = userProvider.user;
      
      if (currentUser.accessToken.isNotEmpty) {
        // Navigate to dashboard with proper arguments
        Navigator.pushNamedAndRemoveUntil(
          context, 
          dashboardPageRoute, 
          (route) => false,
          arguments: {
            'me': currentUser,
            'access_token': currentUser.accessToken, // Fixed: use 'access_token' key
          },
        );
      } else {
        throw Exception('Access token not available');
      }
    } catch (e) {
      print('Navigation error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Navigation failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
