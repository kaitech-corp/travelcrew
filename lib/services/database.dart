import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:firebase_storage/firebase_storage.dart';


class DatabaseService {

  final String uid;
  var tripDocID;
  DatabaseService({this.tripDocID, this.uid});


  //  All collection references

  final CollectionReference userCollection = Firestore.instance.collection("users");
  final CollectionReference userPublicProfileCollection = Firestore.instance.collection("userPublicProfile");
  final Query allUsersCollection = Firestore.instance.collection("userPublicProfile").orderBy('lastname').orderBy('firstname');
  final Query tripCollection = Firestore.instance.collection("trips").orderBy('endDateTimeStamp');
  final CollectionReference tripsCollectionUnordered = Firestore.instance.collection("trips");
  final CollectionReference flightCollection =  Firestore.instance.collection("flights");
  final CollectionReference lodgingCollection =  Firestore.instance.collection("lodging");
  final CollectionReference activitiesCollection =  Firestore.instance.collection("activities");
  final CollectionReference chatCollection =  Firestore.instance.collection("chat");
  final CollectionReference notificationCollection = Firestore.instance.collection('notifications');


  Future updateUserData(String firstname, String lastName, String email, String uid) async {
    return await userCollection.document(uid).setData({
      'firstname': firstname,
      'lastname' : lastName,
      'email': email,
      'uid': uid
    });
  }



  Future updateUserPublicProfileData(String displayName, String firstname, String lastName, String email, int tripsCreated, int tripsJoined, String uid, String urlToImage) async {
    return await userPublicProfileCollection.document(uid).setData({
      'displayName': displayName,
      'email': email,
      'firstname': firstname,
      'lastname' : lastName,
      'tripsCreated': tripsCreated,
      'tripsJoined': tripsJoined,
      'uid': uid,
      'urlToImage': urlToImage
    });
  }

  // Save new profile pic
//  Future saveProfilePicture(File urlToImage) async{
//    if (urlToImage != null) {
//      try {
//        String urlforImage;
//        StorageReference storageReference = FirebaseStorage.instance
//            .ref()
//            .child('trips/${key}');
//        StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
//        await uploadTask.onComplete;
//        print('File Uploaded');
//
//        return await tripsCollectionUnordered.document(key).updateData({"urlToImage":  await storageReference.getDownloadURL().then((fileURL) {
//          urlforImage = fileURL;
//          return urlforImage;
//        })});
//      }catch (e) {
//        print('Error storing image and updating image path: ${e.toString()}');
//      }
//    }
//  }

// Get user display name.
  Future<String> retrieveUserDisplayName(String uid) async {
     var ref = await userPublicProfileCollection.document(uid).get();
     String displayName = await ref.data['displayName'];
     return displayName;
  }
  Future<String> retrieveUserPic(String uid) async {
    var ref = await userPublicProfileCollection.document(uid).get();
    String profilePic = await ref.data['urlToImage'];
    return profilePic;
  }

  // Join Trip
  Future joinTrip() async {

     await tripsCollectionUnordered.document(tripDocID).updateData({
       'accessUsers': FieldValue.arrayUnion([uid]),
     });
     await userPublicProfileCollection.document(uid).updateData({
       "tripsJoined": FieldValue.increment(1),
     });
  }
  // Leave Trip
  Future leaveTrip() async {

    await tripsCollectionUnordered.document(tripDocID).updateData({
      'accessUsers': FieldValue.arrayRemove([uid]),
    });
    await userCollection.document(uid).updateData({
      'accessTrips': FieldValue.arrayRemove([tripDocID]),
    });
    await userPublicProfileCollection.document(uid).updateData({
      "tripsJoined": FieldValue.increment(-1),
    });
  }

  // Add new lodging

  Future addNewLodgingData(String comment, String displayName, String documentID, String link, String lodgingType, String uid, File urlToImage, String tripName) async {

    var key = lodgingCollection.document().documentID;
    print(documentID);

    var addNewLodgingRef = lodgingCollection.document(documentID);
    addNewLodgingRef.updateData({ key:
      {'comment': comment,
        'displayName': displayName,
        'fieldID': key,
        'link': link,
        'lodgingType' : lodgingType,
        'tripName': tripName,
        'uid': uid,
        'urlToImage': '',
        'vote': 0,
        'voters': [],}
    });
    String trip = documentID;
    String message = 'A new lodging has been added to $tripName.';
    String type = 'lodging';

    if (urlToImage != null) {
      String urlforImage;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('lodging/$key');
      StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
      await uploadTask.onComplete;
      print('File Uploaded');

      return await addNewLodgingRef.updateData({
        "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
          urlforImage = fileURL;
          return urlforImage;
        })
      });
    }
  }

  // Remove Lodging
  Future removeLodging(String fieldID){
    try {
      return lodgingCollection.document(tripDocID).updateData({fieldID:FieldValue.delete()});
    } catch (e) {
      print('Error deleting activity: ${e.toString()}');
    }
  }

// Add new activity
  Future addNewActivityData(String comment, String displayName, String documentID,
      String link, String activityType, String uid, File urlToImage, String tripName) async {
    var key = activitiesCollection.document().documentID;
    print(documentID);

    var addNewActivityRef = activitiesCollection.document(documentID);
    addNewActivityRef.updateData({ key:
    {'comment': comment,
      'displayName': displayName,
      'fieldID': key,
      'link': link,
      'activityType' : activityType,
      'tripName': tripName,
      'uid': uid,
      'urlToImage': '',
      'vote': 0,
      'voters': [],}
    });
    String trip = documentID;
    String message = 'A new activity has been added to $tripName.';
    String type = 'activity';

    if (urlToImage != null) {
      String urlforImage;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('activity/$key');
      StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
      await uploadTask.onComplete;
      print('File Uploaded');

      return await addNewActivityRef.updateData({
        "$key.urlToImage": await storageReference.getDownloadURL().then((fileURL) {
          urlforImage = fileURL;
          return urlforImage;
        })
      });
    }
  }

  // Remove Activity
  Future removeActivity(String fieldID){
    try {
      return activitiesCollection.document(tripDocID).updateData({fieldID:FieldValue.delete()});
    } catch (e) {
      print('Error deleting activity: ${e.toString()}');
    }
  }

  // Add new chat message

  Future addNewChatMessage(String displayName, String message, String uid, Map status) async {
    var key = chatCollection.document().documentID;
    print('Adding new chat message.');

    return await chatCollection.document(tripDocID).collection('messages').document(key).setData(
        {
      'displayName': displayName,
      'message': message,
        'status': status,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': uid,
    });
  }
// Clear chat notifications.
  Future clearChatNotifications() async {
    var db = await chatCollection.document(tripDocID).collection('messages').where('status.${uid}' ,isEqualTo: false);
    QuerySnapshot snapshot = await db.getDocuments();
    for(var i =0; i< snapshot.documents.length;i++) {
      chatCollection.document(tripDocID).collection('messages').document(snapshot.documents[i].documentID).updateData({'status.${uid}': true});
    }
  }

  // Add new trip
  Future addNewTripData(List<String> accessUsers, String comment, String displayName,
      String endDate, Timestamp endDateTimeStamp, bool ispublic, String location, String ownerID,
      String startDate, String travelType, File urlToImage)

  async {
    var key = chatCollection.document().documentID;
     var addTripRef = await tripsCollectionUnordered.document(key).setData({
      'favorite': [],
      'accessUsers' : accessUsers,
       'comment': comment,
       'displayName': displayName,
      'documentId': key,
      'endDate': endDate,
      'endDateTimeStamp': endDateTimeStamp,
      'ispublic' : ispublic,
      'location': location,
      'ownerID': ownerID,
      'startDate': startDate,
      'travelType': travelType,
      'urlToImage': '',
    });

    try {
      await lodgingCollection.document(key).setData({});
    }catch (e) {
      print('Error adding Lodging: ${e.toString()}');
    }
    try {
      await flightCollection.document(key).setData({});
    }catch (e) {
      print('Error adding Flight: ${e.toString()}');
    }
    try {
      await activitiesCollection.document(key).setData({});
    }catch (e) {
      print('Error adding Activity: ${e.toString()}');
    }

     try {
       await userCollection.document(ownerID).updateData({'trips': FieldValue.arrayUnion([key])});
     }catch (e) {
       print('Error adding new trip to user document: ${e.toString()}');
     }
//     await addTripRef.updateData({"documentId": addTripRef.documentID});

      if (urlToImage != null) {
        try {
          String urlforImage;
               StorageReference storageReference = FirebaseStorage.instance
             .ref()
             .child('trips/${key}');
               StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
               await uploadTask.onComplete;
               print('File Uploaded');
        
               return await tripsCollectionUnordered.document(key).updateData({"urlToImage":  await storageReference.getDownloadURL().then((fileURL) {
          urlforImage = fileURL;
          return urlforImage;
               })});
        }catch (e) {
          print('Error storing image and updating image path: ${e.toString()}');
        }
      }
  }

  Future deleteTrip() async {

    try {
      await lodgingCollection.document(tripDocID).delete();
    }catch (e) {
      print('Error deleting Lodging: ${e.toString()}');
    }
    try {
      await flightCollection.document(tripDocID).delete();
    }catch (e) {
      print('Error deleting Flight: ${e.toString()}');
    }
    try {
      await activitiesCollection.document(tripDocID).delete();
    }catch (e) {
      print('Error deleting Activity: ${e.toString()}');
    }
    try {
      await chatCollection.document(tripDocID).delete();
    }catch (e) {
      print('Error deleting Chat: ${e.toString()}');
    }
    try {
      await tripsCollectionUnordered.document(tripDocID).delete();
    }catch (e) {
      print('Error deleting Trip: ${e.toString()}');
    }
  }

  // Add new notification
  Future addNewNotificationData(String message, String documentID, String type, String ownerID) async {
    var key = notificationCollection.document().documentID;
    try {
      return await notificationCollection.document(ownerID).collection('notifications').document(key).setData({
          'fieldID': key,
          'message': message,
          'timestamp': FieldValue.serverTimestamp(),
          'documentID': documentID,
          'type': type,
          'uid': uid,

      });
    } catch (e) {
      print('Error writing notification: ${e.toString()}');
    }
    }
  // Remove notification
  Future removeNotificationData(String fieldID) async {
    return await notificationCollection.document(uid).collection('notifications').document(fieldID).delete();
  }

  // Edit Trip
  Future editTripData(String comment, String documentID, String endDate, Timestamp endDateTimeStamp,
      bool ispublic, String location, String startDate, String travelType, File urlToImage)

  async {
    var addTripRef = tripsCollectionUnordered.document(documentID);


    await addTripRef.updateData({
      "comment": comment,
      "endDate": endDate,
      "endDateTimeStamp": endDateTimeStamp,
      "ispublic": ispublic,
      "location": location,
      "startDate": startDate,
      "travelType": travelType,
    });
    if (urlToImage != null) {
      String urlforImage;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('trips/${addTripRef.documentID}');
      StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
      await uploadTask.onComplete;
      print('File Uploaded');

      return await addTripRef.updateData({
        "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
          urlforImage = fileURL;
          return urlforImage;
        })
      });
    }
  }

// Get all trips
  List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return Trip(
        accessUsers: List<String>.from(doc.data['accessUsers']) ?? [''],
        comment: doc.data['comment'] ?? '',
        displayName: doc.data['displayName'] ?? '',
        documentId: doc.data['documentId'] ?? '',
        endDate: doc.data['endDate'] ?? '',
        endDateTimeStamp: DateFormat.yMd()
              .format(doc.data['endDateTimeStamp'].toDate()).toString(),
        favorite: List<String>.from(doc.data['favorite']) ?? [''],
        ispublic: doc.data['ispublic'] ?? null,
        location: doc.data['location'] ?? '',
        ownerID: doc.data['ownerID'] ?? '',
        startDate: doc.data['startDate'] ?? '',
        travelType: doc.data['travelType'] ?? '',
        urlToImage: doc.data['urlToImage'] ?? '',
      );
    }).toList();
  }
  // get trips
  Stream<List<Trip>> get trips {
    return tripCollection.snapshots()
    .map(_tripListFromSnapshot);
  }

  //Get all users
  List<UserProfile> _userListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return UserProfile(
        displayName: doc.data['displayName'] ?? '',
        email: doc.data['email'] ?? '',
        firstname: doc.data['firstname'] ?? '',
        lastname: doc.data['lastname'] ?? '',
        uid: doc.data['uid'] ?? '',
        urlToImage: doc.data['urlToImage'] ?? '',
      );
    }).toList();
  }
  // get all users
  Stream<List<UserProfile>> get userList {
    return allUsersCollection.snapshots()
        .map(_userListFromSnapshot);
  }

  // Get current user public profile
  UserProfile _userPublicProfileSnapshot(DocumentSnapshot snapshot){
    var data = snapshot.data;
      return UserProfile(
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        firstname: data['firstname'] ?? '',
        lastname: data['lastname'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );

  }
  Future getUserDisplayName () async {
    try {
      var userRef = userPublicProfileCollection.document(uid);
      DocumentSnapshot snapshot = await userRef.get();
      return snapshot.data['displayName'];
    } catch (e) {
      print('Error retrieving displaynames: ${e.toString()}');
    }

  }

  // get current use public profile
  Stream<UserProfile> get currentUserPublicProfile {
    return userPublicProfileCollection.document(uid).snapshots()
        .map(_userPublicProfileSnapshot);
  }

  // Get flights
  List<FlightData> _flightListFromSnapshot(DocumentSnapshot snapshot){

    try {
      var list2 = List();
      List<FlightData> listOfFlights = List();

      if (snapshot.exists) {
        snapshot.data.forEach((k,v) => list2.add(v));
        
         for (var i =0; i< list2.length;i++) {
           listOfFlights.add(FlightData(
             airline: list2[i]['airline'] ?? '',
             departureDate: list2[i]['departureDate'] ?? '',
             departureDateArrivalTime: list2[i]['departureDateArrivalTime'] ?? '',
             departureDateDepartTime: list2[i]['departureDateDepartTime'] ?? '',
             displayName: list2[i]['displayName'] ?? '',
             flightNumber: list2[i]['flightNumber'] ?? '',
             returnDate: list2[i]['returnDate'] ?? '',
             returnDateArrivalTime: list2[i]['returnDateArrivalTime'] ?? '',
             returnDateDepartTime: list2[i]['returnDateDepartTime'] ?? '',
           ));
         }
      }

        return listOfFlights;
    } catch (e) {
      print('Error retrieving flight data. ${e.toString()}');
    }


  }

  Stream<List<FlightData>> get flightList {
    try {
      return flightCollection.document(tripDocID).snapshots().map(_flightListFromSnapshot);
    } catch (e) {
      print('Error Streaming Flights. ${e.toString()}');
    }
  }

  //Get Lodging items
  List<LodgingData> _lodgingListFromSnapshot(DocumentSnapshot snapshot){

    var _list = List();
    List<LodgingData> listOfLodging = List();

    snapshot.data.forEach((k,v) => _list.add(v));

    for (var i =0; i< _list.length;i++) {
      listOfLodging.add(LodgingData(
        comment: _list[i]['comment'] ?? '',
        displayName: _list[i]['displayName'] ?? '',
        fieldID: _list[i]['fieldID'] ?? '',
        link: _list[i]['link'] ?? '',
        lodgingType: _list[i]['lodgingType'] ?? '',
        uid: _list[i]['uid'] ?? '',
        urlToImage: _list[i]['urlToImage'] ?? '',
        vote: _list[i]['vote'] ?? 0,
        voters: List<String>.from(_list[i]['voters']) ?? [''],
      ));
    }
    listOfLodging.sort((a,b) => b.vote.compareTo(a.vote));
    return listOfLodging;
  }

  //Get Activity List
  Stream<List<LodgingData>> get lodgingList {
    return lodgingCollection.document(tripDocID).snapshots().map(_lodgingListFromSnapshot);
  }

  List<ActivityData> _activitiesListFromSnapshot(DocumentSnapshot snapshot){

    var _list = List();
    List<ActivityData> listOfActivities = List();

    snapshot.data.forEach((k,v) => _list.add(v));

    for (var i =0; i< _list.length;i++) {
      listOfActivities.add(ActivityData(
        comment: _list[i]['comment'] ?? '',
        activityType: _list[i]['activityType'] ?? '',
        displayName: _list[i]['displayName'] ?? '',
        fieldID: _list[i]['fieldID'] ?? '',
        link: _list[i]['link'] ?? '',
        uid: _list[i]['uid'] ?? '',
        urlToImage: _list[i]['urlToImage'] ?? '',
        vote: _list[i]['vote'] ?? 0,
        voters: List<String>.from(_list[i]['voters']) ?? [''],
      ));
    }
    listOfActivities.sort((a,b) => b.vote.compareTo(a.vote));
    return listOfActivities;
  }

  Stream<List<ActivityData>> get activityList {
    return activitiesCollection.document(tripDocID).snapshots().map(_activitiesListFromSnapshot);
  }


  //Query for My Crew Trips
//  final CollectionReference myCrewCollection =  Firestore.instance.collection("trips");

  List<Trip> _crewTripListFromSnapshot(QuerySnapshot snapshot){
    return snapshot.documents.map((doc){
      return Trip(
        accessUsers: List<String>.from(doc.data['accessUsers']) ?? [''],
        comment: doc.data['comment'] ?? '',
        displayName: doc.data['displayName'] ?? '',
        documentId: doc.data['documentId'] ?? '',
        endDate: doc.data['endDate'] ?? '',
        endDateTimeStamp: DateFormat.yMd()
            .format(doc.data['endDateTimeStamp'].toDate()).toString(),
        favorite: List<String>.from(doc.data['favorite']) ?? [''],
        ispublic: doc.data['ispublic'] ?? null,
        location: doc.data['location'] ?? '',
        ownerID: doc.data['ownerID'] ?? '',
        startDate: doc.data['startDate'] ?? '',
        travelType: doc.data['travelType'] ?? '',
        urlToImage: doc.data['urlToImage'] ?? '',
      );
    }).toList();
  }
  // get trips
  Stream<List<Trip>> get crewTrips {
    return tripCollection.where('accessUsers', arrayContainsAny: [uid]).snapshots()
        .map(_crewTripListFromSnapshot);
  }

  Stream<List<Trip>> get favoriteTrips {
    return tripCollection.where('favorite', arrayContainsAny: [uid]).snapshots()
        .map(_tripListFromSnapshot);
  }


// Add Favorite Trip
  Future addFavoriteToTrip(String uid) async {
    try {
      return await tripsCollectionUnordered.document(tripDocID).updateData({
        'favorite': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error adding favorite. ${e.toString()}');
    }

  }
  //Remove Favorite Trip
  Future removeFavoriteFromTrip(String uid) async {
    try {
      return await tripsCollectionUnordered.document(tripDocID).updateData({
        'favorite': FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error removing favorite. ${e.toString()}');
    }
  }

  //Add and Remove vote for activity
  Future addVoteToActivity(String uid, String fieldID) async {
    try {
      await activitiesCollection.document(tripDocID).updateData({
        '$fieldID.vote':
        FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await activitiesCollection.document(tripDocID).updateData({
        '$fieldID.voters':
        FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
  Future removeVoteFromActivity(String uid, String fieldID) async {
    try {
      await activitiesCollection.document(tripDocID).updateData({
        '$fieldID.vote':
        FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await activitiesCollection.document(tripDocID).updateData({
        '$fieldID.voters':
        FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
// Store Images


  //Add and Remove vote for lodging
  Future addVoteToLodging(String uid, String fieldID) async {
    try {
      await lodgingCollection.document(tripDocID).updateData({
        '$fieldID.vote':
        FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await lodgingCollection.document(tripDocID).updateData({
        '$fieldID.voters':
        FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
  Future removeVoteFromLodging(String uid, String fieldID) async {
    try {
      await lodgingCollection.document(tripDocID).updateData({
        '$fieldID.vote':
        FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await lodgingCollection.document(tripDocID).updateData({
        '$fieldID.voters':
        FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }


  // Get all Notifications

  List<NotificationData> _notificationListFromSnapshot(QuerySnapshot snapshot){

    try {
      return snapshot.documents.map((doc){
        return NotificationData(
          documentID: doc.data['documentID'] ?? '',
          fieldID: doc.data['fieldID'] ?? '',
          message: doc.data['message'] ?? '',
          timestamp: doc.data['timestamp'] ?? Timestamp.now(),
          type: doc.data['type'] ?? '',
          uid: doc.data['uid'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error retrieving notifications: ${e.toString()}');
    }
  }

  Stream<List<NotificationData>> get notificationList {
    return notificationCollection.document(uid).collection('notifications').snapshots().map(_notificationListFromSnapshot);
  }

  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot snapshot){

    return snapshot.documents.map((doc){

      return ChatData(
        displayName: doc.data['displayName'] ?? '',
        message: doc.data['message'] ?? '',
        timestamp: doc.data['timestamp'] ?? '',
        uid: doc.data['uid'] ?? '',
      );
    }).toList();
  }

  Stream<List<ChatData>> get chatList {
    try {
      return chatCollection.document(tripDocID).collection('messages')
      .orderBy('timestamp', descending: true)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      print("Could not load chat: ${e.toString()}");
    }
  }
  Stream<List<ChatData>> get chatListNotification {
    try {
      return chatCollection.document(tripDocID).collection('messages').where('status.${uid}' ,isEqualTo: false).snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      print("Could not load chat notification list: ${e.toString()}");
    }
  }

}
