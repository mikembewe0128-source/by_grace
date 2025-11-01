// ----------------------------------------------------------------------
// FILE: lib/views/views/pickup_dropoff.dart
// ----------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/views/views/requst_details_page.dart';
import 'package:intl/intl.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/pickup_request.dart';

// Formatters for time
final timeFormatter = DateFormat('h:mm a');

class PickupDropoff extends StatelessWidget {
  const PickupDropoff({super.key});

  // Query now fetches ALL requests, ordered by request time.
  Query<PickupRequest> _getAllRequestsQuery() {
    return FirebaseFirestore.instance
        .collection('pickup_requests')
        .withConverter<PickupRequest>(
          fromFirestore: PickupRequest.fromFirestore,
          toFirestore: (request, _) => request.toFirestore(),
        )
        // ⭐️ FIXED: orderBy is now descending: true ⭐️
        .orderBy('request_time', descending: true);
  }

  // Helper to build a visually distinct card border for pending items
  ShapeBorder _getCardShape(bool isPending) {
    if (isPending) {
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.warningAmber, width: 2.0),
      );
    }
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
  }

  @override
  Widget build(BuildContext context) {
    final allRequestsQuery = _getAllRequestsQuery();

    return Scaffold(
      backgroundColor: AppColors.exwwhite,
      body: CustomScrollView(
        slivers: [
          // --- App Bar ---
          SliverAppBar.medium(
            backgroundColor: AppColors.exblue,
            foregroundColor: Colors.white,
            title: const Text('Pickup & Drop-off'),
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

          // --- UI Spacing and Descriptive Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'History of Requests:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'All scheduled movements are listed below.',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const Divider(height: 20),
                ],
              ),
            ),
          ),

          // --- List of ALL Requests (StreamBuilder) ---
          StreamBuilder<QuerySnapshot<PickupRequest>>(
            stream: allRequestsQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        'Error loading schedule: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.errorRed),
                      ),
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: CircularProgressIndicator(color: AppColors.exblue),
                    ),
                  ),
                );
              }

              final requests = snapshot.data!.docs
                  .map((doc) => doc.data())
                  .toList();

              if (requests.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text(
                        "No active pickup or drop-off requests found.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.secondaryText),
                      ),
                    ),
                  ),
                );
              }

              // --- Display the List ---
              return SliverList.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  final request = requests[index];
                  // Date format for the list item subtitle
                  final dateFormatterWithDay = DateFormat('MMM d, h:mm a');
                  final String formattedDateTime = dateFormatterWithDay.format(
                    request.requestTime,
                  );

                  final bool isPending = request.status == 'Pending';
                  final bool isCompleted =
                      request.status.contains('Picked') ||
                      request.status.contains('Dropped');

                  Color statusColor;
                  if (isCompleted) {
                    statusColor = AppColors.successGreen;
                  } else if (isPending) {
                    statusColor = AppColors.warningAmber;
                  } else {
                    statusColor = AppColors.exblue;
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 6.0,
                    ),
                    child: Card(
                      elevation: isPending ? 6 : 3,
                      shape: _getCardShape(isPending),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Icon(
                          request.type == 'Pickup'
                              ? Icons.directions_walk
                              : Icons.directions_car,
                          color: statusColor,
                          size: 32,
                        ),
                        title: Text(
                          request.studentName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.primaryText,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              // Main detail: Date, Time
                              '${request.type} @ $formattedDateTime',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isPending
                                    ? AppColors.warningAmber
                                    : AppColors.exblue,
                              ),
                            ),
                            Text(
                              'Reason: ${request.reason}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        // ⭐️ RESTORED STATUS CHIP ⭐️
                        trailing: Chip(
                          label: Text(
                            request.status,
                            style: TextStyle(
                              color: isPending
                                  ? AppColors.primaryText
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          backgroundColor: isPending
                              ? AppColors.warningAmber.withOpacity(0.8)
                              : statusColor,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  RequestDetailsPage(request: request),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }
}
