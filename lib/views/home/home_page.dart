import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grace_by/Api/firestore_service.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/devtions.dart';
import 'package:grace_by/models/staff_on_duty.dart';
import 'package:grace_by/widgets/announcement_stream_list.dart';
import 'package:grace_by/widgets/quick_actions_card.dart';
import 'package:grace_by/views/home/devotion_card.dart';
import 'package:grace_by/views/home/staff_on_duty.dart';
import 'package:grace_by/widgets/shimmer_placeholder.dart';

import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    final double expandedHeight = screenSize.width * 0.6 > 200
        ? screenSize.width * 0.6
        : 200;

    final StaffOnDuty defaultStaff = StaffOnDuty(
      name: "Not Scheduled",
      dateRange: "No Staff Data Available",
      contact: "N/A",
      role: '',
    );

    return Scaffold(
      backgroundColor: AppColors.exbackground,
      body: CustomScrollView(
        slivers: [
          // 1️⃣ Header
          SliverAppBar(
            backgroundColor: const Color(0xFF000428),
            collapsedHeight: 70,
            elevation: 6.0,
            scrolledUnderElevation: 6.0,
            surfaceTintColor: Colors.transparent,
            expandedHeight: expandedHeight,
            title: Text(
              'Chengelo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              background: DecoratedBox(
                decoration: const BoxDecoration(color: Color(0xFF000428)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: isLandscape ? 0.4 : 0.8,
                      heightFactor: isLandscape ? 0.6 : 0.8,
                      child: Image.asset(
                        'assets/iconnzz.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 2️⃣ Today's Devotion
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 12, bottom: 3.0),
              child: Text(
                "Today's Devotion",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),

          // 🔄 Devotion Stream (Polished Animation)
          StreamBuilder<Devotion?>(
            stream: firestoreService.getLatestDevotionWithFallback(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: ShimmerPlaceholder(
                      height: 160,
                      width: double.infinity,
                      borderRadius: 12,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }

              final Devotion? devotion = snapshot.data;
              if (devotion == null) {
                return const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No devotion found.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                );
              }

              // ✨ ANIMATION: Snappy slide down
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child:
                      DevotionCard(
                            key: ValueKey(devotion.date.toIso8601String()),
                            devotion: devotion,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .slideY(
                            begin: 0.2,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          )
                          .then()
                          .animate(
                            onPlay: (controller) =>
                                controller.forward(from: 0.0),
                          ),
                ),
              );
            },
          ),

          // 3️⃣ Staff On Duty
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 14, bottom: 3.0),
              child: Text(
                "Staff On Duty",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),

          // 🔄 Staff Stream (Clean 2D Animation)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8.0),
              child: StreamBuilder<StaffOnDuty?>(
                stream: firestoreService.getStaffOnDutyWithCache(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerPlaceholder(
                      height: 80,
                      width: double.infinity,
                      borderRadius: 10,
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error loading staff info: ${snapshot.error}",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final staff = snapshot.data ?? defaultStaff;
                  // ✨ ANIMATION: Simple, flat slide/fade
                  return StaffOnDutyCard(
                        key: ValueKey(staff.hashCode),
                        staff: staff,
                      )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(
                        begin: 0.15,
                        end: 0,
                        curve: Curves.easeOutCubic, // Snappy stop
                      )
                      .then()
                      .animate(
                        onPlay: (controller) => controller.forward(from: 0.0),
                      );
                },
              ),
            ),
          ),

          // 4️⃣ Announcements
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 14, bottom: 8.0),
              child: Text(
                "Recent Announcements",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),

          // 🔄 Announcements Stream (Now a single, dedicated widget!)
          const SliverToBoxAdapter(
            child: AnnouncementStreamList(), // <<< CLEANER CODE
          ),

          // 5️⃣ Quick Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 14, bottom: 1.0),
              child: Text(
                "menu",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child:
                const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 10.0,
                      ),
                      child: QuickActionsCard(),
                    )
                    // ✨ ANIMATION: Bounce scale
                    .animate()
                    .scale(
                      duration: 600.ms,
                      delay: 200.ms,
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.easeOutBack,
                    )
                    .fadeIn(duration: 400.ms),
          ),

          // 6️⃣ Footer
          SliverToBoxAdapter(
            child: Column(
              children: [
                Text(
                  'chengelo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const Text(
                  '"as a witness to the light"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CupertinoColors.systemYellow,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}
