import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../locator.dart';

class UserCloudFunction {
  UserService userService = locator<UserService>();

  Future<void> followUser(String userUID) async {
    // Add user ID to current user's followers list.
    // Add current user's ID to user's following list
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('followUser');
    functionData(<String, dynamic>{
      'userUID': userUID,
    });
  }

  Future<void> followBack(String userUID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('followBack');
    functionData(<String, dynamic>{
      'userUID': userUID,
    });
  }

  Future<void> unFollowUser(String userUID) async {
    // Remove user ID from current user following list.
    // Remove current user ID from user's followers list.
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('unFollowUser');
    functionData(<String, dynamic>{
      'userUID': userUID,
    });
  }

  // Block User
  void blockUser(String blockedUserID) {
    final HttpsCallable blockUser =
        FirebaseFunctions.instance.httpsCallable('blockUser');
    blockUser(<String, dynamic>{'blockedUserID': blockedUserID}).then(
        (HttpsCallableResult<dynamic> value) => unFollowUser(blockedUserID));
  }

  void unBlockUser(String blockedUserID) {
    final HttpsCallable unBlockUser =
        FirebaseFunctions.instance.httpsCallable('unBlockUser');
    unBlockUser(<String, dynamic>{'blockedUserID': blockedUserID});
  }

  // Report inappropriate behaviour
  Future<void> reportUser(String collection, String docID, String offenderID,
      String offense, String type, String urlToImage) async {
    final HttpsCallable giveFeedback =
        FirebaseFunctions.instance.httpsCallable('reportUser');
    giveFeedback(<String, dynamic>{
      'collection': collection,
      'docID': docID,
      'offenderID': offenderID,
      'offense': offense,
      'ownerID': userService.currentUserID,
      'type': type,
      'urlToImage': urlToImage
    });
  }

  Future<void> getDestinations() async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('get_destinations');
    final HttpsCallableResult<dynamic> result = await callable();
    if(kDebugMode) {
      print(result.data);
    }
  }
}
