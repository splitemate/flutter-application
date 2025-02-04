import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/states_management/bloc/signup/signup_bloc.dart';
import 'package:splitemate/states_management/bloc/signin/signin_bloc.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({super.key, this.formKey, required this.isLogin});

  final dynamic formKey;
  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? BlocBuilder<SignInBloc, SignInStates>(
            builder: (context, state) {
              return CustomGradientButton(
                  text: 'Login',
                  gradColors: kGradColors,
                  isLoading: state.appStatus is FormSubmitting ? true : false,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      context.read<SignInBloc>().add(LoginSubmitted());
                    }
                  });
            },
          )
        : BlocBuilder<SignUpBloc, SignUpStates>(builder: (context, state) {
            return CustomGradientButton(
                text: 'Sign Up',
                gradColors: kGradColors,
                isLoading: state.appStatus is FormSubmitting ? true : false,
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    context.read<SignUpBloc>().add(RegisterSubmitted());
                  }
                });
          });
  }
}
