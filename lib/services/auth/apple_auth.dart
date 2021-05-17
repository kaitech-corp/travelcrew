import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';


class AppleAuthService {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  // Determine if Apple SignIn is available
  Future<bool> get appleSignInAvailable => SignInWithApple.isAvailable();

  /// Sign in with Apple
  Future<auth.User> appleSignIn() async {
    try {

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email,AppleIDAuthorizationScopes.fullName]

      );

      if (appleCredential != null) {
        // handle errors from Apple here
      }

      final auth.OAuthCredential credential = auth.OAuthProvider('apple.com').credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
      );

      auth.UserCredential firebaseResult = await _auth.signInWithCredential(credential);
      auth.User user = firebaseResult.user;

      // Optional, Update user data in Firestore
      // updateUserData(user);

      return user;
    } catch (error) {
      print(error);
      return null;
    }
  }

}