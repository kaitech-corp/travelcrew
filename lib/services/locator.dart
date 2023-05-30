import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get_it/get_it.dart';

import '../../services/functions/cloud_functions.dart';
import '../features/Trip_Management/logic/logic.dart';
import '../models/public_profile_model/public_profile_model.dart';
import 'database.dart';
import 'navigation/navigation_service.dart';


GetIt locator = GetIt.instance;
final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;



void setupLocator() {
  locator.registerSingleton(UserService());
  locator.registerSingleton(UserProfileService());
  locator.registerLazySingleton(() => NavigationService());
}

/// Provides our user ID via Firebase Authentication.
class UserService {
  // auth change user stream

  String get currentUserID {
    try {
      return _auth.currentUser?.uid ?? '';
    } catch (e) {
      CloudFunction().logError('Error retrieving uid for locator: $e');
      return '';
    }
  }
}

/// Provides the user profile of the current user.
class UserProfileService {

  UserService userService = locator<UserService>();
  UserPublicProfile profile = UserPublicProfile.mock();

  Future<UserPublicProfile> currentUserProfile() async {
    try {
      profile = await getUserProfile(userService.currentUserID);
      
    } catch (e) {
      CloudFunction().logError('Error in User Public Profile service:  $e');
    }
    return UserPublicProfile.mock();
  }

  UserPublicProfile currentUserProfileDirect(){
    currentUserProfile().then((UserPublicProfile value) => profile = value);
    return profile;
  }
}
