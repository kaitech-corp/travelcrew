import 'package:cloud_functions/cloud_functions.dart';

import '../../database.dart';

class TripCloudFunctions {

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

  void addCustomMember() {
    final HttpsCallable addCustomMember =
        FirebaseFunctions.instance.httpsCallable('addCustomMember');
    addCustomMember(<String, dynamic>{
      'docID': 'zUEcSXEpEkp8wFV6AIRn',
      'uid': 'NTjJZIWR5jXCVzgl7xIG39Iz0dG3',
    });
  }
}
