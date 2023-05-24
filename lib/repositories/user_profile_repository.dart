import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/functions/cloud_functions.dart';
import '../models/public_profile_model/public_profile_model.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
/// It contains the public user profile for each user.
///
/// Relies on a remote NoSQL document-oriented database.
class PublicProfileRepository {

  final CollectionReference<Object> userPublicProfileCollection = FirebaseFirestore.instance.collection('userPublicProfile');
  final StreamController<UserPublicProfile> _loadedData = StreamController<UserPublicProfile>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh(String uid) {
    // Get Public Profile
    UserPublicProfile userProfileFromSnapshot(DocumentSnapshot<Object> snapshot){
      if(snapshot.exists) {
        try {
          // final Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
          return UserPublicProfile.fromJson(snapshot as Map<String, Object>);
        } catch(e){
          CloudFunction().logError('Error retrieving single user profile:  $e');
          return UserPublicProfile.mock();
        }} else {
        return UserPublicProfile.mock();
      }
    }

    final Stream<UserPublicProfile> profile = userPublicProfileCollection
        .doc(uid)
        .snapshots().map(userProfileFromSnapshot);


    _loadedData.addStream(profile);


  }

  Stream<UserPublicProfile> profile() => _loadedData.stream;

}
