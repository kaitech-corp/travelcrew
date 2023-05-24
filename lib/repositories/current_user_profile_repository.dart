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
          // final Map<String, dynamic> data = snapshot.data()  as Map<String, dynamic>;
          // urlToImage.value = UserPublicProfile.fromData(data).urlToImage ?? '';
          return UserPublicProfile.fromJson(snapshot as Map<String, Object>);
        } catch(e){
          CloudFunction().logError('Error retrieving single user profile:  $e');
          return defaultProfile;
        }} else {
        return defaultProfile;
      }
    }

    final Stream<UserPublicProfile> profile = userPublicProfileCollection
        .doc(userService.currentUserID)
        .snapshots().map(userProfileFromSnapshot);



    _loadedData.addStream(profile);


  }

  Stream<UserPublicProfile> profile() => _loadedData.stream;

}
