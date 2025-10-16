import 'package:flutter/material.dart';

class GlobalWidgets {
  // context
  final BuildContext context;

  // constructor
  GlobalWidgets(this.context);

  // show snackbar
  void showSnackBar({required String content, Color? backgroundColor}) {
    final Color effectiveBackgroundColor =
        backgroundColor ?? Colors.grey.shade900;
    const Duration duration = Duration(
      milliseconds: 2500,
    ); // Slightly longer duration
    const double borderRadius = 10.0; // Rounded corners

    // 2. Get screen width for max width constraint
    final double screenWidth = MediaQuery.of(context).size.width;
    // 3. Define horizontal padding/margin to keep it centered and away from edges
    const double horizontalMargin = 16.0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          content,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
          ), // Ensure content is white for dark backgrounds
        ),

        // 4. Modern Positioning: SnackBarBehavior.floating
        // Makes the SnackBar float above the bottom navigation bar/content.
        behavior: SnackBarBehavior.floating,

        // 5. Modern Shape: RoundedRectangleBorder
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),

        // 6. Modern Elevation: Add a visible shadow
        elevation: 6.0,

        // 7. Modern Margin: Add padding around the SnackBar
        // This is necessary when behavior is SnackBarBehavior.floating
        margin: const EdgeInsets.symmetric(
          horizontal: horizontalMargin,
          vertical: 20,
        ),

        // 8. Styling
        backgroundColor: effectiveBackgroundColor,
        duration: duration,

        // Optional: Constrain max width for better look on large screens (like tablets)
        width: screenWidth > 600
            ? 500
            : null, // Set a max width of 500 on wider screens
      ),
    );
  }
}
