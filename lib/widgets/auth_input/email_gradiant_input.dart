import 'package:flutter/material.dart';
import 'package:splitemate/utils/validators/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/signup/signup_bloc.dart';
import 'package:splitemate/states_management/bloc/signin/signin_bloc.dart';
import 'package:splitemate/widgets/common/gradient_border_text_field.dart';

class EmailGradiantInput extends StatelessWidget {
  const EmailGradiantInput(
      {super.key, required this.emailController, required this.isLogin});

  final TextEditingController emailController;
  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? BlocBuilder<SignInBloc, SignInStates>(builder: (context, state) {
            return GradientBorderTextField(
              labelText: 'E-mail',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              onChange: (value) => context
                  .read<SignInBloc>()
                  .add(LoginEmailChanged(email: value)),
            );
          })
        : BlocBuilder<SignUpBloc, SignUpStates>(builder: (context, state) {
            return GradientBorderTextField(
              labelText: 'E-mail',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              validator: emailValidator,
              onChange: (value) => context
                  .read<SignUpBloc>()
                  .add(RegisterEmailChanged(email: value)),
            );
          });
  }
}
