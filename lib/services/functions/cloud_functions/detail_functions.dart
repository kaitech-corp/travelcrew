import 'package:cloud_functions/cloud_functions.dart';

import '../../database.dart';
import '../../locator.dart';

class DetailCloudFunction {
  UserService userService = locator<UserService>();
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
      String docID, String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addVoterToLodging');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  Future<void> removeVoterFromLodging(
      String docID, String fieldID) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('removeVoterFromLodging');
    functionData(<String, dynamic>{
      'docID': docID,
      'fieldID': fieldID,
      'uid': userService.currentUserID,
    });
  }

  Future<void> addItemToBringingList(
      String tripDocID, String? item, String? type) async {
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('addItemToBringingList');
    functionData(<String, dynamic>{
      'displayName': currentUserProfile.userPublicProfile!.displayName,
      'item': item,
      'tripDocID': tripDocID,
      'type': type
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
}
