import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

class GradiantEndText extends StatelessWidget {
  final String leadingText;
  final String endingText;

  const GradiantEndText({
    super.key,
    required this.leadingText,
    required this.endingText,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            TextSpan(
              text: leadingText,
              style: TextStyle(
                fontSize: size.width * 0.0444,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.bold,
                color: kBlackColor,
              ),
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: kGradColors,
                  ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height));
                },
                child: Text(
                  endingText,
                  style: TextStyle(
                      fontSize: size.width * 0.0444,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
