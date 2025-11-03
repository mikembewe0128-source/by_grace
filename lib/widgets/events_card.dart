
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

  void openImageFullScreen(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: Hero(
                tag: url,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.45;

    final hasTimes =
        widget.event.startTime != null || widget.event.endTime != null;
    final hasContact =
        (widget.event.email?.isNotEmpty ?? false) ||
        (widget.event.contact?.isNotEmpty ?? false);

    return GestureDetector(
      onTap: toggleExpand,
      child: Stack(
        children: [
          Container(
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
                // Event Image & Floating Title
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
                    // Floating Title
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Event Info (Date, Time, Location, Description)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📅 Event Date (No Icon here, but uses full format)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            size: 18,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat(
                              'EEEE, MMMM d, yyyy',
                            ).format(widget.event.date),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ⏰ Start and End Time ICON
                      if (hasTimes)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 18,
                                color: Colors.teal,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                [
                                  if (widget.event.startTime != null)
                                    "Starts: ${DateFormat('h:mm a').format(widget.event.startTime!)}",
                                  if (widget.event.endTime != null)
                                    "Ends: ${DateFormat('h:mm a').format(widget.event.endTime!)}",
                                ].join("  |  "),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // 📍 Location ICON
                      if (widget.event.location?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.event.location!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ☎️/📧 Contact Info
                      if (hasContact)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (widget.event.email?.isNotEmpty ?? false)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email,
                                      size: 18,
                                      color: Colors.orangeAccent,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      "Email: ${widget.event.email}",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              if (widget.event.contact?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Contact: ${widget.event.contact}",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                      // Description (Animated Expansion)
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

                      const SizedBox(height: 10),

                      // Event Outcome Section (Outcome Text and Image Gallery)
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
                              if (widget.event.outcome?.isNotEmpty ?? false)
                                Text(
                                  widget.event.outcome!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                ),
                              // Image Gallery
                              if (widget.event.outcomeImages.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 10.0),
                                  child: SizedBox(
                                    height: 220,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          widget.event.outcomeImages.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 12),
                                      itemBuilder: (context, index) {
                                        final img =
                                            widget.event.outcomeImages[index];
                                        return GestureDetector(
                                          onTap: () => openImageFullScreen(img),
                                          child: Hero(
                                            tag: img,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(14),
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
                                                    const Icon(
                                                      Icons.broken_image,
                                                    ),
                                              ),
                                            ),
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

          // Floating Status Badge (Upcoming/Completed)
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: widget.event.date.isAfter(DateTime.now())
                    ? Colors.green
                    : Colors.grey,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                widget.event.date.isAfter(DateTime.now())
                    ? "Upcoming"
                    : "Completed",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
