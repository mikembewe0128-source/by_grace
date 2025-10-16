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
import 'package:provider/provider.dart';

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

  // 4️⃣ Determine initial route based on authentication state
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final String initialRouteName = currentUser != null
      ? Constants.homeRoute
      : Constants.signInRoute;

  // 5️⃣ Instantiate FirestoreService (starts caching listener)
  final firestoreService = FirestoreService();

  // 6️⃣ Run the app wrapped in Provider
  runApp(
    Provider<FirestoreService>(
      create: (_) => firestoreService,
      dispose: (_, service) => service.dispose(), // Proper cleanup
      child: MyApp(initialRoute: initialRouteName),
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
      routes: routes,
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
