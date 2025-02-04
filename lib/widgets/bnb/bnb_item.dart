import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomNavItem extends StatelessWidget {
  final Size size;
  final String assetPath;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final List<Color> activeGradientColors;
  final Color? inactiveColor;


  const BottomNavItem({
    super.key,
    required this.size,
    required this.assetPath,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.activeGradientColors,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isActive
              ? ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: activeGradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: SvgPicture.asset(
                    assetPath,
                    colorFilter: isActive
                        ? const ColorFilter.mode(Colors.white, BlendMode.srcIn)
                        : null,
                  ),
                )
              : SvgPicture.asset(
                  assetPath,
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.033,
              foreground: isActive
                  ? (Paint()
                    ..shader = _gradientTextShader(activeGradientColors))
                  : null,
              color: isActive ? null : inactiveColor ?? Colors.grey,

            ),
          ),
        ],
      ),
    );
  }

  Shader _gradientTextShader(List<Color> colors) {
    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
  }
}
