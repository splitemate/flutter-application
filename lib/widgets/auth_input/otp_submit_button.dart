import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/otp/otp_bloc.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';

class VerifyOtpButton extends StatelessWidget {
  final String reasonCode;
  final String userId;
  final String email;
  final List<Color> gradColors;
  final String buttonText;

  const VerifyOtpButton({
    super.key,
    required this.reasonCode,
    required this.userId,
    required this.email,
    required this.gradColors,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    bool useId = (email.isEmpty) ? true : false;

    return BlocBuilder<OtpBloc, OtpStates>(
      builder: (context, state) {
        return CustomGradientButton(
            text: buttonText,
            gradColors: gradColors,
            isLoading: state.appStatus is FormSubmitting ? true : false,
            onPressed: () {
              final bloc = context.read<OtpBloc>();
              if (useId) {
                bloc.add(OtpUidEmailReasonChanged(
                    userId: userId, reason: reasonCode, email: ''));
              } else {
                bloc.add(OtpUidEmailReasonChanged(
                    userId: '', reason: reasonCode, email: email));
              }
              bloc.add(OtpSubmitted());
            });
      },
    );
  }
}
