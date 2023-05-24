

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/custom_objects.dart';
import '../../../services/functions/cloud_functions.dart';

  final CollectionReference<Object?> userPublicProfileCollection =
      FirebaseFirestore.instance.collection('userPublicProfile');
///Get all users Future Builder
  Future<List<UserPublicProfile>> usersList() async {
    try {
      final QuerySnapshot<Object?> ref =
          await userPublicProfileCollection.get();
      final List<UserPublicProfile> userList =
          ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
        // final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        return UserPublicProfile.fromDocument(doc);
      }).toList();
      userList.sort((UserPublicProfile a, UserPublicProfile b) =>
          a.displayName.compareTo(b.displayName));
      return userList;
    } catch (e) {
      CloudFunction().logError('Error retrieving all users: $e');
      return <UserPublicProfile>[];
    }
  }