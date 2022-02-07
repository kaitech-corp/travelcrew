import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/settings_model.dart';
import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';

/// Interface to our 'settings' Firebase collection.
/// It contains the settings for each user.
///
/// Relies on a remote NoSQL document-oriented database.
class UserSettingsRepository {


  Stream<UserNotificationSettingsData> settingsDataStream() {

    final CollectionReference settingsCollection = FirebaseFirestore.instance.collection('settings');

    // Get settings for current user.
    UserNotificationSettingsData _settingsFromSnapshot(DocumentSnapshot snapshot){
      if(snapshot.exists) {
        try {
          Map<String, dynamic> data = snapshot.data();
          return UserNotificationSettingsData.fromData(data);
        } catch(e){
          CloudFunction().logError('Error retrieving settings for user:  ${e.toString()}');
          return UserNotificationSettingsData().fakerData();
        }} else {
        return UserNotificationSettingsData().fakerData();
      }
    }

    return settingsCollection
        .doc(userService.currentUserID)
        .snapshots()
        .map(_settingsFromSnapshot);
  }
}
