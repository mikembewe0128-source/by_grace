// main.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    hide EmailAuthProvider, PhoneAuthProvider;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:grace_by/Api/firestore_service.dart';
import 'package:grace_by/data/constants.dart';
import 'package:grace_by/firebase_options.dart';
import 'package:grace_by/Api/auth_screens.dart';
import 'package:grace_by/views/home/home_page.dart';
import 'package:grace_by/onboarding/onboarding_view.dart'; // 👈 Add this import
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ==========================================================
// ROUTES
// ==========================================================
final Map<String, WidgetBuilder> routes = {
  Constants.signInRoute: (context) => AuthScreens.buildSignInScreen(context),
  Constants.homeRoute: (context) => const HomePage(),
  Constants.verifyEmailRoute: (context) =>
      AuthScreens.buildEmailVerificationScreen(context),
  Constants.forgotPasswordRoute: (context) =>
      AuthScreens.buildForgotPasswordScreen(context),
};

// ==========================================================
// 🚀 MAIN FUNCTION — With FirestoreService Initialization
// ==========================================================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2️⃣ Enable Firestore Offline Persistence
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  // 3️⃣ Configure FirebaseUI Auth Providers
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);

  // 4️⃣ Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final bool seenOnboarding = prefs.getBool('onboarding') ?? false;

  // 5️⃣ Determine which screen to start on
  final User? currentUser = FirebaseAuth.instance.currentUser;
  String initialRoute;

  if (!seenOnboarding) {
    // 👋 Show onboarding first
    initialRoute = '/onboarding';
  } else if (currentUser != null) {
    // 🔐 User already signed in
    initialRoute = Constants.homeRoute;
  } else {
    // 🧍 User not signed in yet
    initialRoute = Constants.signInRoute;
  }

  // 6️⃣ Instantiate FirestoreService
  final firestoreService = FirestoreService();

  // 7️⃣ Run app
  runApp(
    Provider<FirestoreService>(
      create: (_) => firestoreService,
      dispose: (_, service) => service.dispose(),
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

// ==========================================================
// APP WIDGET
// ==========================================================
class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        ...routes,
        '/onboarding': (context) => const OnboardingView(), // 👈 Add route
      },
      theme: ThemeData(
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleMedium: TextStyle(fontSize: 29, color: Colors.white),
          titleSmall: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: Color(0xFF000428),
          ),
          labelMedium: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 19,
            color: Colors.black,
          ),
          labelLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 27,
            color: Color(0xFF000428),
          ),
        ),
      ),
    );
  }
}
