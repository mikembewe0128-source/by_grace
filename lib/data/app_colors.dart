import 'package:flutter/material.dart';

class AppColors {
  static const Color exbackground = Color(0xFFF5F5F5);
  static const Color exwwhite = Colors.white;
  static const Color exblue = Color(0xFF000428);
}

final LinearGradient gradientNumber5 = LinearGradient(
  colors: [
    Color(0xFF0F52BA), // Royal Blue
    Color(0xFF000428), // Dark N/ Deep Navy
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);
final LinearGradient gradientNumber4 = LinearGradient(
  colors: [
    Color(0xFF002366), // Deep Royal Blue
    Color(0xFF000428), // Almost Black Navy
  ],
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
);
