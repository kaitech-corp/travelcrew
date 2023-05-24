// ignore_for_file: always_specify_types

import 'dart:io' show File, Platform;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../features/Profile/logic/logic.dart';

/// Interface to the info about the current user.
/// Relies on Firebase authentication.
/// Allows to sign in with Google or Apple.
class UserRepository {
  UserRepository() : _firebaseAuth = FirebaseAuth.instance;
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithCredentials(
      {required String email, required String password}) async {
    return _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signUp(String email, String password, String? firstname,
      String? lastName, String? displayName, File? urlToImage) async {
    final UserCredential result = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);
    final User? user = result.user;
    await updateUserData(firstname, lastName, email, user!.uid);
    await updateUserPublicProfileData(
        displayName, firstname, lastName, email, user.uid, urlToImage);
  }

  Future<List<dynamic>> signOut() async {
    return Future.wait([_firebaseAuth.signOut()]);
  }

  Future<bool> isSignedIn() async {
    final User? currentUser = _firebaseAuth.currentUser;
    return currentUser != null;
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  User? getUser() {
    return _firebaseAuth.currentUser;
  }

  Stream<User?> get user =>
      _firebaseAuth.authStateChanges().map((User? user) => user);

  bool get appleSignInAvailable => Platform.isIOS;

  Future<UserCredential?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
              scopes: <AppleIDAuthorizationScopes>[
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName
          ]);

      final OAuthCredential credential = OAuthProvider('apple.com').credential(
        accessToken: appleCredential.authorizationCode,
        idToken: appleCredential.identityToken,
      );

      return await _firebaseAuth.signInWithCredential(credential);
    } catch (e) {
      CloudFunction().logError('Error in Apple sign in: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();
      final GoogleSignInAuthentication? googleSignInAuthentication =
          await googleSignInAccount?.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication?.accessToken,
        idToken: googleSignInAuthentication?.idToken,
      );

      final UserCredential authResult =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = authResult.user;

      assert(!user!.isAnonymous);
      assert(await user?.getIdToken() != null);

      final User? currentUser = _firebaseAuth.currentUser;
      assert(user?.uid == currentUser?.uid);

      return authResult;
    } catch (e) {
      return null;
    }
  }

  Future<void> updateUserPublicProfile(String? firstname, String? lastName,
      String? displayName, File? urlToImage) async {
    final User? currentUser = _firebaseAuth.currentUser;
    if (displayName?.isEmpty ?? true) {
      displayName =
          'User${currentUser?.uid.substring(currentUser.uid.length - 5)}';
    }
    await updateUserData(
        firstname, lastName, currentUser.email, currentUser.uid);
    return updateUserPublicProfileData(
        displayName,
        firstname,
        lastName,
        currentUser.email,
        currentUser.uid,
        urlToImage);
  }
}
