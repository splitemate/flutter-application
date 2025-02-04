import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

class GradientTextLineButton extends StatelessWidget {
  final String baseText;
  final String gradientText;
  final TextStyle style;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const GradientTextLineButton({
    super.key,
    required this.baseText,
    required this.gradientText,
    required this.style,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: style,
        children: [
          TextSpan(
            text: baseText,
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: GestureDetector(
              onTap: onTap,
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: gradientColors,
                  ).createShader(bounds);
                },
                child: Text(
                  gradientText,
                  style: style.copyWith(color: kWhiteColor, fontWeight: FontWeight.w500), // Use transparent color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}