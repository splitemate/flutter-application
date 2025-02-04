import 'package:flutter/material.dart';
import 'package:splitemate/routes.dart';

class BackToLogin extends StatelessWidget {
  const BackToLogin({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: () => navigateToLogin(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.grey),
                  SizedBox(width: size.height * 0.01),
                  const Text(
                    'Back to login',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: size.height * 0.02)
        ],
      ),
    );
  }
}
