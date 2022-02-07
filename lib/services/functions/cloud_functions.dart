import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/analytics_service.dart';
import '../../services/locator.dart';

/// Calls our cloud functions.
class CloudFunction {

  final Trace trace = FirebasePerformance.instance.newTrace("test");

  var userService = locator<UserService>();
  var currentUserProfile = locator<UserProfileService>()
      .currentUserProfileDirect();
  final AnalyticsService _analyticsService = AnalyticsService();

  Future<dynamic> connectSplitwise() async {
    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable('connectSplitwise');
    final results = await callable({
      'consumerKey': dotenv.env['consumerKey'],
      'consumerSecret': dotenv.env['consumerSecret'],
    });
    return results.data;
  }

  /// FIXME: What does this do?
  void splitwiseAPI() async {
    final HttpsCallable callable = FirebaseFunctions.instance
        .httpsCallable(
        'connectToSplitwise');
    final results = await callable({
      'consumerKey': dotenv.env['consumerKey'],
      'consumerSecret': dotenv.env['consumerSecret']
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('accessToken', results.data);
    print(results.data);
  }

  Future<dynamic> splitwiseGetCurrentUser(String accessToken) async {
    final HttpsCallable callableGetCurrentUser = FirebaseFunctions.instance
        .httpsCallable(
        'getCurrentUser');
    final results = await callableGetCurrentUser({
      'consumerKey': dotenv.env['consumerKey'],
      'consumerSecret': dotenv.env['consumerSecret'],
      'accessToken': accessToken,
    });
    return results.data;
  }
  Future<dynamic> splitwiseGetFriends(String accessToken) async {
    final HttpsCallable callableGetFriends = FirebaseFunctions.instance
        .httpsCallable(
        'getFriends');
    final results = await callableGetFriends({
      'consumerKey': dotenv.env['consumerKey'],
      'consumerSecret': dotenv.env['consumerSecret'],
      'accessToken': accessToken,
    });
    return results.data;
  }

  void addCustomMember() {
    final HttpsCallable addCustomMember = FirebaseFunctions.instance
        .httpsCallable(
        'addCustomMember');
    addCustomMember({
      'docID': 'zUEcSXEpEkp8wFV6AIRn',
      'uid': 'NTjJZIWR5jXCVzgl7xIG39Iz0dG3',
    });
  }

  // Block User
  void blockUser(String blockedUserID) {
    final HttpsCallable blockUser = FirebaseFunctions.instance.httpsCallable( 'blockUser');
    blockUser({
      'blockedUserID': blockedUserID
    }).then((value) =>
        unFollowUser(blockedUserID));
  }

  void unBlockUser(String blockedUserID) {
    final HttpsCallable unBlockUser = FirebaseFunctions.instance.httpsCallable( 'unBlockUser');
    unBlockUser({
      'blockedUserID': blockedUserID
    });
  }

  // Report inappropriate behaviour
  void reportUser(String collection, String docID, String offenderID,
      String offense, String type, String urlToImage) async {
    final HttpsCallable giveFeedback = FirebaseFunctions.instance.httpsCallable( 'reportUser');
    giveFeedback({
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
  void giveFeedback(String message) async {
    final HttpsCallable giveFeedback = FirebaseFunctions.instance.httpsCallable( 'giveFeedback');
    giveFeedback({
      'message': message,
    });
  }


  void joinTrip(String docID, bool ispublic, String ownerID) async {
    final HttpsCallable joinTrip = FirebaseFunctions.instance.httpsCallable( 'joinTrip');
    joinTrip({
      'docID': docID,
      'ispublic': ispublic,
      'ownerID': ownerID
    }).then((value) =>
    {
      _analyticsService.joinedTrip(true),
    });
  }

  void joinTripInvite(String docID, String uidInvitee, bool ispublic) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'joinTripInvite');
    functionData({
      'docID': docID,
      'uidInvitee': uidInvitee,
      'ispublic': ispublic,
    }).then((value) =>
    {
      _analyticsService.joinedTrip(true),
      if(ispublic){
        addMember(docID, uidInvitee),
      } else
        {
          addPrivateMember(docID, uidInvitee),
        }
    });
  }

  void addMember(String docID, String uid) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addMember');
    functionData({
      'docID': docID,
      'uid': uid,
    });
  }

  void addPrivateMember(String docID, String uid) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addPrivateMember');
    functionData({
      'docID': docID,
      'uid': uid,
    });
  }

  void deleteTrip(String tripDocID, bool ispublic) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'deleteTrip');
    functionData({
      'tripDocID': tripDocID,
      'ispublic': ispublic,
    }).then((value) => deleteTripID(tripDocID));
  }

  void deleteTripID(String tripDocID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'deleteTripID');
    functionData({
      'tripDocID': tripDocID,
    });
  }


  void leaveAndRemoveMemberFromTrip(String tripDocID, String userUID,
      bool ispublic) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'leaveAndRemoveMemberFromTrip');
    functionData({
      'tripDocID': tripDocID,
      'userUID': userUID,
      'ispublic': ispublic,
    });
  }

  void removeLodging(String docID, String fieldID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    });
  }

  void removeActivity(String docID, String fieldID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
    });
  }

  void addFavoriteTrip(String docID) async {
    trace.start();
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( "addFavoriteTrip");
    functionData({
      'docID': docID,
    }).then((value) =>
    {
      _analyticsService.likedTrip(),
      trace.stop(),
    });
  }

  void removeFavoriteFromTrip(String docID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeFavoriteFromTrip');
    functionData({
      'docID': docID,
      'uid': userService.currentUserID,
    });
  }

  void addVoterToActivity(String docID, String fieldID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addVoterToActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  // void removeVoterFromActivity(String docID, String field )
  void removeVoterFromActivity(String docID, String fieldID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeVoterFromActivity');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }


  void addVoterToLodging(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addVoterToLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    });
  }

  void removeVoterFromLodging(String docID, String fieldID, String uid) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeVoterFromLodging');
    functionData({
      'docID': docID,
      'fieldID': fieldID,
      'uid': uid,
    });
  }

  void followUser(String userUID) async {
    // Add user ID to current user's followers list.
    // Add current user's ID to user's following list
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'followUser');
    functionData({
      'userUID': userUID,
    });
  }

  void followBack(String userUID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'followBack');
    functionData({
      'userUID': userUID,
    });
  }

  void unFollowUser(String userUID) async {
    // Remove user ID from current user following list.
    // Remove current user ID from user's followers list.
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'unFollowUser');
    functionData({
      'userUID': userUID,
    });
  }

  void addItemToBringingList(String tripDocID, String item,String type) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addItemToBringingList');
    functionData({
      'displayName': currentUserProfile.displayName,
      'item': item,
      'tripDocID': tripDocID,
      'type': type
    });
  }

  void removeItemFromBringingList(String tripDocID, String documentID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeItemFromBringingList');
    functionData({
      'tripDocID': tripDocID,
      'documentID': documentID,
    });
  }

  void addItemToNeedList(String tripDocID, String item,
      String displayName,String type) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addItemToNeedList');
    functionData({
      'displayName': displayName,
      'item': item,
      'tripDocID': tripDocID,
      'type': type
    });
  }

  void removeItemFromNeedList(String tripDocID, String documentID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeItemFromNeedList');
    functionData({
      'tripDocID': tripDocID,
      'documentID': documentID,
    });
  }

  void addNewNotification(
      {String message, String uidToUse, String documentID, String type, String ownerID, bool ispublic}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addNewNotification');
    functionData({
      'message': message,
      'uidToUse': uidToUse,
      'documentID': documentID,
      'ispublic': ispublic,
      'ownerID': ownerID,
      'ownerDisplayName': currentUserProfile.displayName,
      'type': type,
    });
  }

  void addCustomNotification(String message) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addCustomNotification');
    functionData({
      'message': message,
    });
  }

  void removeNotificationData(String fieldID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeNotificationData');
    functionData({
      'uid': userService.currentUserID,
      'fieldID': fieldID,
    });
  }

  void removeAllNotifications() async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeAllNotifications');
    functionData({
    });
  }

  void deleteChatMessage({String tripDocID, String fieldID}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'deleteChatMessage');
    functionData({
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
  void feedbackData() async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'feedbackData');
    functionData({
    });
  }

  void removeFeedback(String fieldID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeFeedback');
    functionData({
      'fieldID': fieldID,
    });
  }

  void updateClicks(String docID) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'updateClicks');
    functionData({
      'docID': docID,
      'uid': currentUserProfile.uid,
    });
  }


  void addCurrentLocation(
      {String docID, String city, String country, String zipcode, GeoPoint geoPoint}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addCurrentLocation');
    functionData({
      'docID': docID,
      'city': city,
      'zipcode': zipcode,
      'country': country,
      'lat': geoPoint.latitude,
      'lng': geoPoint.longitude,
    });
  }


  void addReview({String docID}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addReview');
    functionData({
      'docID': docID,
    });
  }

  void addTransportation({String mode, String tripDocID, bool canCarpool,
    String carpoolingWith, String airline, String flightNumber, String comment}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addTransportation');
    functionData({
      'mode': mode,
      'tripDocID': tripDocID,
      'displayName': currentUserProfile.displayName,
      'canCarpool': canCarpool,
      'carpoolingWith': carpoolingWith,
      'airline': airline,
      'flightNumber': flightNumber,
      'comment': comment,
    });
  }

  void deleteTransportation({String fieldID, String tripDocID}) async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'deleteTransportation');
    functionData({
      'fieldID':fieldID,
      'tripDocID':tripDocID,
    });
  }

  void addVoterToBringingItem({String documentID, String tripDocID}) async{
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'addVoterToBringingItem');
    functionData({
      'documentID':documentID,
      'tripDocID':tripDocID,
    });
  }

  void removeVoterFromBringingItem({String documentID, String tripDocID}) async{
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'removeVoterFromBringingItem');
    functionData({
      'documentID':documentID,
      'tripDocID':tripDocID,
    });
  }
//Log event
  void logEvent(String action) async{
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'logEvent');
    functionData({
      'action': action,
    });
  }
// Log Error
  void logError(String error) async{
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable( 'logError');
    functionData({
      'error': error,
    });
  }

  //Disable account
  void disableAccount() async {
    final HttpsCallable functionData = FirebaseFunctions.instance.httpsCallable('disableAccount');
    functionData();
  }

  // void addSplitItem(String )
}//end CloudFunction

