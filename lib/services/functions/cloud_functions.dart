import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../models/custom_objects.dart';
import '../../models/location_model.dart';

import '../../services/locator.dart';
import '../database.dart';

class CloudFunction {
  UserService userService = locator<UserService>();


  Future<void> getDestinations() async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('get_destinations');
    final HttpsCallableResult<dynamic> result = await callable();
  }

  void addCustomMember() {
    final HttpsCallable addCustomMember =
        FirebaseFunctions.instance.httpsCallable('addCustomMember');
    addCustomMember(<String, dynamic>{
      'docID': 'zUEcSXEpEkp8wFV6AIRn',
      'uid': 'NTjJZIWR5jXCVzgl7xIG39Iz0dG3',
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

  // Give feedback
  Future<void> giveFeedback(String message) async {
    final HttpsCallable giveFeedback =
        FirebaseFunctions.instance.httpsCallable('giveFeedback');
    giveFeedback(<String, dynamic>{
      'message': message,
    });
  }

  Future<void> joinTrip(String docID, bool ispublic, String ownerID) async {
    final HttpsCallable joinTrip =
        FirebaseFunctions.instance.httpsCallable('joinTrip');
    joinTrip(<String, dynamic>{
      'docID': docID,
      'ispublic': ispublic,
      'ownerID': ownerID
    });
  }

  Future<void> joinTripInvite(
      String docID, String uidInvitee, bool ispublic) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('joinTripInvite');
    functionData(<String, dynamic>{
      'docID': docID,
      'uidInvitee': uidInvitee,
      'ispublic': ispublic,
    }).then((HttpsCallableResult<dynamic> value) => <void>{
          if (ispublic)
            <void>{
              addMember(docID, uidInvitee),
            }
          else
            <void>{
              addPrivateMember(docID, uidInvitee),
            }
        });
  }

  Future<void> addMember(String docID, String uid) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addMember');
    functionData(<String, dynamic>{
      'docID': docID,
      'uid': uid,
    });
  }

  Future<void> addPrivateMember(String docID, String uid) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addPrivateMember');
    functionData(<String, dynamic>{
      'docID': docID,
      'uid': uid,
    });
  }

  Future<void> deleteTrip(String tripDocID, bool ispublic) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('deleteTrip');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
      'ispublic': ispublic,
    }).then((HttpsCallableResult<dynamic> value) => deleteTripID(tripDocID));
  }

  Future<void> deleteTripID(String tripDocID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('deleteTripID');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
    });
  }

  Future<void> leaveAndRemoveMemberFromTrip(
      {required String tripDocID,
      required String userUID,
      required bool ispublic}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance
        .httpsCallable('leaveAndRemoveMemberFromTrip');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
      'userUID': userUID,
      'ispublic': ispublic,
    });
  }

  Future<void> removeLodging(String docID, String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeLodging');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
    });
  }

  Future<void> removeActivity(String docID, String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeActivity');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
    });
  }

  Future<void> addFavoriteTrip(String docID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addFavoriteTrip');
    functionData(<String, dynamic>{
      'docID': docID,
    });
  }

  Future<void> removeFavoriteFromTrip(String docID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeFavoriteFromTrip');
    functionData(<String, dynamic>{
      'docID': docID,
      'uid': userService.currentUserID,
    });
  }

  Future<void> addVoterToActivity(String docID, String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addVoterToActivity');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  // void removeVoterFromActivity(String docID, String field )
  Future<void> removeVoterFromActivity(String docID, String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeVoterFromActivity');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  Future<void> addVoterToLodging(
      String docID, String fieldID, String uid) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addVoterToLodging');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    });
  }

  Future<void> removeVoterFromLodging(
      String docID, String fieldID, String uid) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeVoterFromLodging');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    });
  }

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



  Future<void> removeItemFromBringingList(
      String tripDocID, String documentID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeItemFromBringingList');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
      'documentID': documentID,
    });
  }

  Future<void> addItemToNeedList(
      String tripDocID, String item, String displayName, String type) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addItemToNeedList');
    functionData(<String, dynamic>{
      'displayName': displayName,
      'item': item,
      'tripDocID': tripDocID,
      'type': type
    });
  }

  Future<void> removeItemFromNeedList(
      String tripDocID, String documentID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeItemFromNeedList');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
      'documentID': documentID,
    });
  }

  Future<void> addNewNotification(
      {required String message,
      String? uidToUse,
      String? documentID,
      required String type,
      String? ownerID,
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

  Future<void> deleteChatMessage(
      {required String tripDocID, required String fieldID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('deleteChatMessage');
    functionData(<String, dynamic>{
      'tripDocID': tripDocID,
      'fieldID': fieldID,
    });
  }

  // Future<List<TCFeedback>> feedbackData() async {
  //   final HttpsCallable functionData = FirebaseFunctions.instance.getHttpsCallable(
  //       functionName: 'feedbackData');
  //   dynamic data = await functionData.call();
  //
  //   return data.map((doc) {
  //     Map<String, dynamic> data = doc.data();
  //     return TCFeedback(
  //       message: data['message'] ?? '',
  //       uid: data['uid'] ?? '',
  //       timestamp: data['timestamp'] ?? null,
  //     );
  //   }).toList();
  // }
  Future<void> feedbackData() async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('feedbackData');
    functionData(<String, dynamic>{});
  }

  Future<void> removeFeedback(String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeFeedback');
    functionData(<String, dynamic>{
      'fieldID': fieldID,
    });
  }

  Future<void> updateClicks(String docID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('updateClicks');
    functionData(<String, dynamic>{
      'docID': docID,
      'uid': userService.currentUserID,
    });
  }

  Future<void> addCurrentLocation(
      {required String docID,
      String? city,
      String? country,
      String? zipcode,
      GeoPoint? geoPoint}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addCurrentLocation');
    functionData(<String, dynamic>{
      'docID': docID,
      'city': city,
      'zipcode': zipcode,
      'country': country,
      'lat': geoPoint?.latitude ?? 0.0,
      'lng': geoPoint?.longitude ?? 0.0,
    });
  }

  Future<void> addReview({required String docID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addReview');
    functionData(<String, dynamic>{
      'docID': docID,
    });
  }

  Future<void> addTransportation(
      {required String mode,
      required String tripDocID,
      bool? canCarpool,
      String? carpoolingWith,
      String? airline,
      String? flightNumber,
      String? comment}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addTransportation');
    functionData(<String, dynamic>{
      'mode': mode,
      'tripDocID': tripDocID,
      'displayName': currentUserProfile.userPublicProfile!.displayName,
      'canCarpool': canCarpool,
      'carpoolingWith': carpoolingWith,
      'airline': airline,
      'flightNumber': flightNumber,
      'comment': comment,
    });
  }

  Future<void> deleteTransportation(
      {required String fieldID, required String tripDocID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('deleteTransportation');
    functionData(<String, dynamic>{
      'fieldID': fieldID,
      'tripDocID': tripDocID,
    });
  }

  Future<void> addVoterToBringingItem(
      {required String documentID, required String tripDocID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addVoterToBringingItem');
    functionData(<String, dynamic>{
      'documentID': documentID,
      'tripDocID': tripDocID,
    });
  }

  Future<void> removeVoterFromBringingItem(
      {required String documentID, required String tripDocID}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeVoterFromBringingItem');
    functionData(<String, dynamic>{
      'documentID': documentID,
      'tripDocID': tripDocID,
    });
  }

//Log event
  Future<void> logEvent(String action) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('logEvent');
    functionData(<String, dynamic>{
      'action': action,
    });
  }

// Log Error
  Future<void> logError(String error) async {
    // final HttpsCallable functionData =
    //     FirebaseFunctions.instance.httpsCallable('logError');
    // functionData(<String, dynamic>{
    //   'error': error,
    // });
  }

  //Disable account
  Future<void> disableAccount() async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('disableAccount');
    functionData();
  }

  // Record Location
  Future<void> recordLocation({required LocationModel locationModel}) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('recordLocation');
    functionData(<String, dynamic>{
      'city': locationModel.city,
      'country': locationModel.country,
      'documentID': locationModel.documentID,
      'latitude': locationModel.geoPoint?.latitude,
      'longitude': locationModel.geoPoint?.longitude,
      'zipcode': locationModel.zipcode,
    });
  }
}//end CloudFunction
