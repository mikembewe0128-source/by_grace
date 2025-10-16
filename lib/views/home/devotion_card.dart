import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:grace_by/models/devtions.dart';
import 'package:intl/intl.dart';

class DevotionCard extends StatelessWidget {
  final Devotion devotion;

  const DevotionCard({super.key, required this.devotion});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    final double screenWidth = screenSize.width;
    final double screenHeight = screenSize.height;
    final bool isLandscape = screenWidth > screenHeight;

    final double baseDimension = isLandscape ? screenHeight : screenWidth;
    final double titleFont = baseDimension * 0.07;
    final double scriptureFont = baseDimension * 0.045;
    final double messageFont = baseDimension * 0.04;

    final String formattedDate = DateFormat.yMMMd().format(devotion.date);

    // ✅ Cached network image with versioning
    final String versionedUrl =
        '${devotion.imageUrl.trim()}?v=${devotion.updatedAt?.millisecondsSinceEpoch ?? 0}';

    final double containerHeight = isLandscape
        ? screenHeight * 0.85
        : screenHeight * 0.45;
    const double maxContainerHeight = 550.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: maxContainerHeight,
            minHeight: containerHeight,
          ),
          height: containerHeight,
          margin: EdgeInsets.all(screenWidth * 0.025),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            image: devotion.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: CachedNetworkImageProvider(
                      versionedUrl,
                      cacheKey: versionedUrl,
                    ),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.5),
                      BlendMode.darken,
                    ),
                  )
                : const DecorationImage(
                    image: AssetImage('assets/hill.jpg'),
                    fit: BoxFit.cover,
                  ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                color: Colors.black26,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.06),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // Ensure content is pushed to the bottom if the column space allows
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Date
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: scriptureFont * 0.8,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),

                  // Title
                  Text(
                    devotion.title,
                    style: TextStyle(
                      fontSize: titleFont,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.008),

                  // Scripture
                  Text(
                    devotion.scripture,
                    style: TextStyle(
                      fontSize: scriptureFont,
                      fontStyle: FontStyle.italic,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Message
                  Text(
                    devotion.message,
                    style: TextStyle(
                      fontSize: messageFont,
                      color: Colors.white,
                    ),
                  ),

                  // ADDED: Spacer before the Author to separate it slightly
                  SizedBox(height: screenHeight * 0.01),

                  // ADDED: Author/Source Information (Subtle styling)
                  // ASSUMPTION: The Devotion model has a 'final String author;' field.
                  if (devotion.author.isNotEmpty)
                    Text(
                      'Shared by: ${devotion.author}',
                      textAlign: TextAlign.right, // Align to the bottom right
                      style: TextStyle(
                        fontSize: messageFont * 0.8, // Smaller font
                        color: Colors.white70, // Less prominent color
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
