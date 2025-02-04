import 'package:flutter/cupertino.dart';
import 'package:splitemate/colors.dart';

class FloatingCentralButton extends StatelessWidget {
  const FloatingCentralButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      top: 0,
      child: Container(
        width: 50.0,
        height: 50.0,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: kGradColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child:GestureDetector(
          onTap: () {
          },
          child: const Center(
            child: SizedBox(
                width: 35.0,
                height: 35.0,
                child: Icon(
                  CupertinoIcons.plus,
                  color: kWhiteColor,
                )
            ),
          ),
        ),
      ),
    );
  }
}