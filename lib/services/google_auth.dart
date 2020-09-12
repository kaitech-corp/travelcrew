import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:travelcrew/models/custom_objects.dart';

import 'analytics_service.dart';


class GoogleAuthService {


  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final AnalyticsService _analyticsService = AnalyticsService();

  //Create user object based on Firebase user
  User _userFromFirebase(auth.User user){
    return user != null ? User(uid: user.uid) : null;
  }
  Stream<User> get user {
    return _auth.authStateChanges()
        .map(_userFromFirebase);
  }

  Future<String> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleSignInAccount = await googleSignIn
          .signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final auth.GoogleAuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final auth.UserCredential authResult = await _auth.signInWithCredential(
          credential);
      final auth.User user = authResult.user;


      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final auth.User currentUser =  _auth.currentUser;
      assert(user.uid == currentUser.uid);
      await _analyticsService.logLoginGoogle();

      return 'signInWithGoogle succeeded: $user';
    } catch (e){
      print(e.toString());
    }
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }
}