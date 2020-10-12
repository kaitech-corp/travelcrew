import 'package:cloud_functions/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';

class CloudFunction {

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

  // Block User
  void blockUser(String blockedUserID){
    final HttpsCallable blockUser = CloudFunctions.instance.getHttpsCallable(
        functionName: 'blockUser');
    blockUser({
      'blockedUserID': blockedUserID
    }).then((value) =>
    unFollowUser(blockedUserID));
  }
  void unBlockUser(String blockedUserID){
    final HttpsCallable unBlockUser = CloudFunctions.instance.getHttpsCallable(
        functionName: 'unBlockUser');
    unBlockUser({
      'blockedUserID': blockedUserID
    });
  }
  // Report inappropriate behaviour
  void reportUser(String collection, String docID, String offenderID, String offense, String type, String urlToImage) async {
    final HttpsCallable giveFeedback = CloudFunctions.instance.getHttpsCallable(
        functionName: 'reportUser');
    giveFeedback({
      'collection' : collection,
      'docID' : docID,
      'offenderID': offenderID,
      'offense': offense,
      'ownerID': userService.currentUserID,
      'type': type,
      'urlToImage': urlToImage
    });
  }
  // Give feedback
  void giveFeedback(String message) async {
    final HttpsCallable giveFeedback = CloudFunctions.instance.getHttpsCallable(
        functionName: 'giveFeedback');
    giveFeedback({
      'message': message,
    });
  }


  void joinTrip(String docID, bool ispublic, String ownerID) async {
    final HttpsCallable joinTrip = CloudFunctions.instance.getHttpsCallable(
        functionName: 'joinTrip');
    joinTrip({
      'docID': docID,
      'ispublic':ispublic,
      'ownerID': ownerID
    }).then((value) =>
    {
      print('Join Trip completed'),
      if(ispublic){
        addMember(docID, userService.currentUserID),
      } else
        {
          addPrivateMember(docID, userService.currentUserID),
        }
    });
  }

  void joinTripInvite(String docID, String uidInvitee, bool ispublic) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'joinTripInvite');
    functionData({
      'docID': docID,
      'uidInvitee': uidInvitee,
      'ispublic':ispublic,
    }).then((value) =>
    {
      print('Join Trip completed'),
      if(ispublic){
        addMember(docID, uidInvitee),
      } else
        {
          addPrivateMember(docID, uidInvitee),
        }
    });
  }

  void addMember(String docID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addMember');
    functionData({
      'docID': docID,
      'uid': uid,
    });
  }
  void addPrivateMember(String docID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addPrivateMember');
    functionData({
      'docID': docID,
      'uid': uid,
    });
  }

  void deleteTrip(String tripDocID, bool ispublic) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'deleteTrip');
    functionData({
      'tripDocID': tripDocID,
      'ispublic': ispublic,
    }).then((value) => deleteTripID(tripDocID));
  }

  void deleteTripID(String tripDocID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'deleteTripID');
    functionData({
      'tripDocID': tripDocID,
    });
  }


  void leaveAndRemoveMemberFromTrip(String tripDocID, String userUID, bool ispublic) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'leaveAndRemoveMemberFromTrip');
    functionData({
      'tripDocID': tripDocID,
      'userUID': userUID,
      'ispublic': ispublic,
    });
  }
  void removeLodging(String docID, String fieldID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    });
  }

  void removeActivity(String docID, String fieldID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    });
  }

  void addFavoriteTrip(String docID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: "addFavoriteTrip");
    functionData({
      'docID': docID,
    });
  }

  void removeFavoriteFromTrip(String docID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeFavoriteFromTrip');
    functionData({
      'docID': docID,
      'uid': userService.currentUserID,
    });
  }

  // void addVoteToActivity(String docID, String fieldID) async {
  //   final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
  //       functionName: 'addVoteToActivity');
  //   functionData({
  //     'docID': docID,
  //     'fieldID': fieldID,
  //   });
  // }

  void addVoterToActivity(String docID, String fieldID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addVoterToActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  // void removeVoteFromActivity(String docID, String fieldID) async {
  //   final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
  //       functionName: 'removeVoteFromActivity');
  //   functionData({
  //     'docID': docID,
  //     'fieldID': fieldID,
  //   });
  // }

  // void removeVoterFromActivity(String docID, String field )
  void removeVoterFromActivity(String docID, String fieldID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeVoterFromActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  // void addVoteToLodging(String docID, String fieldID) async {
  //   final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
  //       functionName: 'addVoteToLodging');
  //   functionData({
  //     'docID': docID,
  //     'fieldID': fieldID,
  //   });
  // }

  void addVoterToLodging(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addVoterToLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    });
  }

  // void removeVoteFromLodging(String docID, String fieldID) async {
  //   final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
  //       functionName: 'removeVoteFromLodging');
  //   functionData({
  //     'docID': docID,
  //     'fieldID': fieldID,
  //   });
  // }

  void removeVoterFromLodging(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeVoterFromLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    });
  }

  void followUser(String userUID) async {
    // Add user ID to current user's followers list.
    // Add current user's ID to user's following list
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'followUser');
    functionData({
      'userUID': userUID,
    });
  }
  void followBack(String userUID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'followBack');
    functionData({
      'userUID': userUID,
    });
  }

  void unFollowUser(String userUID) async {
    // Remove user ID from current user following list.
    // Remove current user ID from user's followers list.
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'unFollowUser');
    functionData({
      'userUID': userUID,
    });
  }

  void addItemToBringingList(String tripDocID, String item) async {

    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addItemToBringingList');
    functionData({
      'displayName': currentUserProfile.displayName,
      'item': item,
      'tripDocID': tripDocID,
    });
  }

  void removeItemFromBringingList(String tripDocID, String documentID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeItemFromBringingList');
    functionData({
      'tripDocID': tripDocID,
      'documentID': documentID,
    });
  }

  void addItemToNeedList(String tripDocID, String item, String displayName) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addItemToNeedList');
    functionData({
      'displayName': displayName,
      'item': item,
      'tripDocID': tripDocID,
    });
  }

  void removeItemFromNeedList(String tripDocID, String documentID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeItemFromNeedList');
    functionData({
      'tripDocID': tripDocID,
      'documentID': documentID,
    });
  }

  void addNewNotification({String message, String uidToUse, String documentID, String type, String ownerID, bool ispublic}) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'addNewNotification');
    functionData({
      'message': message,
      'uidToUse': uidToUse,
      'documentID': documentID,
      'ispublic': ispublic,
      'ownerID': ownerID,
      'type': type,
    });
  }
  void removeNotificationData(String fieldID) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeNotificationData');
    functionData({
      'uid': userService.currentUserID,
      'fieldID': fieldID,
    });
  }

  void removeAllNotifications() async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'removeAllNotifications');
    functionData({
    });
  }

  void deleteChatMessage({String tripDocID, String fieldID}) async {
    final HttpsCallable functionData = CloudFunctions.instance.getHttpsCallable(
        functionName: 'deleteChatMessage');
    functionData({
      'tripDocID': tripDocID,
      'fieldID': fieldID,
    });
  }

}