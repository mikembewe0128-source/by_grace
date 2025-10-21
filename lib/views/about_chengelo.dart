import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/data/app_dimensions.dart';

class AboutChengelo extends StatelessWidget {
  const AboutChengelo({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    // Responsive AppBar height calculation (Simplified for cleaner code)
    final double expandedHeight = screenSize.width * 0.6 > 200
        ? screenSize.width * 0.6
        : 200;
    return Scaffold(
      backgroundColor: AppColors.exbackground,
      body: CustomScrollView(
        slivers: [
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Top Spacer
                SizedBox(height: AppDimensions.exsized),

                // Image
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(15),
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
