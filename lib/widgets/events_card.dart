import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grace_by/models/events.dart';
import 'package:grace_by/widgets/shimmer_placeholder.dart';
import 'package:intl/intl.dart';

class EventCard extends StatefulWidget {
  final Event event;
  const EventCard({super.key, required this.event});

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isExpanded = false;

  void toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.45; // Main image height

    return GestureDetector(
      onTap: toggleExpand,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with title overlaid (blending)
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: widget.event.imageUrl,
                  height: cardHeight,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => ShimmerPlaceholder(
                    height: cardHeight,
                    width: double.infinity,
                    borderRadius: 0,
                  ),
                  errorWidget: (context, url, error) => const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
                // Title directly on image (no background)
                Positioned(
                  left: 16,
                  bottom: 16,
                  right: 16,
                  child: Text(
                    widget.event.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black54,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Event Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Date
                  Text(
                    DateFormat(
                      'EEEE, MMMM d, yyyy – h:mm a',
                    ).format(widget.event.date),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Event Description (tap-to-expand)
                  AnimatedCrossFade(
                    firstChild: Text(
                      widget.event.description,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    secondChild: Text(
                      widget.event.description,
                      style: const TextStyle(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                    crossFadeState: isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),

                  // Event Outcome
                  if ((widget.event.outcome?.isNotEmpty ?? false) ||
                      widget.event.outcomeImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 14.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Event Outcome',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Outcome Text
                          if (widget.event.outcome?.isNotEmpty ?? false)
                            Text(
                              widget.event.outcome!,
                              style: const TextStyle(fontSize: 14, height: 1.5),
                            ),

                          // Outcome Images (scrollable)
                          if (widget.event.outcomeImages.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: SizedBox(
                                height: 220,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: widget.event.outcomeImages.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final img =
                                        widget.event.outcomeImages[index];
                                    return ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: CachedNetworkImage(
                                        imageUrl: img,
                                        width: 220,
                                        height: 220,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            ShimmerPlaceholder(
                                              height: 220,
                                              width: 220,
                                              borderRadius: 14,
                                            ),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
