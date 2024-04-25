import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

import '../../../models/location_model/location_model.dart';
import '../../locator.dart';

class AdminCloudFunction {
  UserService userService = locator<UserService>();

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
    final HttpsCallable functionData =
        FirebaseFunctions.instance.httpsCallable('logEvent');
    functionData(<String, dynamic>{
      'error': error,
    });
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
      // 'latitude': locationModel.geoPoint?.latitude,
      // 'longitude': locationModel.geoPoint?.longitude,
      'zipcode': locationModel.zipcode,
    });
  }
}
