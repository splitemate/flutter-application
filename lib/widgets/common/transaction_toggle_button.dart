import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

class TransactionToggleButton extends StatelessWidget {
  final String text;
  final int toggleIndex;
  final int currentIndex;
  final VoidCallback onTap;

  const TransactionToggleButton({
    super.key,
    required this.text,
    required this.toggleIndex,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isActive = toggleIndex == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient:
                isActive ? const LinearGradient(colors: kGradColors) : null,
            color: isActive ? null : kWhiteColor,
            borderRadius: BorderRadius.circular(size.width * 0.0333),
          ),
          alignment: Alignment.center, // ✅ Optimized layout
          padding: EdgeInsets.symmetric(vertical: size.width * 0.0278),
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? kWhiteColor : kGreyColor,
              fontSize: size.width * 0.044,
            ),
          ),
        ),
      ),
    );
  }
}
