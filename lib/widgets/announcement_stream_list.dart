import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:grace_by/Api/firestore_service.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/models/announcements.dart';
import 'package:grace_by/widgets/shimmer_placeholder.dart';
import 'package:intl/intl.dart';

class AnnouncementStreamList extends StatelessWidget {
  const AnnouncementStreamList({super.key});

  // Helper function for date formatting
  String _formatTimestamp(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy h:mm a').format(dateTime);
  }

  // Extracted widget to build a single announcement card
  Widget _buildAnnouncementCard(
    BuildContext context,
    Announcement announcement,
    int index,
    double cardWidth,
    double cardHeight,
  ) {
    // --- Card Structure ---
    final card = Container(
      width: cardWidth,
      margin: EdgeInsets.only(left: index == 0 ? 12 : 6, right: 6),
      decoration: BoxDecoration(
        color: AppColors.exblue,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(blurRadius: 8, color: Colors.black26, offset: Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          if (announcement.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: announcement.imageUrl,
                width: cardWidth,
                height: cardHeight,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 500),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/images/ethos.jpg', fit: BoxFit.cover),
                placeholder: (context, url) => const ShimmerPlaceholder(
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
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        announcement.content,
                        style: const TextStyle(
                          color: Colors
                              .white, // Changed to white for better visibility over overlay
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
              _formatTimestamp(announcement.date),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Sender
          if (announcement.sender != null && announcement.sender!.isNotEmpty)
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

    // --- Animation Logic (Subtle Polish) ---
    return card
        .animate()
        .fadeIn(duration: 400.ms, delay: (100 * index).ms)
        .slideX(
          begin: 0.2 * (index % 2 == 0 ? 1 : -1),
          end: 0,
          curve: Curves.decelerate, // Snappy entry curve
        )
        .then()
        .animate(onPlay: (controller) => controller.forward(from: 0.0));
  }

  @override
  Widget build(BuildContext context) {
    final firestoreService = Provider.of<FirestoreService>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth * 0.50;
    final cardWidth = screenWidth * 0.70;

    return StreamBuilder<List<Announcement>>(
      stream: firestoreService.getRecentAnnouncements(5),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Shimmer loading state
          return SizedBox(
            height: cardHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                width: cardWidth,
                margin: EdgeInsets.only(left: index == 0 ? 12 : 6, right: 6),
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

        return SizedBox(
          height: cardHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return _buildAnnouncementCard(
                context,
                announcement,
                index,
                cardWidth,
                cardHeight,
              );
            },
          ),
        );
      },
    );
  }
}
