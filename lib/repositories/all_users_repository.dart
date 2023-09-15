import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';
import '../models/public_profile_model/public_profile_model.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
///
/// Relies on a remote NoSQL document-oriented database.
class AllUserRepository extends GenericBlocRepository<UserPublicProfile>{

  @override
  Stream<List<UserPublicProfile>> data() {
    final CollectionReference<Object> userPublicProfileCollection = FirebaseFirestore.instance
        .collection('userPublicProfile');
    List<UserPublicProfile> userListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        List<UserPublicProfile> userList = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return UserPublicProfile.fromJson(doc.data()! as Map<String, dynamic>);
        }).toList();
        userList.sort((UserPublicProfile a, UserPublicProfile b) => a.displayName.compareTo(b.displayName));
        userList =
            userList.where((UserPublicProfile user) => user.uid != userService.currentUserID)
                .toList();
        return userList;
      } catch (e) {
        CloudFunction().logError(
            'Error retrieving stream of all users: $e');
        return <UserPublicProfile>[];
      }
    }
    // get all users
    return userPublicProfileCollection.snapshots()
        .map(userListFromSnapshot);
  }
}
