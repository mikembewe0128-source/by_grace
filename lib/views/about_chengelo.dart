import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/data/app_dimensions.dart';
import 'package:url_launcher/url_launcher.dart'; // <-- 1. Import url_launcher

// Assume these imports exist and are correct
// import 'package:grace_by/data/app_colors.dart';
// import 'package:grace_by/data/app_dimensions.dart';
class AboutChengelo extends StatefulWidget {
  const AboutChengelo({super.key});

  @override
  State<AboutChengelo> createState() => _AboutChengeloState();
}

class _AboutChengeloState extends State<AboutChengelo> {
  // ==========================================================
  // 1. URL Constants
  // ==========================================================

  // URL for the main website (Opens in a browser)
  static const String SCHOOL_WEBSITE_URL = 'https://www.chengeloschool.org';

  // URL for the iCalendar feed (Attempts to open in a calendar app)
  static const String SCHOOL_CALENDAR_URL =
      'https://calendar.google.com/calendar/ical/admin%40chengeloschool.org/private-665b5078be27b752d6949a828d4496af/basic.ics';

  // ==========================================================
  // 2. Launch Functions with Improved Error Logging
  // ==========================================================

  // Function to launch the main website
  Future<void> _launchWebsiteUrl() async {
    final Uri url = Uri.parse(SCHOOL_WEBSITE_URL);

    try {
      if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
        // Fallback or explicit failure reporting
        _showLaunchError(SCHOOL_WEBSITE_URL, 'The browser failed to open.');
      }
    } catch (e) {
      _showLaunchError(SCHOOL_WEBSITE_URL, 'An unexpected error occurred: $e');
    }
  }

  // Function to launch the calendar feed
  Future<void> _launchCalendarUrl() async {
    final Uri url = Uri.parse(SCHOOL_CALENDAR_URL);

    try {
      // 1. Attempt to open in a native calendar app (externalApplication)
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // 2. If native app fails, fall back to opening in a web browser
        if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
          // 3. If both fail, show error
          _showLaunchError(
            SCHOOL_CALENDAR_URL,
            'Failed to launch in both calendar app and browser.',
          );
        }
      }
    } catch (e) {
      _showLaunchError(SCHOOL_CALENDAR_URL, 'An unexpected error occurred: $e');
    }
  }

  // ==========================================================
  // 3. Error Reporting Method (using SnackBar)
  // ==========================================================

  void _showLaunchError(String url, String message) {
    // Print to console for debugging
    print('LAUNCH ERROR for $url: $message');

    // Display a user-friendly error message using a SnackBar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error: Could not open the link. $message'),
        backgroundColor: Colors.red,
      ),
    );
  }

  Widget _buildLinkRow(
    BuildContext context,
    String title,
    VoidCallback onTapHandler,
  ) {
    return GestureDetector(
      onTap: onTapHandler,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize:
              MainAxisSize.min, // Ensures the Row only takes up space needed
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.exblue, // Style it like a link
                decoration: TextDecoration.underline,
              ),
            ),
            const SizedBox(width: 8.0), // Space between text and icon
            // Arrow Icon
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.exblue,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.exbackground,
      body: CustomScrollView(
        slivers: [
          // 1. SliverAppBar (Correct)
          SliverAppBar.medium(
            backgroundColor: AppColors.exblue,
            foregroundColor: Colors.white,
            title: const Text('chengelo'),
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

          // 2. Main Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Top Spacer
                SizedBox(height: AppDimensions.exsized),

                // Calendar Title/Subtitle Block (Updated to use helper)
                Column(
                  children: [
                    // Website Link
                    _buildLinkRow(
                      context,
                      'Visit Our Website',
                      _launchWebsiteUrl, // <-- Linked to the website function
                    ),

                    const SizedBox(height: 10), // Spacing between links
                    // Calendar Link
                    _buildLinkRow(
                      context,
                      'School Calendar',
                      _launchCalendarUrl, // <-- Linked to the calendar function
                    ),
                  ],
                ),

                // Use a regular SizedBox for spacing here, NOT SliverToBoxAdapter
                const SizedBox(height: 25),

                // Image
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/about.jpg'),
                  ),
                ),

                // Spacer
                SizedBox(height: AppDimensions.exsized),

                // Content Area (Title and all Paragraphs)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.exsized,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Title
                      Text(
                        'All About us',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(height: AppDimensions.expadding), // Smaller gap
                      // Paragraph 1
                      Text(
                        textAlign: TextAlign.justify,
                        "Chengelo School is a coeducational Christian Boarding School situated near Mkushi in the Central Province of Zambia.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      SizedBox(
                        height: AppDimensions.exsized,
                      ), // Paragraph separator
                      // Paragraph 2
                      Text(
                        textAlign: TextAlign.justify,
                        "We cater for the educational needs of Primary, Secondary and Sixth Form students in a secure and caring environment. Overlooking Chengelo is a hill where a large wooden cross has been placed which serves as a constant reminder of the central place that the Lord Jesus occupies in the school. We believe that without a personal knowledge of God the physical, mental and social development of a child is incomplete. Our school motto 'As a witness to The Light' summarises our aspirations for the young people who attend the school and go on to further education and the world of work.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      SizedBox(height: AppDimensions.exsized),

                      // Paragraph 3
                      Text(
                        textAlign: TextAlign.justify,
                        "Chengelo offers a first class learning environment where pupils are prepared for the University of Cambridge International GCSE and A-Level exams. Fifteen kilometres away is the Ndubaluba Outdoor Centre where our students regularly go on expeditions to face challenges and learn lessons about leadership that cannot be taught in the classroom setting. Our campus has excellent sporting facilities including several soccer fields, a rugby pitch, a 400m running track, netball and basketball courts and a swimming pool.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      SizedBox(height: AppDimensions.exsized),

                      // Paragraph 4
                      Text(
                        textAlign: TextAlign.justify,
                        "Chengelo caters for students from 5 to 18 years or older. Whilst the school takes pupils from a variety of backgrounds and faiths, special priority is given to children whose parents are farmers, in full-time Christian service or who live in rural areas.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      SizedBox(height: AppDimensions.exsized),

                      // Paragraph 5
                      Text(
                        textAlign: TextAlign.justify,
                        "Chengelo School was founded in September 1988 by the Mkushi Christian Fellowship. Since then God has blessed Chengelo and we have grown into a thriving school of about 370 students, with over 70 staff and many supporters drawn from Zambia and all over the world.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),
                      SizedBox(height: AppDimensions.exsized),

                      // Paragraph 6
                      Text(
                        textAlign: TextAlign.justify,
                        "We believe that many of our pupils will become the future leaders of Zambian business and professional life as well as the Church. We trust and pray that God's Kingdom will increase in this nation as a result.",
                        style: const TextStyle(fontSize: 14, height: 1.5),
                      ),

                      // Bottom Spacer
                      SizedBox(height: AppDimensions.exsized),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. Footer Content
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

          // 4. Final Spacer
          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }
}
