import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/states_management/bloc/forgot_pw/forgot_pw_bloc.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';

class ForgotPWButton extends StatelessWidget {
  final dynamic formKey;

  const ForgotPWButton({super.key, this.formKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgotPWBloc, ForgotPwStates>(
      builder: (context, state) {
        return CustomGradientButton(
            text: 'Send OTP',
            gradColors: kGradColors,
            isLoading: state.appStatus is FormSubmitting ? true : false,
            onPressed: () {
              if (formKey.currentState.validate()) {
                context
                    .read<ForgotPWBloc>()
                    .add(ForgotPwEmailChangedSubmitted());
              }
            });
      },
    );
  }
}
