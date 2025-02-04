import 'package:flutter/material.dart';
import 'package:splitemate/utils/validators/name_validator.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/signup/signup_bloc.dart';
import 'package:splitemate/widgets/common/gradient_border_text_field.dart';

class NameGradiantInput extends StatelessWidget {
  const NameGradiantInput({super.key, required this.nameController});

  final TextEditingController nameController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SignUpBloc, SignUpStates>(builder: (context, state) {
      return GradientBorderTextField(
        labelText: 'Name',
        controller: nameController,
        keyboardType: TextInputType.name,
        validator: nameValidator,
        onChange: (value) =>
            context.read<SignUpBloc>().add(RegisterNameChanged(name: value)),
      );
    });
  }
}
