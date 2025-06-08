import 'package:get/get.dart';

import '../models/user_model.dart';

class GlobalVariables {
  static RxBool showLoader = false.obs;
  static bool fromLoginScreen = false;
  static String? toVerify;
  static bool isEmail = false;
  static Rxn<UserModel?> loggedInUser = Rxn(null);
  static RxBool isBuyerMode = true.obs;
  static String userId = GlobalVariables.loggedInUser.value?.id ?? '';
  static RxString addingToFavourites = ''.obs;
  static RxBool showDropdown = false.obs;

  static bool isLoggedInUser(String id) {
    return loggedInUser.value?.id == id;
  }
}
