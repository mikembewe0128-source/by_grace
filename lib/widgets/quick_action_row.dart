import 'package:flutter/material.dart';
import 'package:grace_by/widgets/divider_widget.dart';
// Assuming AppDimensions, Notices, Weekend, DevotionCalender, Events, StaffCover, AboutChengelo are imported here

// Utility Widget for the menu items (optional, but cleaner)
class QuickActionRow extends StatelessWidget {
  final String iconAsset;
  final String label;
  final Widget destination;

  const QuickActionRow({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    // You'll need to define AppDimensions.exsized2 if it's not available
    final double iconSize =
        33.0; // Use a fixed size or a calculated one if AppDimensions isn't accessible
    const double spacing = 30.0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination),
        );
      },
      child: Column(
        // Use Column to hold the Row and the Divider
        children: [
          SizedBox(height: 10), // Small vertical spacing above the row
          Row(
            children: [
              Image.asset(iconAsset, height: iconSize, width: iconSize),
              const SizedBox(width: spacing),
              Text(label, style: Theme.of(context).textTheme.labelMedium),
            ],
          ),
          SizedBox(height: 10), // Small vertical spacing below the row
          // Assuming DividerWidget is a custom thin line
          const DividerWidget(),
        ],
      ),
    );
  }
}
