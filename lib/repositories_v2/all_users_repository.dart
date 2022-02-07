import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/custom_objects.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
///
/// Relies on a remote NoSQL document-oriented database.
class AllUserRepository {

  Stream<List<UserPublicProfile>> allUsersDataStream() {
    CollectionReference userPublicProfileCollection = FirebaseFirestore.instance
        .collection("userPublicProfile");
    List<UserPublicProfile> _userListFromSnapshot(QuerySnapshot snapshot) {
      try {
        List<UserPublicProfile> userList = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return UserPublicProfile.fromData(data);
        }).toList();
        userList.sort((a, b) => a.displayName.compareTo(b.displayName));
        userList =
            userList.where((user) => user.uid != userService.currentUserID)
                .toList();

        return userList;
      } catch (e) {
        CloudFunction().logError(
            'Error retrieving stream of all users: ${e.toString()}');
        return null;
      }
    }
    // get all users
    return userPublicProfileCollection.snapshots()
        .map(_userListFromSnapshot);
  }
}