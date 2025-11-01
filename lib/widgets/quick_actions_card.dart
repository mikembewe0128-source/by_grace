import 'package:flutter/material.dart';
import 'package:grace_by/views/views/pickup_dropoff.dart';
import 'package:grace_by/views/views/requst_details_page.dart';
import 'package:grace_by/widgets/quick_action_row.dart';
import 'package:grace_by/views/about_chengelo.dart';
import 'package:grace_by/views/events.dart';
import 'package:grace_by/views/notices.dart';
import 'package:grace_by/views/school_programme_page.dart';

class QuickActionsCard extends StatelessWidget {
  const QuickActionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              QuickActionRow(
                iconAsset: 'assets/message-board.png',
                label: 'Notices',
                destination: NoticesPage(),
              ),
              QuickActionRow(
                iconAsset: 'assets/family.png',
                label: 'Pickup & Dropoff',
                destination: PickupDropoff(),
              ),
              QuickActionRow(
                iconAsset: 'assets/school.png',
                label: 'School Calendar',
                destination: SchoolProgrammesPage(),
              ),
              QuickActionRow(
                iconAsset: 'assets/event.png',
                label: 'Events',
                destination: EventsPage(),
              ),

              QuickActionRow(
                iconAsset: 'assets/about.png',
                label: 'About Chengelo',
                destination: AboutChengelo(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
