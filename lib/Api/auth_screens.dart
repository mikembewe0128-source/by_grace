import 'dart:developer';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/constants.dart';
import '../widgets/global_widgets.dart';

// Define your desired new color here, for example:
// Deep Sky Blue: 0xFF00BFFF
// Or, if your color was #FF5733, you would use 0xFFFF5733
// Changed the type from int to Color for improved readability and type safety.
const Color kBackgroundColor = Color(
  0xFF000428,
); // <- Replace this with your color!

class AuthScreens {
  // sign in screen
  static Widget buildSignInScreen(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        // FIX: Set the scaffoldBackgroundColor in the theme so Firebase UI widgets adopt the color
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      child: Scaffold(
        // Set the desired background color here
        backgroundColor: kBackgroundColor,
        body: SignInScreen(
          providers: [EmailAuthProvider()],

          // Actions define what happens after sign-in/registration completes
          actions: [
            _handleUserCreation(),
            _handleSignIn(context),
            ForgotPasswordAction((context, email) {
              if (!context.mounted) return;
              Navigator.of(context, rootNavigator: true).pushNamed(
                Constants.forgotPasswordRoute,
                arguments: {'email': email}, // Pass the entered email (if any)
              );
            }),
          ],
          headerBuilder: (context, constraints, shrinkOffset) {
            return _authHeaderLogo();
          },

          // Custom UI builders
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                action == AuthAction.signIn
                    ? 'Welcome STAFF! Please sign in to continue.'
                    : 'Welcome STAFF! Please create an account to continue.',
                style: const TextStyle(color: Colors.grey),
              ),
            );
          },

          footerBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the whole column
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Ensure all children are centered
                children: [
                  // 1. Legal Text (Conditional)
                  Text(
                    action == AuthAction.signIn
                        ? 'By signing in, you agree to our Terms of Service and Privacy Policy.'
                        : 'By creating an account, you agree to our Terms of Service and Privacy Policy.',
                    textAlign: TextAlign.center, // Added for clarity
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 55),

                  // 2. Main Title
                  Text(
                    'chengelo',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 25),
                  ),

                  // 3. Subtitle/Motto
                  Text(
                    '"as a witness to the light"', // Simplified string literal
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color:
                          CupertinoColors.systemYellow, // Using Cupertino color
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // build email verification screen
  static Widget buildEmailVerificationScreen(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        // FIX: Set the scaffoldBackgroundColor in the theme
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      child: Scaffold(
        // Set the desired background color here
        backgroundColor: kBackgroundColor,
        body: Column(
          children: [
            Expanded(
              child: EmailVerificationScreen(
                headerBuilder: (context, constraints, shrinkOffset) {
                  return _authHeaderLogo();
                },
                actions: [
                  // Navigate to home after successful email verification
                  EmailVerifiedAction(() {
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushReplacementNamed(Constants.homeRoute);
                  }),
                  // Sign out and navigate to sign-in screen if user cancels verification
                  AuthCancelledAction((context) {
                    FirebaseUIAuth.signOut();
                    Navigator.of(
                      context,
                      rootNavigator: true,
                    ).pushReplacementNamed(Constants.signInRoute);
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: const Text(
                "If there's no email in the inbox, check the spam or junk folders.",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // handle user creation (registration)
  static AuthStateChangeAction<UserCreated> _handleUserCreation() {
    return AuthStateChangeAction<UserCreated>((context, state) {
      if (!context.mounted) {
        log('Context is no longer mounted. Cannot navigate or show snackbar.');
        return;
      }

      Navigator.of(
        context,
        rootNavigator: true,
      ).pushReplacementNamed(Constants.verifyEmailRoute);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        GlobalWidgets(context).showSnackBar(
          content:
              'Account created! Please check your email to verify your account.',
          backgroundColor: Colors.grey.shade900,
        );
      });
    });
  }

  //handle sign in
  static AuthStateChangeAction<SignedIn> _handleSignIn(BuildContext context) {
    return AuthStateChangeAction<SignedIn>((context, state) {
      if (!context.mounted) return;

      // Navigate based on verification status
      if (!state.user!.emailVerified) {
        log('Email not verified, redirecting to verification screen.');
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(Constants.verifyEmailRoute);
      } else {
        log('Email verified, redirecting to home screen.');
        Navigator.of(
          context,
          rootNavigator: true,
        ).pushReplacementNamed(Constants.homeRoute);
      }
    });
  }

  // build forgot password screen
  static Widget buildForgotPasswordScreen(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final email = arguments?['email'] as String?;

    return Theme(
      data: ThemeData(
        brightness: Brightness.dark,
        // FIX: Set the scaffoldBackgroundColor in the theme
        scaffoldBackgroundColor: kBackgroundColor,
      ),
      child: Scaffold(
        // Set the desired background color here
        backgroundColor: kBackgroundColor,
        body: ForgotPasswordScreen(
          email: email,
          headerMaxExtent: 200,
          headerBuilder: (context, constraints, shrinkOffset) {
            return const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Icon(Icons.lock_reset, size: 60, color: Colors.blueAccent),
            );
          },
        ),
      ),
    );
  }

  // auth header logo
  static Widget _authHeaderLogo() {
    return SizedBox(
      // Set the desired size for the image container (e.g., 250 pixels wide)
      width: 300.0,

      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: AspectRatio(
          aspectRatio: 1, // Will make the height 250 (Width * 1)
          child: Image.asset(
            'assets/iconnzz.png',
            // The height property can be removed now as SizedBox/AspectRatio dictates the size
          ),
        ),
      ),
    );
  }
}
