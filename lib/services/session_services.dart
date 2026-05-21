import 'package:get/get.dart';
import 'package:travel_crew/models/public_user_model.dart';

import '../models/user_model.dart';

class GlobalVariables {
  static RxBool showLoader = false.obs;
  static bool fromLoginScreen = false;
  static String? toVerify;
  static bool isEmail = false;
  static Rxn<UserModel> loggedInUser = Rxn<UserModel>();
  static Rxn<PublicUserModel> userProfile = Rxn<PublicUserModel>();
  static RxBool isBuyerMode = true.obs;
  static RxString addingToFavourites = ''.obs;
  static RxBool showDropdown = false.obs;

  static String get currentUid => loggedInUser.value?.uid ?? '';

  static bool isLoggedInUser(String id) {
    return loggedInUser.value?.uid == id;
  }
}
