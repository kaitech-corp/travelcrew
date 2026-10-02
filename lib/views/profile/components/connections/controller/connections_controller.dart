import 'package:get/get.dart';
import '../../../../../models/public_user_model.dart';
import '../../../../../services/auth_service.dart';

class ConnectionsController extends GetxController {
  final RxList<PublicUserModel> followers = <PublicUserModel>[].obs;
  final RxList<PublicUserModel> following = <PublicUserModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxInt initialIndex = 0.obs;
  String? userId;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map<String, dynamic>) {
      initialIndex.value = Get.arguments['initialIndex'] ?? 0;
      userId = Get.arguments['userId'];
      loadConnections(userId!);
    }
  }

  Future<void> loadConnections(String userId) async {
    isLoading.value = true;
    try {
      final List<PublicUserModel> followersList =
          await AuthService.getFollowers(userId);
      final List<PublicUserModel> followingList =
          await AuthService.getFollowing(userId);
      followers.assignAll(followersList);
      following.assignAll(followingList);
    } catch (e) {
      // Error handled in AuthService
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow(PublicUserModel user) async {
    // Implement toggle follow logic if needed in this screen
  }
}
