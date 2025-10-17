import 'package:flutter/material.dart';
import 'package:grace_by/Api/firestore_service.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/notices.dart';
import 'package:grace_by/widgets/notice_card.dart';
import 'package:grace_by/widgets/shimmer_placeholder.dart';
import 'package:provider/provider.dart';

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the service provider without listening for changes on the main widget
    final service = Provider.of<FirestoreService>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.exwwhite,
      body: CustomScrollView(
        slivers: [
          // --- 1. App Bar ---
          SliverAppBar.medium(
            backgroundColor: AppColors.exblue,
            foregroundColor: Colors.white,
            title: const Text('Notices'),
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

          // --- 2. Header ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0, left: 14, bottom: 1.0),
              child: Text(
                "Recent Notices",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),

          // --- 3. Stream Builder for Notices ---
          StreamBuilder<List<Notice>>(
            stream: service.getNoticesWithCache(),
            builder: (context, snapshot) {
              // --- Loading State with Shimmer ---
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      children: List.generate(
                        3,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: const ShimmerPlaceholder(
                            height: 110,
                            width: double.infinity,
                            borderRadius: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              // --- Error State ---
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error loading notices: ${snapshot.error}'),
                  ),
                );
              }

              final notices = snapshot.data ?? [];

              // --- Empty State ---
              if (notices.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40.0),
                    child: Center(child: Text('No notices available.')),
                  ),
                );
              }

              // --- Success/Data State (With Fade-in Animation) ---
              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final notice = notices[index];
                  final isLast = index == notices.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(
                      top: index == 0 ? 10 : 0,
                      bottom: isLast ? 20 : 0,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 600),
                      switchInCurve: Curves.easeInOut,
                      child: NoticeCard(
                        key: ValueKey(notice.id),
                        notice: notice,
                      ),
                    ),
                  );
                }, childCount: notices.length),
              );
            },
          ),

          // Optional bottom spacing
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }
}
