import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

class ActionButtons extends StatelessWidget {
  final Size size;
  final String leftButtonText;
  final String rightButtonText;
  final VoidCallback? onLeftButtonPressed;
  final VoidCallback? onRightButtonPressed;
  final Color leftButtonColor;
  final Color rightButtonColor;

  const ActionButtons({
    super.key,
    required this.size,
    required this.leftButtonText,
    required this.rightButtonText,
    this.onLeftButtonPressed,
    this.onRightButtonPressed,
    this.leftButtonColor = kRedColor,
    this.rightButtonColor = kGreenColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(size.width * 0.04),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: size.height * 0.06,
              decoration: BoxDecoration(
                color: leftButtonColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: onLeftButtonPressed,
                child: Text(
                  leftButtonText,
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GT-Walsheim-Pro',
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Container(
              height: size.height * 0.06,
              decoration: BoxDecoration(
                color: rightButtonColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: onRightButtonPressed,
                child: Text(
                  rightButtonText,
                  style: TextStyle(
                    color: kWhiteColor,
                    fontSize: size.width * 0.04,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GT-Walsheim-Pro',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 