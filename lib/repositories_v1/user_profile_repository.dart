import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/custom_objects.dart';
import '../../../services/functions/cloud_functions.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
/// It contains the public user profile for each user.
///
/// Relies on a remote NoSQL document-oriented database.
class PublicProfileRepository {

  final CollectionReference userPublicProfileCollection = FirebaseFirestore.instance.collection("userPublicProfile");
  final _loadedData = StreamController<UserPublicProfile>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh(String uid) {
    // Get Public Profile
    UserPublicProfile _userProfileFromSnapshot(DocumentSnapshot snapshot){
      if(snapshot.exists) {
        try {
          Map<String, dynamic> data = snapshot.data();
          return UserPublicProfile.fromData(data);
        } catch(e){
          CloudFunction().logError('Error retrieving single user profile:  ${e.toString()}');
          return null;
        }} else {
        return null;
      }
    }

    Stream<UserPublicProfile> profile = userPublicProfileCollection
        .doc(uid)
        .snapshots().map(_userProfileFromSnapshot);


    _loadedData.addStream(profile);


  }

  Stream<UserPublicProfile> profile() => _loadedData.stream;

}
