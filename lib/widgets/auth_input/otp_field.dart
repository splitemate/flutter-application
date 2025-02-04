import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/states_management/bloc/otp/otp_bloc.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class OtpPinFieldWidget extends StatelessWidget {
  final dynamic otpPinFieldController;
  final Size size;

  const OtpPinFieldWidget({
    super.key,
    required this.otpPinFieldController,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return OtpPinField(
      key: otpPinFieldController,
      autoFocus: true,
      autoFillEnable: false,
      fieldHeight: size.width * 0.163,
      fieldWidth: size.width * 0.163,
      onSubmit: (text) {},
      onChange: (text) {
        context.read<OtpBloc>().add(OtpChanged(code: text));
      },
      onCodeChanged: (code) {},
      otpPinFieldStyle: const OtpPinFieldStyle(
        activeFieldBorderGradient: LinearGradient(colors: kGradColors),
        fieldBorderWidth: 1,
      ),
      maxLength: 4,
      showCursor: true,
      mainAxisAlignment: MainAxisAlignment.center,
      otpPinFieldDecoration: OtpPinFieldDecoration.defaultPinBoxDecoration,
    );
  }
}
