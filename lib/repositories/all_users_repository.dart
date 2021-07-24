import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:travelcrew/services/database.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';

class AllUserRepository {

  final CollectionReference userPublicProfileCollection = FirebaseFirestore.instance.collection("userPublicProfile");
  final _loadedData = StreamController<List<UserPublicProfile>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    //Get all users
    List<UserPublicProfile> _userListFromSnapshot(QuerySnapshot snapshot){

      try {
        List<UserPublicProfile> userList =  snapshot.docs.map((doc){
          Map<String, dynamic> data = doc.data();
          return UserPublicProfile.fromData(data);
        }).toList();
        userList.sort((a,b) => a.displayName.compareTo(b.displayName));
        userList = userList.where((user) => user.uid != userService.currentUserID).toList();

        return userList;
      } catch (e) {
        CloudFunction().logError('Error retrieving stream of all users: ${e.toString()}');
        return null;
      }
    }
    // get all users
    Stream<List<UserPublicProfile>> userList = userPublicProfileCollection.snapshots()
          .map(_userListFromSnapshot);


    _loadedData.addStream(userList);


  }

  Stream<List<UserPublicProfile>> users() => _loadedData.stream;

}