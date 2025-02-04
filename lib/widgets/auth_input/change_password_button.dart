import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/change_pw/change_pw_bloc.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';

class ChangePasswordButton extends StatelessWidget {
  final List<Color> gradColors;
  final dynamic formKey;
  final String buttonText;
  final String uid;
  final String token;

  const ChangePasswordButton({super.key,
    required this.formKey,
    required this.gradColors,
    required this.buttonText,
    required this.uid,
    required this.token
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChangePWBloc, ChangePWStates>(
      builder: (context, state) {
        return CustomGradientButton(
            text: buttonText,
            gradColors: gradColors,
            isLoading: state.appStatus is FormSubmitting ? true : false,
            onPressed: () {
              if (formKey.currentState.validate()) {
                final bloc = context.read<ChangePWBloc>();
                bloc.add(UIDAdded(uid: uid));
                bloc.add(TokenAdded(token: token));
                bloc.add(EmailSubmitted());
              }
            });
      },
    );
  }
}
