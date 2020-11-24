import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;


GetIt locator = GetIt.asNewInstance();
final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;


void setupLocator() {
  locator.registerSingleton(UserService());
  locator.registerSingleton(UserProfileService());
}

class UserService {
  // auth change user stream

  String get currentUserID {
    try {
      return _auth.currentUser.uid;
    } catch (e) {
      return '';
    }
  }
}
class UserProfileService {

  var userService = locator<UserService>();
  UserPublicProfile profile;

  Future<UserPublicProfile> currentUserProfile() async {
    var ref = await FirebaseFirestore.instance.collection("userPublicProfile").doc(userService.currentUserID).get();
    if(ref.exists){
      Map<String, dynamic> data = ref.data();
      profile = UserPublicProfile(
        blockedList: List<String>.from(data['blockedList']) ?? [],
        following: List<String>.from(data['following']) ?? [],
        followers: List<String>.from(data['followers']) ?? [],
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );
      return profile;
    } else {
      return null;
    }
  }

  UserPublicProfile currentUserProfileDirect(){
    currentUserProfile().then((value) => profile = value);
    return profile;
  }
}
class UserProfileServiceStream {

  var userService = locator<UserService>();
  UserPublicProfile profile;

  UserPublicProfile _userListFromSnapshot(DocumentSnapshot snapshot){
    if (snapshot.exists)
    {

      Map<String, dynamic> data = snapshot.data();
      profile = UserPublicProfile(
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        following: List<String>.from(data['following']) ?? [''],
        followers: List<String>.from(data['followers']) ?? [''],
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );

    }

  }
  // get all users
  Stream<UserPublicProfile> get userList {
    return FirebaseFirestore.instance.collection("userPublicProfile").doc(userService.currentUserID).snapshots()
        .map(_userListFromSnapshot);
  }
}

