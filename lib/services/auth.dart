import 'package:firebase_auth/firebase_auth.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';


class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Create user object based on Firebase user
  User _userFromFirebase(FirebaseUser user){
    return user != null ? User(uid: user.uid) : null;
  }

//  var subscription = FirebaseUserReloader.onUserReloaded.listen((user) {
//    // A new user will be printed each time there's a reload
//    print(user);
//
//  });
//  FirebaseUserReloader.reloadCurrentUser();
//  subscription.cancel();
// This will trigger a reload and the reloaded user will be emitted by onUserReloaded

  // auth change user stream

  Stream<User> get user {
    return _auth.onAuthStateChanged
        .map(_userFromFirebase);
  }

  Future signInCredentials(String email, String password) async {
    try {
     AuthResult result =  await _auth.signInWithEmailAndPassword(email: email, password: password);
//    AuthResult result = await _auth.signInAnonymously();
    FirebaseUser user = result.user;
    print(user.uid);


     return _userFromFirebase(user);
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password

  //Register with email and password

  // Sign out
  Future logOut() async {
    try {
       return await _auth.signOut();
    } catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signUpWithEmailAndPassword(String email, String password, String firstname, String lastName, String displayName) async {
    try {
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      await DatabaseService(uid: user.uid).updateUserData(firstname, lastName, email, user.uid);
      await DatabaseService(uid: user.uid).updateUserPublicProfileData(displayName, firstname, lastName, email, 0, 0, user.uid, '');

      return _userFromFirebase(user);
    } catch(e) {
      print(e.toString());
      return null;
    }
  }
}