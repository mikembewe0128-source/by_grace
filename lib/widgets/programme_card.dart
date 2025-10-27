import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for HapticFeedback
import 'package:grace_by/models/programmes.dart';
import 'package:intl/intl.dart';

class ProgrammeCard extends StatelessWidget {
  final Programme programme;
  // New: Pass the selected day from the parent widget for correct context
  final DateTime selectedDay;

  const ProgrammeCard({
    Key? key,
    required this.programme,
    required this.selectedDay, // Required selectedDay
  }) : super(key: key);

  // Helper method for clearer metadata display
  Widget _buildMetadataRow(BuildContext context, IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Time Formatting
    final start = DateFormat.jm().format(programme.start);
    final end = programme.end != null
        ? DateFormat.jm().format(programme.end!)
        : '';

    // 2. TRUE 'TODAY' CHECK (The user's requirement)
    // Checks if the programme overlaps with the CURRENT REAL-WORLD DATE
    final now = DateTime.now();
    final programmeEndActual = programme.end ?? programme.start;
    final isCurrentlyActive =
        DateUtils.isSameDay(programme.start, now) ||
        (programme.start.isBefore(now) && programmeEndActual.isAfter(now));

    // 3. Location Tag Text (to be used in the trailing column)
    final locationText = programme.location?.split(',').first.trim() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          // Slightly reduced opacity for a cleaner look
          gradient: LinearGradient(
            colors: [Colors.white, Colors.indigo.withOpacity(0.03)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.06), // Lighter shadow
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              HapticFeedback.lightImpact(); // Add Haptic Feedback
              _showProgrammeDetails(context, programme);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              leading: _buildLeadingImage(),
              title: Text(
                programme.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Improved Description Check
                  Text(
                    programme.description?.isNotEmpty == true
                        ? programme.description!
                        : 'No details available.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  // Use 'isCurrentlyActive' for the Today tag
                  if (isCurrentlyActive)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3, // Slightly increased vertical padding
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50, // Use a warm color for "Now"
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade100),
                      ),
                      child: Text(
                        'Happening Now', // Changed text for better clarity
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Time Tag (Most Prominent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$start${end.isNotEmpty ? ' - $end' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Location Tag (Secondary Info)
                  if (locationText.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          locationText,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // (The _buildLeadingImage method remains mostly the same, no changes needed)
  Widget _buildLeadingImage() {
    // ... (same as original)
    if (programme.imageUrl == null) {
      return const Icon(Icons.school_outlined, size: 40, color: Colors.indigo);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: CachedNetworkImage(
        imageUrl: programme.imageUrl!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (context, url, error) =>
            const Icon(Icons.broken_image, color: Colors.grey),
      ),
    );
  }

  void _showProgrammeDetails(BuildContext context, Programme p) {
    // Determine the full date range for display
    final dateRange = p.end != null
        ? '${DateFormat.yMMMMd().add_jm().format(p.start)} - ${DateFormat.jm().format(p.end!)}'
        : DateFormat.yMMMMd().add_jm().format(p.start);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.5, // Start height at 50%
        minChildSize: 0.25,
        maxChildSize: 0.9,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Image/Icon Header
              // ... (previous code)
              if (p.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: p.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity, // <--- ADD THIS LINE
                    // height: 200, // Optional: You can also set a fixed height or use aspectRatio
                  ),
                ),
              // ... (rest of the code)
              if (p.imageUrl == null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Icon(
                      Icons.class_outlined,
                      size: 60,
                      color: Colors.indigo.shade600,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Title
              Text(
                p.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 24),

              // Structured Metadata
              _buildMetadataRow(context, Icons.schedule, dateRange),
              _buildMetadataRow(
                context,
                Icons.place_outlined,
                p.location ?? 'Unspecified Location',
              ),
              _buildMetadataRow(
                context,
                Icons.notes,
                p.description?.isNotEmpty == true ? 'Details' : 'No Details',
              ),

              const Divider(height: 30),

              // Description Body
              Text(
                p.description?.isNotEmpty == true
                    ? p.description!
                    : 'No further details have been provided for this programme.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
