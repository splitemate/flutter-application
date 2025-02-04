import 'package:flutter/material.dart';
import 'package:splitemate/utils/validators/password_validator.dart';
import 'package:splitemate/widgets/common/gradient_border_text_field.dart';

class ReTypePasswordGradiantInput extends StatelessWidget {
  const ReTypePasswordGradiantInput(
      {required this.labelText, super.key, required this.passwordController, required this.confirmPasswordController});

  final String labelText;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    return GradientBorderTextField(
      labelText: labelText,
      controller: confirmPasswordController,
      keyboardType: TextInputType.visiblePassword,
      validator: (value) => passwordValidator(
          value, passwordController.text),
    );
  }
}
