import 'package:flutter/material.dart';

class AppColors {
  static const Color exbackground = Color(0xFFF5F5F5);
  static const Color exwwhite = Colors.white;
  static const Color exblue = Color(0xFF000428);
  static const Color primaryText = Color(
    0xFF212121,
  ); // Dark Gray for main titles/names
  static const Color secondaryText = Color(
    0xFF757575,
  ); // Medium Gray for subdued text/icons

  // Status Colors (used for Chips and Icons)
  static const Color successGreen = Color(
    0xFF4CAF50,
  ); // Green for Completed status
  static const Color warningAmber = Color(
    0xFFFFC107,
  ); // Amber/Yellow for Pending status
  // A color for errors, used in the StreamBuilder error state
  static const Color errorRed = Color(0xFFF44336);

  // --- Utility Colors (Optional, but good to have) ---
  static const Color backgroundLight = Colors.white;
  static const Color backgroundDark = Color(0xFFE0E0E0);
  static const Color dividerColor = Color(0xFFBDBDBD);
  // Shade definitions for convenience (if needed, otherwise rely on Flutter shades)
  static const MaterialColor exblueMaterial = MaterialColor(
    0xFF1E88E5,
    <int, Color>{
      50: Color(0xFFE3F2FD),
      100: Color(0xFFBBDEFB),
      200: Color(0xFF90CAF9),
      300: Color(0xFF64B5F6),
      400: Color(0xFF42A5F5),
      500: Color(0xFF2196F3),
      600: Color(0xFF1E88E5), // Base color
      700: Color(0xFF1976D2),
      800: Color(0xFF1565C0),
      900: Color(0xFF0D47A1),
    },
  );
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
