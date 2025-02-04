import 'package:flutter/material.dart';
import 'package:splitemate/utils/validators/password_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/change_pw/change_pw_bloc.dart';
import 'package:splitemate/widgets/common/gradient_border_text_field.dart';

class ChangePasswordField extends StatelessWidget {
  const ChangePasswordField(
      {super.key, required this.passwordController, required this.labelText});

  final String labelText;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePWBloc, ChangePWStates>(builder: (context, state) {
      return GradientBorderTextField(
        labelText: labelText,
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        validator: passwordValidator,
        onChange: (value) => context
            .read<ChangePWBloc>()
            .add(PasswordChanged(password: value)),
      );
    });
  }
}
