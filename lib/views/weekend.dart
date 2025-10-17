import 'package:flutter/material.dart';
import 'package:grace_by/data/app_colors.dart';

class Weekend extends StatelessWidget {
  const Weekend({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isLandscape = screenSize.width > screenSize.height;

    // Responsive AppBar height calculation (Simplified for cleaner code)
    final double expandedHeight = screenSize.width * 0.6 > 200
        ? screenSize.width * 0.6
        : 200;
    return Scaffold(
      backgroundColor: AppColors.exwwhite,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back_ios, color: AppColors.exbackground),
            ),
            backgroundColor: const Color(0xFF000428),
            pinned: true,
            elevation: 6.0,
            scrolledUnderElevation: 6.0,
            surfaceTintColor: Colors.transparent,
            expandedHeight: expandedHeight,
            title: Text(
              'Chengelo',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.white),
            ),
            centerTitle: true,
            flexibleSpace: FlexibleSpaceBar(
              title: null,
              background: DecoratedBox(
                decoration: const BoxDecoration(color: Color(0xFF000428)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100.0),
                  child: Center(
                    child: FractionallySizedBox(
                      widthFactor: isLandscape ? 0.4 : 0.8,
                      heightFactor: isLandscape ? 0.6 : 0.8,
                      child: Image.asset(
                        'assets/iconnzz.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Preferred way to center a static "empty" state in a CustomScrollView
          SliverFillRemaining(
            hasScrollBody:
                false, // Ensures the content remains fixed and centered
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/soon.png'), // The image
                  const SizedBox(height: 50),
                  Text(
                    'Coming Soon!',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.exblue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
