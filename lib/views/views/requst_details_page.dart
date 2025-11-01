// ----------------------------------------------------------------------
// FILE: lib/views/views/request_details_page.dart (Final Version)
// ----------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/models/student.dart';
import 'package:intl/intl.dart';
import 'package:grace_by/models/pickup_request.dart';
import 'package:grace_by/data/app_colors.dart';

class RequestDetailsPage extends StatefulWidget {
  final PickupRequest? request;

  const RequestDetailsPage({super.key, this.request});

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  final timeFormatter = DateFormat('h:mm a');

  Student? _studentDetails;
  bool _isLoadingStudent = true;

  @override
  void initState() {
    super.initState();
    _fetchStudentDetails();
  }

  Future<void> _fetchStudentDetails() async {
    if (widget.request == null || widget.request!.studentId.isEmpty) {
      setState(() => _isLoadingStudent = false);
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('students')
          .doc(widget.request!.studentId)
          .withConverter<Student>(
            fromFirestore: Student.fromFirestore,
            toFirestore: (student, _) => student.toFirestore(),
          )
          .get();

      setState(() {
        _studentDetails = docSnapshot.data();
        _isLoadingStudent = false;
      });
    } catch (e) {
      debugPrint('Error fetching student details: $e');
      setState(() {
        _studentDetails = null;
        _isLoadingStudent = false;
      });
    }
  }

  // Standard row builder for clean detail display
  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.request == null) {
      return Scaffold(
        backgroundColor: AppColors.exwwhite,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Text(
              'No request selected. Please open this page from a specific request item.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: AppColors.secondaryText),
            ),
          ),
        ),
      );
    }

    final request = widget.request!;
    final bool isCompleted =
        request.status.contains('Picked') || request.status.contains('Dropped');

    // Date and Time formatting
    final dateFormatter = DateFormat('MMM d, yyyy');
    final String formattedDate = dateFormatter.format(request.requestTime);
    final String formattedTime = timeFormatter.format(request.requestTime);

    final Color baseTypeColor = request.type == 'Pickup'
        ? Colors.red.shade700
        : AppColors.successGreen;

    // ⭐️ FIXED: Assign the final color ⭐️
    // If completed, use Green. Otherwise, use the base type color.
    final Color finalIconColor = isCompleted
        ? AppColors.successGreen
        : baseTypeColor;
    // Class Name, Parent Name, and Contact display logic based on fetch state
    String classNameDisplay;
    String parentNameDisplay;
    String parentContactDisplay;

    if (_isLoadingStudent) {
      classNameDisplay = 'Loading...';
      parentNameDisplay = 'Loading...';
      parentContactDisplay = 'Loading...';
    } else if (_studentDetails == null) {
      classNameDisplay = 'ID: ${request.studentId} (Data Unavailable)';
      parentNameDisplay = 'Unavailable';
      parentContactDisplay = 'Unavailable';
    } else {
      classNameDisplay = _studentDetails!.className;
      parentNameDisplay = _studentDetails!.parentName.isNotEmpty
          ? _studentDetails!.parentName
          : 'N/A';
      parentContactDisplay = _studentDetails!.parentContact.isNotEmpty
          ? _studentDetails!.parentContact
          : 'N/A';
    }

    return Scaffold(
      backgroundColor: AppColors.exwwhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            backgroundColor: AppColors.exblue,
            foregroundColor: Colors.white,
            title: Text('${request.type} Details'),
            centerTitle: true,
            floating: true,
            snap: true,
            pinned: true,
            surfaceTintColor: Colors.transparent,
            elevation: 6.0,
            scrolledUnderElevation: 6.0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- Header Card ---
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // --- UPDATED ICON ---
                          Icon(
                            Icons
                                .school_sharp, // Changed to a student/person icon
                            size: 60,
                            color: finalIconColor,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            request.studentName,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          // Display the current status clearly
                          Chip(
                            label: Text('Current Status: ${request.status}'),
                            backgroundColor: isCompleted
                                ? AppColors.successGreen.withOpacity(0.2)
                                : AppColors.warningAmber.withOpacity(0.8),
                            labelStyle: TextStyle(
                              color: isCompleted
                                  ? Colors.green.shade800
                                  : AppColors.primaryText,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Detail Rows (Minimal and Essential) ---
                  _buildDetailRow(
                    'Student Class',
                    classNameDisplay,
                    Icons.school,
                    AppColors.exblue,
                  ),
                  const Divider(),

                  // ⭐️ Parent Name Detail Row ⭐️
                  _buildDetailRow(
                    'Parent/Guardian Name',
                    parentNameDisplay,
                    Icons.person_2,
                    AppColors.exblue,
                  ),
                  const Divider(),

                  // ⭐️ Parent Contact Detail Row ⭐️
                  _buildDetailRow(
                    'Parent Contact',
                    parentContactDisplay,
                    Icons.phone,
                    AppColors.exblue,
                  ),
                  const Divider(),

                  // Remaining request details
                  _buildDetailRow(
                    'Request Type',
                    request.type,
                    request.type == 'Pickup'
                        ? Icons.departure_board
                        : Icons.directions_car_filled,
                    finalIconColor,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Scheduled Date',
                    formattedDate,
                    Icons.calendar_month,
                    AppColors.exblue,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Scheduled Time',
                    formattedTime,
                    Icons.access_time_filled,
                    AppColors.exblue,
                  ),
                  const Divider(),
                  _buildDetailRow(
                    'Reason for Request',
                    request.reason,
                    Icons.notes,
                    AppColors.exblue,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
