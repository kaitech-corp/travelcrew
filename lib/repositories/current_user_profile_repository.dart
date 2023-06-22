import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../models/public_profile_model/public_profile_model.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
/// It contains the public profile infos for all users.
///
/// Relies on a remote NoSQL document-oriented database.
class CurrentUserProfileRepository {

  final CollectionReference<Object> userPublicProfileCollection = FirebaseFirestore.instance.collection('userPublicProfile');
  final StreamController<UserPublicProfile> _loadedData = StreamController<UserPublicProfile>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    // Get Public Profile
    UserPublicProfile userProfileFromSnapshot(DocumentSnapshot<Object> snapshot){
      if(snapshot.exists) {
        try {
          return UserPublicProfile.fromJson(snapshot.data() as Map<String, dynamic>);
        } catch(e){
          CloudFunction().logError('Error retrieving single user profile:  $e');
          return UserPublicProfile.mock();
        }} else {
        return UserPublicProfile.mock();
      }
    }

    final Stream<UserPublicProfile> profile = userPublicProfileCollection
        .doc(userService.currentUserID)
        .snapshots().map(userProfileFromSnapshot);



    _loadedData.addStream(profile);


  }

  Stream<UserPublicProfile> profile() => _loadedData.stream;

}
