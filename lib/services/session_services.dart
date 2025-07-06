import 'package:get/get.dart';
import 'package:travel_crew/models/public_user_model.dart';

import '../models/user_model.dart';

class GlobalVariables {
  static RxBool showLoader = false.obs;
  static bool fromLoginScreen = false;
  static String? toVerify;
  static bool isEmail = false;
  static Rxn<UserModel?> loggedInUser = Rxn(null);
  static Rxn<PublicUserModel?> userProfile = Rxn(null);
  static RxBool isBuyerMode = true.obs;
  static String userId = GlobalVariables.loggedInUser.value?.uid ?? '';
  static RxString addingToFavourites = ''.obs;
  static RxBool showDropdown = false.obs;

  static bool isLoggedInUser(String id) {
    return loggedInUser.value?.uid == id;
  }
}
