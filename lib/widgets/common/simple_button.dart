import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SimpleButton extends StatelessWidget {
  final String iconPath;
  final String buttonText;
  final VoidCallback onPressed;
  final double buttonHeight;
  final Color backGroundColor;
  final Color foreGroundColor;

  const SimpleButton({
    super.key,
    required this.iconPath,
    required this.buttonText,
    required this.onPressed,
    required this.buttonHeight,
    required this.backGroundColor,
    required this.foreGroundColor
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(backGroundColor),
        foregroundColor: WidgetStateProperty.all<Color>(foreGroundColor),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        minimumSize: WidgetStateProperty.all<Size>(
          Size(double.infinity, buttonHeight),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconPath,
          ),
          SizedBox(width: size.height * 0.007),
          Text(buttonText),
        ],
      ),
    );
  }
}
