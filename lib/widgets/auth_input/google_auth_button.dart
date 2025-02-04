import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitemate/states_management/bloc/external_auth/external_auth_bloc.dart';

class GoogleAuthButton extends StatelessWidget {
  const GoogleAuthButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExternalAuthBloc, ExternalAuthState>(
        builder: (context, state) {
      return TextButton.icon(
        onPressed: () => context.read<ExternalAuthBloc>().add(DataSubmitted()),
        icon: SvgPicture.asset(
          'assets/images/google_icon.svg',
          height: 24,
          width: 24,
        ),
        label: const Text('Continue with Google'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 50),
        ),
      );
    });
  }
}
