import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:apple_sign_in/apple_sign_in.dart';


class AppleAuthService {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  // Determine if Apple SignIn is available
  Future<bool> get appleSignInAvailable => AppleSignIn.isAvailable();

  /// Sign in with Apple
  Future<auth.User> appleSignIn() async {
    try {

      final AuthorizationResult appleResult = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      if (appleResult.error != null) {
        // handle errors from Apple here
      }

      final auth.OAuthCredential credential = auth.OAuthProvider('apple.com').credential(
        accessToken: String.fromCharCodes(appleResult.credential.authorizationCode),
        idToken: String.fromCharCodes(appleResult.credential.identityToken),
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