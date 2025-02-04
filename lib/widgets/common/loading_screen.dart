import 'package:flutter/material.dart';
import 'dart:math';

Widget _buildLoadingScreen(BuildContext context) {
  return MaterialApp(
    title: 'Splitemate',
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(),
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildGlowingOrb(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Initializing Splitemate...",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                _buildAnimatedDots(),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildGlowingOrb() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.8, end: 1.2),
    duration: const Duration(seconds: 1),
    curve: Curves.easeInOut,
    builder: (context, scale, child) {
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
        ),
      );
    },
    onEnd: () {
      Future.delayed(const Duration(milliseconds: 500), () {
        _buildGlowingOrb();
      });
    },
  );
}

Widget _buildAnimatedDots() {
  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.0, end: 1.0),
    duration: const Duration(seconds: 1),
    builder: (context, opacity, child) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Opacity(
              opacity: opacity * (index + 1) / 3,
              child: const Icon(Icons.circle, color: Colors.blue, size: 12),
            ),
          );
        }),
      );
    },
  );
}
