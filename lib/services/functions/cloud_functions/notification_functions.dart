import 'package:cloud_functions/cloud_functions.dart';

import '../../database.dart';

class NotificationCloudFunction {

    Future<void> addNewNotification(
      {required String message,
      String? uidToUse,
      String? documentID,
      required String type,
      String? ownerID, // ownerID is the owner of the notification received.
      bool? ispublic}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addNewNotification');
    functionData(<String, dynamic>{
      'message': message,
      'uidToUse': uidToUse,
      'documentID': documentID,
      'ispublic': ispublic,
      'ownerID': ownerID,
      'ownerDisplayName': currentUserProfile.userPublicProfile!.displayName,
      'type': type,
    });
  }

  Future<void> addCustomNotification(String message) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addCustomNotification');
    functionData(<String, dynamic>{
      'message': message,
    });
  }

  Future<void> removeNotificationData(String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeNotificationData');
    functionData(<String, dynamic>{
      'uid': userService.currentUserID,
      'fieldID': fieldID,
    });
  }

  Future<void> removeAllNotifications() async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeAllNotifications');
    functionData(<String, dynamic>{});
  }
}
