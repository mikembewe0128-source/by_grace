class Constants {
  // Route names
  static const String homeRoute = '/home';
  static const String signInRoute = '/sign-in';
  static const String verifyEmailRoute = '/verify-email';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String profileRoute = '/profile';
  static const String landingRoute = '/landing';

  // firestore collection names
  static const String usersCollection = 'users';
  // firestore storage buctkets
  static const String profileImagesBucket = 'profileImages';

  // cachemanager keys
  static const String profileimageKey = 'userImage';

  // usermodel fields
  static const String userIdField = 'userId';
  static const String emailField = 'email';
  static const String nameField = 'name';
  static const String profileImageUrlField = 'imageUrl';
  static const String createdAtField = 'createdAt';
  static const String phoneNumberField = 'phoneNumber';
  static const String addressField = 'address';
  static const String fcmTokenField = 'fcmToken';
  static const String isOnlineField = 'isOnline';
}
