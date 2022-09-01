import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/custom_objects.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../blocs/generics/generic_bloc.dart';

/// Interface to our 'userPublicProfile' Firebase collection.
///
/// Relies on a remote NoSQL document-oriented database.
class AllUserRepository extends GenericBlocRepository<UserPublicProfile>{

  @override
  Stream<List<UserPublicProfile>> data() {
    final CollectionReference<Object> userPublicProfileCollection = FirebaseFirestore.instance
        .collection('userPublicProfile');
    List<UserPublicProfile> _userListFromSnapshot(QuerySnapshot<Object> snapshot) {
      try {
        List<UserPublicProfile> userList = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return UserPublicProfile.fromData(data);
        }).toList();
        userList.sort((UserPublicProfile a, UserPublicProfile b) => a.displayName!.compareTo(b.displayName!));
        userList =
            userList.where((UserPublicProfile user) => user.uid != userService.currentUserID)
                .toList();

        return userList;
      } catch (e) {
        CloudFunction().logError(
            'Error retrieving stream of all users: ${e.toString()}');
        return [];
      }
    }
    // get all users
    return userPublicProfileCollection.snapshots()
        .map(_userListFromSnapshot);
  }
}