import 'package:flutter/material.dart';
import 'package:splitemate/colors.dart';

class NewMessageIndicator extends StatelessWidget {
  final VoidCallback onTap;
  final int messageCount;
  final bool isVisible;

  const NewMessageIndicator({
    Key? key,
    required this.onTap,
    required this.messageCount,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible || messageCount == 0) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kStockColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: kBlackColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$messageCount new message${messageCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    color: kBlackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 