import 'package:flutter/material.dart';
import 'package:splitemate/utils/validators/password_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/signup/signup_bloc.dart';
import 'package:splitemate/states_management/bloc/signin/signin_bloc.dart';
import 'package:splitemate/widgets/common/gradient_border_text_field.dart';

class PasswordGradiantInput extends StatelessWidget {
  const PasswordGradiantInput(
      {super.key, required this.passwordController, required this.isLogin});

  final TextEditingController passwordController;
  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? BlocBuilder<SignInBloc, SignInStates>(builder: (context, state) {
            return GradientBorderTextField(
              labelText: 'Password',
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              validator: passwordValidator,
              onChange: (value) => context
                  .read<SignInBloc>()
                  .add(LoginPasswordChanged(password: value)),
            );
          })
        : BlocBuilder<SignUpBloc, SignUpStates>(builder: (context, state) {
            return GradientBorderTextField(
              labelText: 'Password',
              controller: passwordController,
              keyboardType: TextInputType.visiblePassword,
              validator: passwordValidator,
              onChange: (value) => context
                  .read<SignUpBloc>()
                  .add(RegisterPasswordChanged(password: value)),
            );
          });
  }
}
