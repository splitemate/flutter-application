import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitemate/states_management/bloc/auth_status.dart';
import 'package:splitemate/states_management/bloc/otp/otp_bloc.dart';

class ResendOtpButton extends StatefulWidget {
  final String baseText;
  final String gradientText;
  final TextStyle style;
  final List<Color> gradientColors;
  final VoidCallback onTap;
  final String reasonCode;
  final String? userId;

  const ResendOtpButton(
      {super.key,
      required this.baseText,
      required this.gradientText,
      required this.style,
      required this.gradientColors,
      required this.onTap,
      required this.userId,
      required this.reasonCode});

  @override
  _ResendOtpButtonState createState() => _ResendOtpButtonState();
}

class _ResendOtpButtonState extends State<ResendOtpButton> {
  late Timer _timer = Timer(Duration.zero, () {});
  int _start = 30;
  bool _isVisible = true;

  void startTimer() {
    setState(() {
      _isVisible = false;
      _start = 30;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isVisible = true;
        });
        _timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _onTap(BuildContext context, OtpStates state, userId, reasonCode) async {
    context.read<OtpBloc>()
      ..add(OtpUidEmailReasonChanged(userId: userId, reason: reasonCode))
      ..add(OtpRequested());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OtpBloc, OtpStates>(
      listener: (context, state) {
        if (state.appStatus is OtpSentSuccess) {
          startTimer();
        }
      },
      builder: (context, state) {
        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              TextSpan(
                text: widget.baseText,
              ),
              if (_isVisible)
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: GestureDetector(
                    onTap: () => _onTap(
                        context, state, widget.userId, widget.reasonCode),
                    child: ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return LinearGradient(
                          colors: widget.gradientColors,
                        ).createShader(bounds);
                      },
                      child: Text(
                        widget.gradientText,
                        style: widget.style.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
              else
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return LinearGradient(
                        colors: widget.gradientColors,
                      ).createShader(bounds);
                    },
                    child: Text(
                      'Resend in $_start',
                      style: widget.style.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    );
  }
}
