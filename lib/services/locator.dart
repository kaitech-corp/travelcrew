import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:get_it/get_it.dart';

import '../../models/custom_objects.dart';
import '../../services/functions/cloud_functions.dart';
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
      CloudFunction().logError('Error retrieving uid for locator: ${e.toString()}');
      return '';
    }
  }
}

/// Provides the user profile of the current user.
class UserProfileService {

  var userService = locator<UserService>();
  late UserPublicProfile profile;

  Future<UserPublicProfile> currentUserProfile() async {

    try {
      profile = await DatabaseService().getUserProfile(userService.currentUserID);
      urlToImage.value = profile?.urlToImage ?? '';
    } catch (e) {
      CloudFunction().logError('Error in User Public Profile service:  ${e.toString()}');
    }

    return profile;
  }

  UserPublicProfile currentUserProfileDirect(){
    currentUserProfile().then((value) => profile = value);
    return profile;
  }
}

