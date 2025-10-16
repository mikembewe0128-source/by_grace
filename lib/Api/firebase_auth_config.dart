import 'package:firebase_ui_auth/firebase_ui_auth.dart';

class FirebaseAuthConfig {
  static void configureProviders() {
    // This is where EmailAuthProvider is defined and used.
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  }
}
