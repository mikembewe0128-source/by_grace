import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grace_by/models/events.dart';
import 'package:grace_by/widgets/events_card.dart';
import 'package:grace_by/widgets/shimmer_placeholder.dart';
import 'package:grace_by/data/app_colors.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 🎯 Query FIX: Changed to descending: true for newest events first
    final query = FirebaseFirestore.instance
        .collection('events')
        .orderBy('date', descending: true)
        .withConverter<Event>(
          fromFirestore: (snap, _) => Event.fromMap(snap.data()!, snap.id),
          toFirestore: (event, _) => event.toMap(),
        );

    return Scaffold(
      backgroundColor: AppColors.exwwhite,
      body: CustomScrollView(
        slivers: [
          // 🏷️ App Bar
          SliverAppBar.medium(
            backgroundColor: AppColors.exblue,
            foregroundColor: Colors.white,
            title: const Text('Events'),
            centerTitle: true,
            floating: true,
            snap: true,
            pinned: false,
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
          // 💬 Small subtitle (now includes bottom padding)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                10,
                16,
                10,
              ), // Increased bottom padding slightly
              child: Text(
                "Stay updated with upcoming activities",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[700], // Give subtitle a subtle color
                ),
              ),
            ),
          ),

          // 🔄 Firestore Stream Builder
          StreamBuilder<QuerySnapshot<Event>>(
            stream: query.snapshots(),
            builder: (context, snapshot) {
              // 🟡 Loading shimmer
              if (snapshot.connectionState == ConnectionState.waiting) {
                // A better approach for Sliver loading is SliverList
                return SliverList.builder(
                  itemCount: 3,
                  itemBuilder: (context, index) => const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 8.0,
                    ),
                    child: ShimmerPlaceholder(
                      height: 280,
                      width: double.infinity,
                      borderRadius: 18,
                    ),
                  ),
                );
              }

              // 🔴 Error handling
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  // Use this to center the error message
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Error loading events: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }

              // 🟢 Data available
              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('No upcoming events.'),
                    ),
                  ),
                );
              }

              // 🧱 Build dynamic scrollable list
              return SliverList.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final event = docs[index].data();

                  // NOTE: The EventCard widget already has vertical margin (10)
                  // from the code you provided in the first prompt.
                  // We'll trust that padding is handled inside EventCard for simplicity.
                  return EventCard(event: event);
                },
              );
            },
          ),

          // Added a small, final bottom spacer
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
