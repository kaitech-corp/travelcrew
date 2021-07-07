import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/analytics_service.dart';
import 'package:travelcrew/services/database.dart';

import '../functions/cloud_functions.dart';


class AuthService {

  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final AnalyticsService _analyticsService = AnalyticsService();

  //Create user object based on Firebase user
  User _userFromFirebase(auth.User user){

    return user != null ? User(uid: user.uid) : null;

  }

  // auth change user stream

  Stream<User> get user {
    return _auth.authStateChanges()
        .map(_userFromFirebase);
  }

  Future signInCredentials(String email, String password) async {
    try {
     auth.UserCredential result =  await _auth.signInWithEmailAndPassword(email: email, password: password);
//    AuthResult result = await _auth.signInAnonymously();
    auth.User user = result.user;

    if(user.uid != null){
      await _analyticsService.logLogin();
    }

     return _userFromFirebase(user);
    } catch(e){
      print(e.toString());
      if (e.toString().contains('ERROR_WRONG_PASSWORD')){
        return 'The password provided is invalid or the username is incorrect.';
      } else {
        if (e.toString().contains('ERROR_USER_NOT_FOUND')){
          return 'There is no user record corresponding to this email.';
        }else {
          return 'Error logging in with provided credentials.';
        }
      }
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
  // Sign in with email and password

  //Register with email and password

  // Sign out
  void logOut() async {
    try {
      _auth.signOut();
    } catch(e){
      CloudFunction().logError('Error signing out: ${e.toString()}');
    }
  }

  Future signUpWithEmailAndPassword(String email, String password, String firstname, String lastName, String displayName, File urlToImage) async {
    try {
      auth.UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      auth.User user = result.user;
      await DatabaseService(uid: user.uid).updateUserData(firstname, lastName, email, user.uid);
      await DatabaseService(uid: user.uid).updateUserPublicProfileData(displayName, firstname, lastName, email, 0, 0, user.uid, urlToImage);
      await _analyticsService.logSignUp();
      return _userFromFirebase(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

}