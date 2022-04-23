
import 'dart:io' show File, Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../services/analytics_service.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to the info about the current user.
/// Relies on Firebase authentication.
/// Allows to sign in with Google or Apple.
class UserRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AnalyticsService _analyticsService = AnalyticsService();

  UserRepository()
      : _firebaseAuth = FirebaseAuth.instance;

  Future<UserCredential> signInWithCredentials(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

  }

  Future<void> signUp(String email, String password, String firstname, String lastName, String displayName, File urlToImage) async {
    var result = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
    User user = result.user;
    await DatabaseService(uid: user.uid).updateUserData(firstname, lastName, email, user.uid);
    await DatabaseService(uid: user.uid).updateUserPublicProfileData(displayName, firstname, lastName, email, 0, 0, user.uid, urlToImage);
    await _analyticsService.logSignUp();

    return result;
  }

  Future<void> signOut() async {
    return Future.wait([_firebaseAuth.signOut()]);
  }

  Future<bool> isSignedIn() async {
    final currentUser =  _firebaseAuth.currentUser;
    return currentUser != null;
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  User getUser()  {
    return  _firebaseAuth.currentUser;
  }
  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((user) => user);

  }

  bool get appleSignInAvailable => Platform.isIOS;

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [AppleIDAuthorizationScopes.email,AppleIDAuthorizationScopes.fullName]
      );

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);

    } catch (e) {
      CloudFunction().logError('Error in Apple sign in: ${e.toString()}');
      return null;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn
          .signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final GoogleAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult = await _firebaseAuth.signInWithCredential(
          credential);
      final User user = authResult.user;


      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser =  _firebaseAuth.currentUser;
      assert(user.uid == currentUser.uid);
      await _analyticsService.logLoginGoogle();

    } catch (e){
      return e.toString();
    }
  }

  Future<void>updateUserPublicProfile(String firstname, String lastName, String displayName, File urlToImage) async {
    final currentUser =  _firebaseAuth.currentUser;
    if(displayName.isEmpty){
      displayName = 'User${currentUser.uid.substring(currentUser.uid.length - 5)}';
    }
    await DatabaseService(uid: currentUser.uid).updateUserData(firstname, lastName, currentUser.email, currentUser.uid);
    return await DatabaseService(uid: currentUser.uid).updateUserPublicProfileData(displayName, firstname, lastName,currentUser.email, 0, 0, currentUser.uid, urlToImage);
  }

}
