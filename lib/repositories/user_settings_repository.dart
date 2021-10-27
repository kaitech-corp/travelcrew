import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/settings_model.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class UserSettingsRepository {

  final CollectionReference settingsCollection = FirebaseFirestore.instance.collection('settings');
  final _loadedData = StreamController<UserNotificationSettingsData>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
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

    Stream<UserNotificationSettingsData> settings = settingsCollection
        .doc(userService.currentUserID)
        .snapshots().map(_settingsFromSnapshot);


    _loadedData.addStream(settings);


  }

  Stream<UserNotificationSettingsData> settingsData() => _loadedData.stream;

}