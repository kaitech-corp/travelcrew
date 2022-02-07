import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/custom_objects.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
/// It contains the public profile infos for all users.
///
/// Relies on a remote NoSQL document-oriented database.
class CurrentUserProfileRepository {

Stream<UserPublicProfile> currentUserProfileDataStream() {
    final CollectionReference userPublicProfileCollection = FirebaseFirestore.instance.collection("userPublicProfile");

    // Get Public Profile
    UserPublicProfile _userProfileFromSnapshot(DocumentSnapshot snapshot){
      if(snapshot.exists) {
        try {
          Map<String, dynamic> data = snapshot.data();
          urlToImage.value = UserPublicProfile.fromData(data).urlToImage;
          return UserPublicProfile.fromData(data);
        } catch(e){
          CloudFunction().logError('Error retrieving single user profile:  ${e.toString()}');
          return null;
        }} else {
        return null;
      }
    }

    return userPublicProfileCollection
        .doc(userService.currentUserID)
        .snapshots().map(_userProfileFromSnapshot);

  }
}
