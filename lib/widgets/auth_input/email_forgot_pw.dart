import 'package:flutter/material.dart';
import 'package:splitemate/utils/validators/email_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/widgets/common/gradient_border_text_field.dart';
import 'package:splitemate/states_management/bloc/forgot_pw/forgot_pw_bloc.dart';


class EmailForgotPw extends StatelessWidget {
  const EmailForgotPw({super.key, required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPWBloc, ForgotPwStates>(builder: (context, state) {
      return GradientBorderTextField(
        labelText: 'E-mail',
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        validator: emailValidator,
        onChange: (value) => context
            .read<ForgotPWBloc>()
            .add(ForgotPwEmailChanged(email: value)),
      );
    });
  }
}
