// home_page.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/Api/firestore_service.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/announcements.dart';
import 'package:grace_by/models/devtions.dart';
import 'package:grace_by/models/staff_on_duty.dart';
import 'package:grace_by/widgets/quick_actions_card.dart';
import 'package:grace_by/views/home/devotion_card.dart';
import 'package:grace_by/views/home/staff_on_duty.dart';
import 'package:grace_by/widgets/shimmer_placeholder.dart';
import 'package:intl/intl.dart';
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
            collapsedHeight: 80,
            pinned: true,
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

          // 🔄 Devotion Stream
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

              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeOut,
                    child: DevotionCard(
                      key: ValueKey(devotion.date.toIso8601String()),
                      devotion: devotion,
                    ),
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

          // 🔄 Staff Stream
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
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 600),
                    switchInCurve: Curves.easeInOut,
                    child: StaffOnDutyCard(
                      key: ValueKey(staff.hashCode),
                      staff: staff,
                    ),
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

          // 🔄 Announcements Stream
          SliverToBoxAdapter(
            child: StreamBuilder<List<Announcement>>(
              stream: firestoreService.getRecentAnnouncements(5),
              builder: (context, snapshot) {
                final screenWidth = MediaQuery.of(context).size.width;
                final cardHeight = screenWidth * 0.50;
                final cardWidth = screenWidth * 0.70;

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: cardHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) => Container(
                        width: cardWidth,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 12 : 6,
                          right: 6,
                        ),
                        child: const ShimmerPlaceholder(
                          height: double.infinity,
                          width: double.infinity,
                          borderRadius: 10,
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return const SizedBox.shrink();
                }

                final announcements = snapshot.data!;
                String formatTimestamp(DateTime dateTime) {
                  return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
                }

                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeInOut,
                  child: SizedBox(
                    key: ValueKey(announcements.hashCode),
                    height: cardHeight,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = announcements[index];

                        return Container(
                          width: cardWidth,
                          margin: EdgeInsets.only(
                            left: index == 0 ? 12 : 6,
                            right: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.exblue,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 8,
                                color: Colors.black26,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Background
                              if (announcement.imageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: announcement.imageUrl,
                                    width: cardWidth,
                                    height: cardHeight,
                                    fit: BoxFit.cover,
                                    fadeInDuration: const Duration(
                                      milliseconds: 500,
                                    ),
                                    fadeOutDuration: const Duration(
                                      milliseconds: 200,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                          'assets/images/ethos.jpg',
                                          fit: BoxFit.cover,
                                        ),
                                    placeholder: (context, url) =>
                                        const ShimmerPlaceholder(
                                          height: double.infinity,
                                          width: double.infinity,
                                          borderRadius: 10,
                                        ),
                                  ),
                                )
                              else
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.exblue,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),

                              // Overlay
                              Container(
                                decoration: BoxDecoration(
                                  color: announcement.imageUrl.isNotEmpty
                                      ? Colors.black.withOpacity(0.4)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),

                              // Centered content
                              Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        announcement.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (announcement.content.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                          ),
                                          child: Text(
                                            announcement.content,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),

                              // Timestamp
                              Positioned(
                                top: 12.0,
                                left: 12.0,
                                child: Text(
                                  formatTimestamp(announcement.date),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                              // Sender
                              if (announcement.sender != null &&
                                  announcement.sender.isNotEmpty)
                                Positioned(
                                  bottom: 12.0,
                                  left: 12.0,
                                  child: Text(
                                    'From: ${announcement.sender}',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
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
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
              child: QuickActionsCard(),
            ),
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
