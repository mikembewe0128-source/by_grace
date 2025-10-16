import 'package:flutter/material.dart';
import 'package:grace_by/models/staff_on_duty.dart';

class StaffOnDutyCard extends StatefulWidget {
  final StaffOnDuty staff;

  const StaffOnDutyCard({super.key, required this.staff});

  @override
  State<StaffOnDutyCard> createState() => _StaffOnDutyCardState();
}

class _StaffOnDutyCardState extends State<StaffOnDutyCard> {
  Widget? _cachedCardWidget;
  int? _lastStaffHashCode;

  @override
  void didUpdateWidget(covariant StaffOnDutyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear cache only if the staff object changed
    if (widget.staff != oldWidget.staff) {
      _cachedCardWidget = null;
      _lastStaffHashCode = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return cached widget if staff hasn't changed
    if (_cachedCardWidget != null &&
        widget.staff.hashCode == _lastStaffHashCode) {
      return _cachedCardWidget!;
    }

    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    final double baseWidth = orientation == Orientation.portrait ? 400 : 600;
    final double scale = (size.width / baseWidth).clamp(0.9, 2.5);

    final double titleFontSize = 20 * scale;
    final double subtitleFontSize = 14 * scale;
    final double iconSize = 18 * scale;

    // Build the card
    final cardWidget = RepaintBoundary(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color(0xFFF9FAFB),
            child: Padding(
              padding: EdgeInsets.all(16 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8 * scale),

                  // Name
                  Text(
                    widget.staff.name,
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 12 * scale),

                  // Date Range
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: iconSize,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          'DATES: ${widget.staff.dateRange}',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.blueGrey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),

                  // Contact
                  Row(
                    children: [
                      Icon(Icons.phone, size: iconSize, color: Colors.blueGrey),
                      SizedBox(width: 8 * scale),
                      Expanded(
                        child: Text(
                          'CONTACT: ${widget.staff.contact}',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: Colors.blueGrey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    // Cache the built widget and hash code
    _cachedCardWidget = cardWidget;
    _lastStaffHashCode = widget.staff.hashCode;

    return cardWidget;
  }
}
