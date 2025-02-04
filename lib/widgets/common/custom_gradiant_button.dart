import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitemate/colors.dart';

class CustomGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final double? buttonHeight;
  final List<Color> gradColors;
  final String? prefixIconPath;
  final Color? textColor;

  const CustomGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradColors,
    this.buttonHeight,
    this.isLoading = false,
    this.prefixIconPath,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: buttonHeight ?? size.width * 0.1333,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.05,
          vertical: size.height * 0.01,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(size.width * 0.03),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (prefixIconPath != null)
              SvgPicture.asset(
                prefixIconPath!,
                width: size.width * 0.06,
              ),
            if (prefixIconPath != null) SizedBox(width: size.width * 0.03),
            if (!isLoading)
              Text(
                text,
                style: TextStyle(
                  fontSize: size.width * 0.05,
                  color: textColor ?? kWhiteColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              SizedBox(
                width: size.width * 0.045,
                height: size.width * 0.045,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(kWhiteColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
