import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/data/app_colors.dart';
import 'package:grace_by/onboarding/onboarding_items.dart';
import 'package:grace_by/data/constants.dart'; // 👈 for Constants.signInRoute
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    // Get screen metrics and text scale factor for responsive design
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaleFactor = MediaQuery.of(context).textScaleFactor;

    // Define proportional vertical spacing based on screen height
    final smallVSpace = screenHeight * 0.01; // ~1% of screen height
    final mediumVSpace = screenHeight * 0.03; // ~3% of screen height

    return Scaffold(
      backgroundColor: AppColors.exblue,
      bottomSheet: Container(
        color: AppColors.exblue,
        // The padding remains fixed as it's part of the visual design
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: isLastPage
            ? getStarted()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // skip button
                  TextButton(
                    onPressed: () =>
                        pageController.jumpToPage(controller.items.length - 1),
                    child: Text(
                      "Skip",
                      style: TextStyle(
                        // Scale font size slightly for better accessibility
                        fontSize: 20 * textScaleFactor * 0.9,
                        color: Colors.white70,
                      ),
                    ),
                  ),

                  // indicator
                  SmoothPageIndicator(
                    controller: pageController,
                    count: controller.items.length,
                    onDotClicked: (index) => pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    ),
                    effect: const WormEffect(
                      activeDotColor: Colors.white70,
                      dotColor: Colors.white30,
                      dotHeight: 10,
                      dotWidth: 10,
                    ),
                  ),

                  // next button
                  TextButton(
                    onPressed: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeIn,
                    ),
                    child: Text(
                      "Next",
                      style: TextStyle(
                        // Scale font size slightly for better accessibility
                        fontSize: 20 * textScaleFactor * 0.9,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ],
              ),
      ),

      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15),
        child: PageView.builder(
          controller: pageController,
          onPageChanged: (index) {
            setState(() => isLastPage = index == controller.items.length - 1);
          },
          itemCount: controller.items.length,
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon at top
                Image.asset(item.icon, height: 100),

                // Small title - now uses proportional spacing
                SizedBox(height: smallVSpace), // 👈 CHANGED
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 18 * textScaleFactor, // 👈 CHANGED
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: smallVSpace), // 👈 CHANGED
                // Main image (scaled down to fit)
                Flexible(
                  flex: 2,
                  child: Image.asset(
                    item.image,
                    fit: BoxFit.contain,
                    height: screenHeight * 0.28, // Already responsive
                  ),
                ),

                SizedBox(
                  height: mediumVSpace,
                ), // 👈 CHANGED (increased to 3% for better separation from image)
                // Title text
                Text(
                  item.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24 * textScaleFactor, // 👈 CHANGED
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(
                  height: 8,
                ), // Small fixed space (part of visual design)
                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    item.description,
                    style: TextStyle(
                      color: AppColors.exbackground,
                      fontSize: 15 * textScaleFactor,
                    ), // 👈 CHANGED
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: mediumVSpace), // 👈 CHANGED
                // Small footer branding
                Column(
                  children: [
                    Text(
                      'chengelo',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            (Theme.of(
                                  context,
                                ).textTheme.titleMedium?.fontSize ??
                                16) *
                            textScaleFactor, // 👈 CHANGED
                      ),
                    ),
                    const Text(
                      '"as a witness to the light"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: CupertinoColors.systemYellow,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                // Add a small spacer at the very bottom to push content up slightly
                SizedBox(height: smallVSpace), // 👈 ADDED
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getStarted() {
    return Container(
      width: MediaQuery.of(context).size.width * .9,
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.exbackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool("onboarding", true);

          if (!mounted) return;

          // Go to SignIn screen after onboarding
          Navigator.pushReplacementNamed(context, Constants.signInRoute);
        },
        child: Text(
          "Get Started",
          style: TextStyle(
            color: AppColors.exblue,
            // Scale font size slightly for better accessibility
            fontSize: 18 * MediaQuery.of(context).textScaleFactor, // 👈 CHANGED
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
