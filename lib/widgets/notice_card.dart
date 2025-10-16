import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:grace_by/models/notices.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NoticeCard extends StatelessWidget {
  final Notice notice;
  const NoticeCard({super.key, required this.notice});

  // --- MODIFIED LOGO WIDGET (Reduced Size) ---
  Widget _centeredLogo() => Padding(
    // Keep some top and bottom padding for vertical spacing
    padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
    child: Center(
      // Use a fixed-size box for a neat, controlled logo size (80x80)
      child: SizedBox(
        width: 80.0,
        height: 80.0,
        child: Padding(
          // Removed heavy internal padding
          padding: const EdgeInsets.all(0.0),
          child: Image.asset('assets/icon.png', fit: BoxFit.contain),
        ),
      ),
    ),
  );

  // Widget for the 'chengelo' text block (No changes needed here)
  Widget _chengeloBranding(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 10.0),
    child: Center(
      child: Column(
        children: [
          Text(
            'chengelo',
            textAlign: TextAlign.center,
            style:
                Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ) ??
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  );

  @override
  Widget build(BuildContext context) {
    // Determine if the image is valid to control conditional spacing
    final bool hasImage = notice.imageUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _centeredLogo(),
          const Divider(height: 1, color: Colors.black12),
          const SizedBox(height: 10),

          _row("TO:", notice.to),
          _row("FROM:", notice.sender),
          _row("SUBJECT:", notice.title),
          _row("DATE:", DateFormat('d/MM/yyyy').format(notice.date)),
          const Divider(height: 18),

          Text(
            notice.content,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),

          // --- MODIFIED IMAGE BLOCK with Conditional Spacing ---
          if (hasImage) ...[
            // Space BEFORE the image (only present if image is present)
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: notice.imageUrl,
                // Ensures image covers full inner width
                width: double.infinity,
                // Ensures image is cropped to fill the fixed height
                fit: BoxFit.cover,
                // Set fixed height for consistent banner size
                height: 160,

                placeholder: (context, url) => const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator()),
                ),

                // FIX: Shows nothing (zero size) on image load failure
                errorWidget: (context, url, error) => const SizedBox.shrink(),
              ),
            ),
            // Space AFTER the image (only present if image is present)
            const SizedBox(height: 16),
          ] else
            // If NO image, add a SMALLER space to keep "Kind Regards" close to content.
            // Adjust '8.0' to your preferred minimal gap if needed.
            const SizedBox(height: 8.0),

          // 5. Kind Regards Text (Left Aligned)
          const Text(
            "Kind Regards",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          // Insert the 'chengelo' text block here
          _chengeloBranding(context),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    ),
  );
}
