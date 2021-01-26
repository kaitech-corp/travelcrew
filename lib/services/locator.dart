import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

import 'database.dart';
import 'navigation/navigation_service.dart';


GetIt locator = GetIt.asNewInstance();
final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;



void setupLocator() {
  locator.registerSingleton(UserService());
  locator.registerSingleton(UserProfileService());
  locator.registerLazySingleton(() => NavigationService());
  // locator.registerSingleton(UserProfileServiceStream());
}

class UserService {
  // auth change user stream

  String get currentUserID {
    try {
      return _auth.currentUser.uid;
    } catch (e) {
      CloudFunction().logError('Error retrieving uid for locator: ${e.toString()}');
      return '';
    }
  }
}
class UserProfileService {

  var userService = locator<UserService>();
  UserPublicProfile profile;

  Future<UserPublicProfile> currentUserProfile() async {

    try {
      profile = await DatabaseService().getUserProfile(userService.currentUserID);
    } catch (e) {
      CloudFunction().logError(e.toString());
    }

    return profile;
  }

  UserPublicProfile currentUserProfileDirect(){
    currentUserProfile().then((value) => profile = value);
    return profile;
  }
}

