import 'package:get/get.dart';
import '../../../../models/public_user_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/session_services.dart';

class ProfileController extends GetxController {
  RxBool isNotificationEnabled = true.obs;
  Rxn<PublicUserModel> publicProfile = Rxn<PublicUserModel>();

  @override
  void onInit() {
    super.onInit();
    fetchPublicProfile();
  }

  Future<void> fetchPublicProfile() async {
    final String? userId = GlobalVariables.loggedInUser.value?.uid;
    if (userId != null) {
      publicProfile.value = await AuthService.getUserPublicProfile(
        userId: userId,
      );
    }
  }
}
