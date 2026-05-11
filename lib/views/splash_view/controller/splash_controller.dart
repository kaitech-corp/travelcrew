import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/secure_storage_service.dart';

import '../../../utils/app_strings.dart';

class SplashController extends GetxController {
  Future<void> setUser() async {
    if (FirebaseAuth.instance.currentUser == null) {
      if ((await SecureStorageService.readByKey(key: 'haveSeenOnboarding')) ==
          null) {
        // User has not seen onboarding screen
        await SecureStorageService.saveInStorage(
          key: 'haveSeenOnboarding',
          data: 'true',
        );
        Get.offNamed(kOnboardingScreenRoute);
      } else {
        Get.toNamed(kLoginScreenRoute);
      }
    } else {
      // await AuthService.getUser().then((user) {
      //   if (user == null) {
      //     Get.offNamed(kOnboardingScreenRoute);
      //   } else {
      await AuthService.validateUser(fromSplash: true);
      //   }
      // });
    }
  }
}
