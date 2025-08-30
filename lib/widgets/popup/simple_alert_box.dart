import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:splitemate/colors.dart';
import 'package:splitemate/widgets/common/custom_gradiant_button.dart';
import 'package:splitemate/widgets/common/simple_button.dart';

void simpleAlertBox(
    BuildContext context,
    String title,
    String content, {
      required Size size,
      String? svgIconPath,
      String buttonText = '',
      void Function()? onTap,
      String? secondButtonText,
      void Function()? onSecondButtonTap,
      List<Color>? secondButtonColors,
      Color? secondButtonTextColor,
    }) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(size.width * 0.03),
        ),
        contentPadding: EdgeInsets.all(size.width * 0.05),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(height: size.height * 0.02),
            if (svgIconPath != null)
              SvgPicture.asset(
                svgIconPath,
                height: size.width * 0.1778,
                width: size.width * 0.1778,
              ),
            SizedBox(height: size.height * 0.02),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: size.width * 0.0667,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              content,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: size.width * 0.0444,
                  fontFamily: 'Roboto',
                  color: Colors.grey
              ),
            ),
          ],
        ),
        actions: <Widget>[
          if (secondButtonText != null)
            Row(
              children: [
                Expanded(
                  child: CustomGradientButton(
                    text: buttonText,
                    onPressed: onTap ?? () => Navigator.of(context).pop(),
                    gradColors: kGradColors,
                    textColor: kBlackColor,
                    isOutlined: true,
                    borderWidth: 1.0,
                  ),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: CustomGradientButton(
                    text: secondButtonText,
                    onPressed: onSecondButtonTap ?? () => Navigator.of(context).pop(),
                    gradColors: secondButtonColors ?? [kRedColor, kRedColor],
                    textColor: secondButtonTextColor ?? kWhiteColor,
                  ),
                ),
              ],
            )
          else
            CustomGradientButton(
              text: buttonText,
              onPressed: onTap ?? () => Navigator.of(context).pop(),
              gradColors: kGradColors,
            ),
        ],
      );
    },
  );
}
