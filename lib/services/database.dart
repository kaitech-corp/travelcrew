import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'analytics_service.dart';


class DatabaseService {

  final String uid;
  var tripDocID;
  DatabaseService({this.tripDocID, this.uid});
  final AnalyticsService _analyticsService = AnalyticsService();

  //  All collection references

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference userPublicProfileCollection = FirebaseFirestore.instance.collection("userPublicProfile");
  final Query allUsersCollection = FirebaseFirestore.instance.collection("userPublicProfile").orderBy('lastname').orderBy('firstname');
  final Query tripCollection = FirebaseFirestore.instance.collection("trips").orderBy('endDateTimeStamp').where('ispublic', isEqualTo: true);
  final Query privateTripCollection = FirebaseFirestore.instance.collection("privateTrips").orderBy('endDateTimeStamp');
  final CollectionReference tripsCollectionUnordered = FirebaseFirestore.instance.collection("trips");
  final CollectionReference privateTripsCollectionUnordered = FirebaseFirestore.instance.collection("privateTrips");
  final CollectionReference flightCollection =  FirebaseFirestore.instance.collection("flights");
  final CollectionReference lodgingCollection =  FirebaseFirestore.instance.collection("lodging");
  final CollectionReference activitiesCollection =  FirebaseFirestore.instance.collection("activities");
  final CollectionReference chatCollection =  FirebaseFirestore.instance.collection("chat");
  final CollectionReference notificationCollection = FirebaseFirestore.instance.collection('notifications');
  final CollectionReference bringListCollection = FirebaseFirestore.instance.collection('bringList');
  final CollectionReference needListCollection = FirebaseFirestore.instance.collection('needList');



  Future updateUserData(String firstName, String lastName, String email, String uid) async {
    return await userCollection.doc(uid).set({
      'firstName': firstName,
      'lastName' : lastName,
      'email': email,
      'uid': uid
    });
  }

  Future<bool> checkUserHasProfile() async {
    var ref = userCollection.doc(uid);
    var refSnapshot = await ref.get();

    return refSnapshot.exists;
    }


  Future updateUserPublicProfileData(String displayName, String firstName, String lastName, String email, int tripsCreated, int tripsJoined, String uid, File urlToImage) async {
    var ref = userPublicProfileCollection.doc(uid);
     try {
       await ref.set({
        'displayName': displayName,
        'email': email,
         'followers': [],
         'following': [],
        'firstName': firstName,
        'lastName' : lastName,
        'tripsCreated': tripsCreated,
        'tripsJoined': tripsJoined,
        'uid': uid,
        'urlToImage': ''
           });
     } catch (e) {
       print('Error creating Public: ${e.toString()}');
       _analyticsService.writeError('Error creating Public: ${e.toString()}');
     }
     if (urlToImage != null) {
       String urlforImage;
       
       try {
         StorageReference storageReference = FirebaseStorage.instance
             .ref()
             .child('users/$uid');
         StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
         await uploadTask.onComplete;
         print('File Uploaded');
         
         return await ref.update({
           'urlToImage': await storageReference.getDownloadURL().then((fileURL) {
             urlforImage = fileURL;
             return urlforImage;
           })
         });
       } catch (e) {
        print('Error updating with image url: ${e.toString()}');
        _analyticsService.writeError('Error updating public profile with image url: ${e.toString()}');
       }
     }
  }

  // Edit Public Profile page
  Future editPublicProfileData(String displayName, String firstName, String lastName, File urlToImage) async {
    var ref = userPublicProfileCollection.doc(uid);
    try {
      await ref.update({
        'displayName': displayName,
        'firstName': firstName,
        'lastName' : lastName,
      });
    } catch (e) {
      print('Error editing Public Profile: ${e.toString()}');
      _analyticsService.writeError('Error editing Public Profile: ${e.toString()}');
    }
    if (urlToImage != null) {
      String urlforImage;

      try {
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('users/$uid');
        StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
        await uploadTask.onComplete;
        print('File Uploaded');

        return await ref.update({
          'urlToImage': await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      } catch (e) {
        print('Error updating with image url: ${e.toString()}');
        _analyticsService.writeError('Error editing Public Profile with image url: ${e.toString()}');
      }
    }
  }

// Get user display name.
  Future<UserPublicProfile> retrieveUserPublicProfile(String uid) async {
     var ref = await userPublicProfileCollection.doc(uid).get();
     if(ref.exists){
       Map<String, dynamic> data = ref.data();
       return UserPublicProfile(
         displayName: data['displayName'],
         firstName: data['firstName'],
         lastName: data['lastName'],
         urlToImage: data['urlToImage'],
       );
     } else {
       return null;
     }
  }
  Future<String> retrieveUserPic(String uid) async {
    var ref = await userPublicProfileCollection.doc(uid).get();
    Map<String, dynamic> data = ref.data();
    String profilePic = await data['urlToImage'];
    return profilePic;
  }

  //Follow a user
  Future followUser(String userUID) async {
     userPublicProfileCollection.doc(userUID).update({
      'following': FieldValue.arrayUnion([uid]),
    });
     userPublicProfileCollection.doc(uid).update({
       'followers': FieldValue.arrayUnion([userUID]),
     });
  }

  //Un-Follow a user
  Future unFollowUser(String userUID) async {
    userPublicProfileCollection.doc(uid).update({
      'following': FieldValue.arrayRemove([userUID]),
    });
    userPublicProfileCollection.doc(userUID).update({
      'followers': FieldValue.arrayRemove([uid]),
    });
  }

  // Get following list
  Future<List<UserProfile>> retrieveFollowingList() async {
    List<UserProfile> followingList;
    UserProfile followingListUID;
    try {
      await userPublicProfileCollection.doc(uid).get().then((value) => {
        if(value.exists) {
          followingListUID = UserProfile(
            following: List<String>.from(value.data()['following']) ?? [''],
            // firstName: value.data['firstName'] ?? '',
          ),
        }
      });
      await usersList().then((value) =>
      {
        followingList =
            value.where((user) => followingListUID.following.contains(user.uid)).toList(),
      });
      return followingList;
    } catch (e) {
      print('Error getting following list: ${e.toString()}');
    }


  }


  // Join Trip &
  //Add member to Trip
  Future joinTrip() async {

    try {
      await tripsCollectionUnordered.doc(tripDocID).update({
        'accessUsers': FieldValue.arrayUnion([uid]),
      }).then((value) =>
      {
        retrieveUserPublicProfile(uid).then((value) =>
        {
          tripsCollectionUnordered.doc(tripDocID)
              .collection('Members')
              .doc(uid)
              .set({
            'displayName': value.displayName ?? '',
            'firstName': value.firstName ?? '',
            'lastName': value.lastName ?? '',
            'uid': uid,
            'urlToImage': value.urlToImage ?? '',
          })
        })
      });
      
    } catch(e){
      print('Error joining trip: ${e.toString()}');
      _analyticsService.writeError('Error joining trip:  ${e.toString()}');
    }

     await userPublicProfileCollection.doc(uid).update({
       "tripsJoined": FieldValue.increment(1),
     });

  }


  // Leave Trip
  Future leaveTrip() async {

     tripsCollectionUnordered.doc(tripDocID).update({
      'accessUsers': FieldValue.arrayRemove([uid]),
    });
     tripsCollectionUnordered.doc(tripDocID).collection('Members').doc(uid).delete();

     userCollection.doc(uid).update({
      'accessTrips': FieldValue.arrayRemove([tripDocID]),
    });
     userPublicProfileCollection.doc(uid).update({
      "tripsJoined": FieldValue.increment(-1),
    });
  }
  // Add new trip
  Future addNewTripData(List<String> accessUsers, String comment, String displayName,
      String endDate, String firstName, String lastName, Timestamp endDateTimeStamp, Timestamp startDateTimeStamp, bool ispublic, String location, String ownerID,
      String startDate, String travelType, File urlToImage)

  async {
    var key = tripsCollectionUnordered.doc().id;
    if (ispublic) {
      var addTripRef =  tripsCollectionUnordered.doc(key);
      try {
         addTripRef.set(
            {
              'favorite': [],
              'accessUsers': accessUsers,
              'comment': comment,
              'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
              'displayName': displayName,
              'documentId': key,
              'endDate': endDate,
              'endDateTimeStamp': endDateTimeStamp,
              'ispublic': ispublic,
              'location': location,
              'ownerID': ownerID,
              'startDate': startDate,
              'startDateTimeStamp': startDateTimeStamp,
              'travelType': travelType,
              'urlToImage': '',
            });

         _analyticsService.createTrip(true);
      } catch (e){
        print("Error saving trip: ${e.toString()}");
        _analyticsService.writeError('Error saving new public trip:  ${e.toString()}');
      }
      try {
         addTripRef.collection('Members').doc(ownerID).set({
           'displayName' : displayName,
           'firstName': firstName,
           'lastname' : lastName,
           'uid' : ownerID,
           'urlToImage' : '',
         });
      } catch(e){
        print(e.toString());
      }

    } else {
      var addTripRef = privateTripsCollectionUnordered.doc(key);
      try {
         addTripRef.set({
          'favorite': [],
          'accessUsers': accessUsers,
          'comment': comment,
           'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
          'displayName': displayName,
          'documentId': key,
          'endDate': endDate,
          'endDateTimeStamp': endDateTimeStamp,
          'ispublic': ispublic,
          'location': location,
          'ownerID': ownerID,
          'startDate': startDate,
           'startDateTimeStamp': startDateTimeStamp,
          'travelType': travelType,
          'urlToImage': '',
        });
         _analyticsService.createPrivateTrip(true);
      }
      catch (e) {
        print("Error saving private trip: ${e.toString()}");
        _analyticsService.writeError('Error saving new private trip:  ${e.toString()}');
      }
      try {
        addTripRef.collection('Members').doc(ownerID).set({
          'displayName' : displayName,
          'firstName': firstName,
          'lastName' : lastName,
          'uid' : ownerID,
          'urlToImage' : '',
        });
      } catch(e){
        print(e.toString());
      }
    }

    try {
      await flightCollection.doc(key).set({});
    }catch (e) {
      print('Error adding Flight: ${e.toString()}');
    }

    try {
      await userCollection.doc(ownerID).update({'trips': FieldValue.arrayUnion([key])});
    }catch (e) {
      print('Error adding new trip to user document: ${e.toString()}');
    }
//     await addTripRef.update({"documentId": addTripRef.id});

    if (urlToImage != null) {
      if(ispublic) {
        try {
          String urlforImage;
          StorageReference storageReference = FirebaseStorage.instance
              .ref()
              .child('trips/$key');
          StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
          await uploadTask.onComplete;
          print('File Uploaded');

          return await tripsCollectionUnordered.doc(key).update({
            "urlToImage": await storageReference.getDownloadURL().then((
                fileURL) {
              urlforImage = fileURL;
              return urlforImage;
            })
          });
        } catch (e) {
          print('Error storing image and updating image path: ${e.toString()}');
        }
      } else {
        try {
          String urlforImage;
          StorageReference storageReference = FirebaseStorage.instance
              .ref()
              .child('trips/$key');
          StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
          await uploadTask.onComplete;
          print('File Uploaded');

          return await privateTripsCollectionUnordered.doc(key).update({
            "urlToImage": await storageReference.getDownloadURL().then((
                fileURL) {
              urlforImage = fileURL;
              return urlforImage;
            })
          });
        } catch (e) {
          print('Error storing image and updating image path: ${e.toString()}');
        }
      }
    }
  }
  // Convert trip (private or public)
  Future convertTrip(Trip trip)
  async {
    if (!trip.ispublic) {
      try {
        await tripsCollectionUnordered.doc(trip.documentId).set(
            {
              'favorite': trip.favorite,
              'accessUsers': trip.accessUsers,
              'comment': trip.comment,
              'dateCreatedTimeStamp': trip.dateCreatedTimeStamp,
              'displayName': trip.displayName,
              'documentId': trip.documentId,
              'endDate': trip.endDate,
              'endDateTimeStamp': trip.endDateTimeStamp,
              'ispublic': true,
              'location': trip.location,
              'ownerID': trip.ownerID,
              'startDate': trip.startDate,
              'startDateTimeStamp': trip.startDateTimeStamp,
              'travelType': trip.travelType,
              'urlToImage': trip.urlToImage,
            });
        try {
           privateTripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          print("Error deleting private trip: ${e.toString()}");
        }
      } catch (e) {
        print("Error saving trip: ${e.toString()}");
        _analyticsService.writeError('Error converting to public trip:  ${e.toString()}');
      }
    } else {
      try {
        await privateTripsCollectionUnordered.doc(trip.documentId)
            .set({
          'favorite': trip.favorite,
          'accessUsers': trip.accessUsers,
          'comment': trip.comment,
          'dateCreatedTimeStamp': trip.dateCreatedTimeStamp,
          'displayName': trip.displayName,
          'documentId': trip.documentId,
          'endDate': trip.endDate,
          'endDateTimeStamp': trip.endDateTimeStamp,
          'ispublic': false,
          'location': trip.location,
          'ownerID': trip.ownerID,
          'startDate': trip.startDate,
          'startDateTimeStamp': trip.startDateTimeStamp,
          'travelType': trip.travelType,
          'urlToImage': trip.urlToImage,
        });
        try {
           tripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          print("Error deleting public trip: ${e.toString()}");
        }
      }
      catch (e) {
        print("Error saving private trip: ${e.toString()}");
        _analyticsService.writeError('Error converting to private trip:  ${e.toString()}');
      }
    }
  }
// Delete trip
  Future deleteTrip() async {

    try {
      await lodgingCollection.doc(tripDocID).delete();
    }catch (e) {
      print('Error deleting Lodging: ${e.toString()}');
    }
    try {
      await flightCollection.doc(tripDocID).delete();
    }catch (e) {
      print('Error deleting Flight: ${e.toString()}');
    }
    try {
      await activitiesCollection.doc(tripDocID).delete();
    }catch (e) {
      print('Error deleting Activity: ${e.toString()}');
    }
    try {
      await chatCollection.doc(tripDocID).delete();
    }catch (e) {
      print('Error deleting Chat: ${e.toString()}');
    }
    try {
      await tripsCollectionUnordered.doc(tripDocID).delete();
    }catch (e) {
      print('Error deleting Trip: ${e.toString()}');
    }
    try {
      await privateTripsCollectionUnordered.doc(tripDocID).delete();
    }catch (e) {
      print('Error deleting Trip: ${e.toString()}');
    }
  }
  // Update trip with new field
  Future updateTrip(String documentID) async {
    var updateTripRef = tripsCollectionUnordered.doc(documentID);
    await updateTripRef.update({
      'dateCreatedTimeStamp': FieldValue.serverTimestamp()
    });
  }


// Edit Trip
  Future editTripData(String comment, String documentID, String endDate, Timestamp endDateTimeStamp,
      bool ispublic, String location, String startDate, String travelType, File urlToImage)

  async {
    var addTripRef = ispublic ? tripsCollectionUnordered.doc(documentID) : privateTripsCollectionUnordered.doc(documentID);


    await addTripRef.update({
      "comment": comment,
      'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
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
          .child('trips/${addTripRef.id}');
      StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
      await uploadTask.onComplete;
      print('File Uploaded');

      return await addTripRef.update({
        "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
          urlforImage = fileURL;
          return urlforImage;
        })
      });
    }
  }

  //Add items the user is Bringing
  Future addItemToBringingList(String tripDocID, String item, String displayName) async {
    String key = bringListCollection.doc().id;
    try {
      var ref = bringListCollection.doc(tripDocID).collection('Items')
          .doc(key);
      ref.set({
        'item': item,
        'displayName': displayName,
        'documentID': key
      });
    } catch (e) {
      print('Error saving item to Bringing collection: ${e.toString()}');
    }
  }

  List<Bringing> _retrieveBringingItems(QuerySnapshot snapshot) {
        return snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
            return Bringing(
            displayName: data['displayName'] ?? '',
            item: data['item'] ?? '',
            documentID: data['documentID'] ?? ''
        );
      }).toList();
  }
  Stream<List<Bringing>> getBringingList(String docID){
    return bringListCollection.doc(docID).collection('Items').snapshots().map(_retrieveBringingItems);
  }

  //Remove item from Bring list
  Future removeItemFromBringingList(String tripDocID, String documentID) async {
    try {
      var ref = bringListCollection.doc(tripDocID).collection('Items')
          .doc(documentID);
      ref.delete();
    } catch (e) {
      print('Error deleting item from Bringing collection: ${e.toString()}');
    }
  }

  //Create a list of items user wants others to bring
  Future addItemToNeedList(String docID, String item, String displayName) async {
    String key = needListCollection.doc().id;
    try {
      var ref = needListCollection.doc(docID).collection('Items')
          .doc(key);
      ref.set({
        'item': item,
        'displayName': displayName,
        'documentID': key
      });
    } catch (e) {
      print('Error saving item to Need collection: ${e.toString()}');
    }
  }

  List<Need> _retrieveNeedItems(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
      return Need(
          displayName: data['displayName'] ?? '',
          item: data['item'] ?? '',
          documentID: data['documentID'] ?? ''
      );
    }).toList();
  }
  Stream<List<Need>> getNeedList(String docID){
    return needListCollection.doc(docID).collection('Items').snapshots().map(_retrieveNeedItems);
  }

  //Remove item from Need list
  Future removeItemFromNeedList(String tripDocID, String documentID) async {
    try {
      var ref = needListCollection.doc(tripDocID).collection('Items')
          .doc(documentID);
      ref.delete();
    } catch (e) {
      print('Error deleting item from Bringing collection: ${e.toString()}');
    }
  }


  //Get all members from Trip
  Future<List<Members>> retrieveMembers(String docID, bool pubic) async {
    if(pubic) {
      try {
        var ref = await tripsCollectionUnordered.doc(docID).collection(
            'Members').get();
        List<Members> memberList = ref.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Members(
            displayName: data['displayName'] ?? '',
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            urlToImage: data['urlToImage'] ?? '',
          );
        }).toList();
        memberList.sort((a, b) => a.lastName.compareTo(b.lastName));
        return memberList;
      } catch (e) {
        print(e.toString());
        return null;
      }
    } else {
      try {
        var ref = await privateTripsCollectionUnordered.doc(docID).collection(
            'Members').get();
        List<Members> memberList = ref.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Members(
            displayName: data['displayName'] ?? '',
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            urlToImage: data['urlToImage'] ?? '',
          );
        }).toList();
        memberList.sort((a, b) => a.lastName.compareTo(b.lastName));
        return memberList;
      } catch (e) {
        print(e.toString());
        return null;
      }
    }

  }


// Get all trips
  List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
        return Trip(
          accessUsers: List<String>.from(data['accessUsers']) ?? null,
          comment: data['comment'] ?? '',
          dateCreatedTimeStamp: data['dateCreatedTimeStamp'],
          displayName: data['displayName'] ?? '',
          documentId: data['documentId'] ?? '',
          endDate: data['endDate'] ?? '',
          endDateTimeStamp: data['endDateTimeStamp'],
          favorite: List<String>.from(data['favorite']) ?? [''],
          ispublic: data['ispublic'] ?? null,
          location: data['location'] ?? '',
          ownerID: data['ownerID'] ?? '',
          startDate: data['startDate'] ?? '',
          travelType: data['travelType'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
    }).toList();
  }

  // get trips
  Stream<List<Trip>> get trips {
    return tripCollection.snapshots()
        .map(_tripListFromSnapshot);
  }


  Future<List<Trip>> privateTripList() async {
    var ref = await privateTripCollection.where(
        'accessUsers', arrayContainsAny: [uid]).get();
    return ref.docs.map((doc) {
      Map<String, dynamic> data = doc.data();
        return Trip(
          accessUsers: List<String>.from(data['accessUsers']) ?? null,
          comment: data['comment'] ?? '',
          dateCreatedTimeStamp: data['dateCreatedTimeStamp'],
          displayName: data['displayName'] ?? '',
          documentId: data['documentId'] ?? '',
          endDate: data['endDate'] ?? '',
          endDateTimeStamp: data['endDateTimeStamp'],
          favorite: List<String>.from(data['favorite']) ?? [''],
          ispublic: data['ispublic'] ?? null,
          location: data['location'] ?? '',
          ownerID: data['ownerID'] ?? '',
          startDate: data['startDate'] ?? '',
          travelType: data['travelType'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
      }).toList();
  }

  // Add new lodging

  Future addNewLodgingData(String comment, String displayName, String documentID, String link, String lodgingType, String uid, File urlToImage, String tripName) async {

    var key = lodgingCollection.doc().id;
    print(documentID);

    var addNewLodgingRef = lodgingCollection.doc(documentID).collection('lodging').doc(key);
    addNewLodgingRef.set(
      {'comment': comment,
        'displayName': displayName,
        'fieldID': key,
        'link': link,
        'lodgingType' : lodgingType,
        'tripName': tripName,
        'uid': uid,
        'urlToImage': '',
        'vote': 0,
        'voters': [],
    });

    if (urlToImage != null) {
      String urlforImage;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child('lodging/$key');
      StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
      await uploadTask.onComplete;
      print('File Uploaded');

      return await addNewLodgingRef.update({
        "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
          urlforImage = fileURL;
          return urlforImage;
        })
      });
    }
  }

  // Edit Lodging
  Future editLodgingData(String comment, String displayName, String documentID,
      String link, String lodgingType, File urlToImage, String fieldID) async {

    var editLodgingRef = lodgingCollection.doc(documentID).collection('lodging').doc(fieldID);

    try {
      editLodgingRef.update(
          {'comment': comment,
            'displayName': displayName,
            'link': link,
            'lodgingType' : lodgingType,
            'urlToImage': '',


          });
    } catch (e) {
      print('Error editing lodging: ${e.toString()}');
      _analyticsService.writeError('Error editing lodging:  ${e.toString()}');
    }

    try {
      if (urlToImage != null) {
        String urlforImage;
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('lodging/$fieldID');
        StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
        await uploadTask.onComplete;
        print('File Uploaded');

        return await editLodgingRef.update({
          "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      }
    } catch (e) {
      print('Error updating lodging image: ${e.toString()}');
    }
  }


  // Remove Lodging
   removeLodging(String fieldID){
    try {
      return lodgingCollection.doc(tripDocID).collection('lodging').doc(fieldID).delete();
    } catch (e) {
      print('Error deleting lodging: ${e.toString()}');
      _analyticsService.writeError('Error deleting lodging:  ${e.toString()}');
    }
  }

// Add new activity
  Future addNewActivityData(String comment, String displayName, String documentID,
      String link, String activityType, String uid, File urlToImage, String tripName) async {
    var key = activitiesCollection.doc().id;

    var addNewActivityRef = activitiesCollection.doc(documentID).collection('activity').doc(key);

    try {
      addNewActivityRef.set(
      {'comment': comment,
        'displayName': displayName,
        'fieldID': key,
        'link': link,
        'activityType' : activityType,
        'tripName': tripName,
        'uid': uid,
        'urlToImage': '',
        'vote': 0,
        'voters': [],
      });
    } catch (e) {
      print('Error adding new activity: ${e.toString()}');
      _analyticsService.writeError('Error adding new activity:  ${e.toString()}');
    }

    try {
      if (urlToImage != null) {
        String urlforImage;
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('activity/$key');
        StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
        await uploadTask.onComplete;
        print('File Uploaded');

        return await addNewActivityRef.update({
          "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      }
    } catch (e) {
      print('Error updating activity image: ${e.toString()}');
    }
  }

  // Edit activity
  Future editActivityData(String comment, String displayName, String documentID,
      String link, String activityType, File urlToImage, String fieldID) async {

    var addNewActivityRef = activitiesCollection.doc(documentID).collection('activity').doc(fieldID);

    try {
      addNewActivityRef.update(
      {'comment': comment,
        'displayName': displayName,
        'link': link,
        'activityType' : activityType,
        'urlToImage': '',


      });
    } catch (e) {
      print('Error editing activity: ${e.toString()}');
      _analyticsService.writeError('Error editing activity:  ${e.toString()}');
    }

    try {
      if (urlToImage != null) {
        String urlforImage;
        StorageReference storageReference = FirebaseStorage.instance
            .ref()
            .child('activity/$fieldID');
        StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
        await uploadTask.onComplete;
        print('File Uploaded');

        return await addNewActivityRef.update({
          "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      }
    } catch (e) {
      print('Error updating activity image: ${e.toString()}');
    }
  }

  // Remove Activity
   removeActivity(String fieldID){
    try {
      return activitiesCollection.doc(tripDocID).collection('activity').doc(fieldID).delete();
    } catch (e) {
      print('Error deleting activity: ${e.toString()}');
      _analyticsService.writeError('Error removing activity:  ${e.toString()}');
    }
  }
  //Get Activity List
  Stream<List<LodgingData>> get lodgingList {
    return lodgingCollection.doc(tripDocID).collection('lodging').snapshots().map(_lodgingListFromSnapshot);
  }

  List<ActivityData> _activitiesListFromSnapshot(QuerySnapshot snapshot){
    List<ActivityData> activitiesList = snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data();
      return ActivityData(
        comment: data['comment'] ?? '',
        activityType: data['activityType'] ?? '',
        displayName: data['displayName'] ?? '',
        fieldID: data['fieldID'] ?? '',
        link: data['link'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
        vote: data['vote'] ?? 0,
        voters: List<String>.from(data['voters']) ?? [''],
      );
    }).toList();
    activitiesList.sort((a,b) => b.vote.compareTo(a.vote));
    return activitiesList;
  }

  Stream<List<ActivityData>> get activityList {
    return activitiesCollection.doc(tripDocID).collection('activity').snapshots().map(_activitiesListFromSnapshot);
  }

  //Get all users
  List<UserProfile> _userListFromSnapshot(QuerySnapshot snapshot){

    List<UserProfile> userList =  snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data();
      return UserProfile(
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        following: List<String>.from(data['following']) ?? [''],
        followers: List<String>.from(data['followers']) ?? [''],
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );
    }).toList();
    userList.sort((a,b) => a.firstName.compareTo(b.firstName));
    return userList;
  }
  // get all users
  Stream<List<UserProfile>> get userList {
    return userPublicProfileCollection.snapshots()
        .map(_userListFromSnapshot);
  }
  //Get all users Future Builder
  Future<List<UserProfile>> usersList() async {
    try {
      var ref = await userPublicProfileCollection.get();
      List<UserProfile> userList = ref.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return UserProfile(
          displayName: data['displayName'] ?? '',
          email: data['email'] ?? '',
          following: List<String>.from(data['following']) ?? [''],
          followers: List<String>.from(data['followers']) ?? [''],
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          uid: data['uid'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
      }).toList();
      userList.sort((a,b) => a.firstName.compareTo(b.firstName));
      return userList;
    } on Exception catch (e) {
      print(e.toString());
    }
    }


  // Get current user public profile
  UserProfile _userPublicProfileSnapshot(DocumentSnapshot snapshot){
    Map<String, dynamic> data = snapshot.data();
      return UserProfile(
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );

  }

  // get current use public profile
  Stream<UserProfile> get currentUserPublicProfile {
    return userPublicProfileCollection.doc(uid).snapshots()
        .map(_userPublicProfileSnapshot);
  }

  // Get flights
  List<FlightData> _flightListFromSnapshot(DocumentSnapshot snapshot){

    try {
      var list2 = List();
      List<FlightData> listOfFlights = List();

      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data();
        data.forEach((k,v) => list2.add(v));
        
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
      return flightCollection.doc(tripDocID).snapshots().map(_flightListFromSnapshot);
    } catch (e) {
      print('Error Streaming Flights. ${e.toString()}');
    }
  }

  //Get Lodging items
  List<LodgingData> _lodgingListFromSnapshot(QuerySnapshot snapshot){
    List<LodgingData> lodgingList = snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data();
      return LodgingData(
        comment: data['comment'] ?? '',
        lodgingType: data['lodgingType'] ?? '',
        displayName: data['displayName'] ?? '',
        fieldID: data['fieldID'] ?? '',
        link: data['link'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
        vote: data['vote'] ?? 0,
        voters: List<String>.from(data['voters']) ?? [''],
      );
    }).toList();
    lodgingList.sort((a,b) => b.vote.compareTo(a.vote));
    return lodgingList;
  }




  //Query for My Crew Trips
  List<Trip> _crewTripListFromSnapshot(QuerySnapshot snapshot){
    try {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Trip(
          accessUsers: List<String>.from(data['accessUsers']) ?? null,
          comment: data['comment'] ?? '',
          displayName: data['displayName'] ?? '',
          documentId: data['documentId'] ?? '',
          endDate: data['endDate'] ?? '',
          endDateTimeStamp: data['endDateTimeStamp'],
          favorite: List<String>.from(data['favorite']) ?? [''],
          ispublic: data['ispublic'] ?? null,
          location: data['location'] ?? '',
          ownerID: data['ownerID'] ?? '',
          startDate: data['startDate'] ?? '',
          travelType: data['travelType'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
      }).toList();
    } catch (e){
      print(e.toString());
    }
  }
//  endDateTimeStamp: DateFormat.yMd()
//      .format(data['endDateTimeStamp'].toDate()).toString(),
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
      return await tripsCollectionUnordered.doc(tripDocID).update({
        'favorite': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error adding favorite. ${e.toString()}');
    }

  }
  //Remove Favorite Trip
  Future removeFavoriteFromTrip(String uid) async {
    try {
      return await tripsCollectionUnordered.doc(tripDocID).update({
        'favorite': FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error removing favorite. ${e.toString()}');
    }
  }

  //Add and Remove vote for activity
  Future addVoteToActivity(String uid, String fieldID) async {
    try {
      await activitiesCollection.doc(tripDocID).collection('activity').doc(fieldID).update({
        'vote':
        FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await activitiesCollection.doc(tripDocID).collection('activity').doc(fieldID).update({
        'voters':
        FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
  Future removeVoteFromActivity(String uid, String fieldID) async {
    try {
      await activitiesCollection.doc(tripDocID).collection('activity').doc(fieldID).update({
        'vote':
        FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await activitiesCollection.doc(tripDocID).collection('activity').doc(fieldID).update({
        'voters':
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
      await lodgingCollection.doc(tripDocID).collection('lodging').doc(fieldID).update({
        'vote':
        FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await lodgingCollection.doc(tripDocID).collection('lodging').doc(fieldID).update({
        'voters':
        FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
  Future removeVoteFromLodging(String uid, String fieldID) async {
    try {
      await lodgingCollection.doc(tripDocID).collection('lodging').doc(fieldID).update({
        'vote':
        FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await lodgingCollection.doc(tripDocID).collection('lodging').doc(fieldID).update({
        'voters':
        FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }

  // Add new notification
  Future addNewNotificationData(String message, String documentID, String type, String ownerID) async {
    var key = notificationCollection.doc().id;
    try {
      return await notificationCollection.doc(ownerID).collection('notifications').doc(key).set({
        'fieldID': key,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'documentID': documentID,
        'type': type,
        'uid': uid,

      });
    } catch (e) {
      print('Error writing notification: ${e.toString()}');
      _analyticsService.writeError('Error writing notification:  ${e.toString()}');
    }
  }
  // Remove notification
  Future removeNotificationData(String fieldID) async {
    return await notificationCollection.doc(uid).collection('notifications').doc(fieldID).delete();
  }
  // Clear all notifications
  Future removeAllNotificationData() async {
    try {
      return await notificationCollection.doc(uid).collection('notifications').get().then((QuerySnapshot val) => {
        val.docs.forEach((val) => {
          notificationCollection.doc(uid).collection('notifications').doc(val.id).delete()
        })
      });
    } catch (e) {
      print('Error deleting all notificatons: ${e.toString()}');
      _analyticsService.writeError('Error deleting all notifications:  ${e.toString()}');
    }
  }
  // Get all Notifications

  List<NotificationData> _notificationListFromSnapshot(QuerySnapshot snapshot){

    try {
      return snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data();
        return NotificationData(
          documentID: data['documentID'] ?? '',
          fieldID: data['fieldID'] ?? '',
          message: data['message'] ?? '',
          timestamp: data['timestamp'] ?? Timestamp.now(),
          type: data['type'] ?? '',
          uid: data['uid'] ?? '',
        );
      }).toList();
    } catch (e) {
      print('Error retrieving notifications: ${e.toString()}');
    }
  }

  Stream<List<NotificationData>> get notificationList {
    return notificationCollection.doc(uid).collection('notifications').orderBy('timestamp', descending: true).snapshots().map(_notificationListFromSnapshot);
  }


  // Add new chat message
  Future addNewChatMessage(String displayName, String message, String uid, Map status) async {
    var key = chatCollection.doc().id;

    try {
      return await chatCollection.doc(tripDocID).collection('messages').doc(key).set(
          {
            'displayName': displayName,
            'message': message,
            'status': status,
            'timestamp': FieldValue.serverTimestamp(),
            'uid': uid,
          });
    } catch (e) {
      _analyticsService.writeError('Error writing new chat:  ${e.toString()}');
    }
  }
// Clear chat notifications.
  Future clearChatNotifications() async {
    var db = chatCollection.doc(tripDocID).collection('messages').where('status.$uid' ,isEqualTo: false);
    QuerySnapshot snapshot = await db.get();
    for(var i =0; i< snapshot.docs.length;i++) {
      chatCollection.doc(tripDocID).collection('messages').doc(snapshot.docs[i].id).update({'status.$uid': true});
    }
  }

  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot snapshot){

    return snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data();
      return ChatData(
        displayName: data['displayName'] ?? '',
        message: data['message'] ?? '',
        timestamp: data['timestamp'] ?? Timestamp.now(),
        uid: data['uid'] ?? '',
      );
    }).toList();
  }

  Stream<List<ChatData>> get chatList {
    try {
      return chatCollection.doc(tripDocID).collection('messages')
      .orderBy('timestamp', descending: true)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      print("Could not load chat: ${e.toString()}");
    }
  }
  Stream<List<ChatData>> get chatListNotification {
    try {
      return chatCollection.doc(tripDocID).collection('messages').where('status.$uid' ,isEqualTo: false).snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      print("Could not load chat notification list: ${e.toString()}");
    }
  }

}
