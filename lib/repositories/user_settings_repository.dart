import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../services/database.dart';
import '../../../../services/functions/cloud_functions.dart';
import '../models/settings_model/settings_model.dart';

/// Interface to our 'settings' Firebase collection.
/// It contains the settings for each user.
///
/// Relies on a remote NoSQL document-oriented database.
class UserSettingsRepository {

  final CollectionReference<Map<String, dynamic>> settingsCollection = FirebaseFirestore.instance.collection('settings');
  final StreamController<SettingsModel> _loadedData = StreamController<SettingsModel>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    // Get settings for current user.
    SettingsModel settingsFromSnapshot(DocumentSnapshot<Object?> snapshot){
      if(snapshot.exists) {
        try {
          return SettingsModel.fromJson(snapshot.data() as Map<String, Object>);
        } catch(e){
          CloudFunction().logError('Error retrieving settings for user:  $e');
          return SettingsModel().fakerData();
        }} else {
        return SettingsModel().fakerData();
      }
    }

    final Stream<SettingsModel> settings = settingsCollection
        .doc(userService.currentUserID)
        .snapshots().map(settingsFromSnapshot);


    _loadedData.addStream(settings);


  }

  Stream<SettingsModel> settingsData() => _loadedData.stream;

}
