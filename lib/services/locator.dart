import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../services/functions/cloud_functions.dart';
import '../features/Trip_Management/logic/logic.dart';
import '../models/public_profile_model/public_profile_model.dart';
import 'navigation/navigation_service.dart';

GetIt locator = GetIt.instance;
final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

void setupLocator() {
  locator.registerSingleton(UserService());
  locator.registerLazySingleton(() => ProfileData());
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

Future<void> getCurrentUserProfile() async {
  final UserService userService = locator<UserService>();
  final ProfileData profileData = locator<ProfileData>();
  try {
    final DocumentSnapshot<Object?> userData =
        await userPublicProfileCollection.doc(userService.currentUserID).get();
    if (userData.exists) {
      profileData.userPublicProfile =
          UserPublicProfile.fromJson(userData.data() as Map<String, dynamic>);
    }
  } catch (e) {
    CloudFunction().logError('Error retrieving single user profile:  $e');
    print('Error retrieving single user profile:  $e');
    // return ;
  }
}

class ProfileData extends ChangeNotifier {
  UserPublicProfile? _userPublicProfile;

  UserPublicProfile? get userPublicProfile => _userPublicProfile;

  set userPublicProfile(UserPublicProfile? value) {
    _userPublicProfile = value;
    notifyListeners(); // Notify listeners when the data changes
  }
}
