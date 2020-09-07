import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:firebase_storage/firebase_storage.dart';


class DatabaseService {

  final String uid;
  var tripDocID;
  DatabaseService({this.tripDocID, this.uid});
  var analytics = FirebaseAnalytics();

  //  All collection references

  final CollectionReference userCollection = Firestore.instance.collection("users");
  final CollectionReference userPublicProfileCollection = Firestore.instance.collection("userPublicProfile");
  final Query allUsersCollection = Firestore.instance.collection("userPublicProfile").orderBy('lastname').orderBy('firstname');
  final Query tripCollection = Firestore.instance.collection("trips").orderBy('endDateTimeStamp').where('ispublic', isEqualTo: true);
  final Query privateTripCollection = Firestore.instance.collection("privateTrips").orderBy('endDateTimeStamp');
  final CollectionReference tripsCollectionUnordered = Firestore.instance.collection("trips");
  final CollectionReference privateTripsCollectionUnordered = Firestore.instance.collection("privateTrips");
  final CollectionReference flightCollection =  Firestore.instance.collection("flights");
  final CollectionReference lodgingCollection =  Firestore.instance.collection("lodging");
  final CollectionReference activitiesCollection =  Firestore.instance.collection("activities");
  final CollectionReference chatCollection =  Firestore.instance.collection("chat");
  final CollectionReference notificationCollection = Firestore.instance.collection('notifications');
  final CollectionReference bringListCollection = Firestore.instance.collection('bringList');
  final CollectionReference needListCollection = Firestore.instance.collection('needList');



  Future updateUserData(String firstname, String lastname, String email, String uid) async {
    return await userCollection.document(uid).setData({
      'firstname': firstname,
      'lastname' : lastname,
      'email': email,
      'uid': uid
    });
  }

  Future<bool> checkUserHasProfile() async {
    var ref = userCollection.document(uid);
    var refSnapshot = await ref.get();

    return refSnapshot.exists;
    }


  Future updateUserPublicProfileData(String displayName, String firstname, String lastname, String email, int tripsCreated, int tripsJoined, String uid, File urlToImage) async {
    var ref = userPublicProfileCollection.document(uid);
     try {
       await ref.setData({
        'displayName': displayName,
        'email': email,
        'firstname': firstname,
        'lastname' : lastname,
        'tripsCreated': tripsCreated,
        'tripsJoined': tripsJoined,
        'uid': uid,
        'urlToImage': ''
           });
     } catch (e) {
       print('Error creating Public: ${e.toString()}');
       analytics.logEvent(name: 'write_error',parameters:
         {'name': 'updateUserPublicProfileData',
         'description': e.toString(),
       });
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
         
         return await ref.updateData({
           'urlToImage': await storageReference.getDownloadURL().then((fileURL) {
             urlforImage = fileURL;
             return urlforImage;
           })
         });
       } catch (e) {
        print('Error updating with image url: ${e.toString()}');
       }
     }
  }

  // Edit Public Profile page
  Future editPublicProfileData(String displayName, String firstname, String lastname, File urlToImage) async {
    var ref = userPublicProfileCollection.document(uid);
    try {
      await ref.updateData({
        'displayName': displayName,
        'firstname': firstname,
        'lastname' : lastname,
      });
    } catch (e) {
      print('Error editing Public Profile: ${e.toString()}');
      analytics.logEvent(name: 'write_error',parameters:
      {'name': 'editPublicProfileData',
        'description': e.toString(),
      });
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

        return await ref.updateData({
          'urlToImage': await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      } catch (e) {
        print('Error updating with image url: ${e.toString()}');
        analytics.logEvent(name: 'write_error',parameters:
        {'name': 'editPublicProfileData',
          'description': e.toString(),
        });
      }
    }
  }

// Get user display name.
  Future<UserPublicProfile> retrieveUserPublicProfile(String uid) async {
     var ref = await userPublicProfileCollection.document(uid).get();
     if(ref.exists){
       return UserPublicProfile(
         displayName: ref.data['displayName'],
         firstname: ref.data['firstname'],
         lastname: ref.data['lastname'],
         urlToImage: ref.data['urlToImage'],
       );
     } else {
       return null;
     }
  }
  Future<String> retrieveUserPic(String uid) async {
    var ref = await userPublicProfileCollection.document(uid).get();
    String profilePic = await ref.data['urlToImage'];
    return profilePic;
  }

  //Follow a user
  Future followUser(String userUID) async {
     userPublicProfileCollection.document(uid).updateData({
      'following': FieldValue.arrayUnion([userUID]),
    });
     userPublicProfileCollection.document(userUID).updateData({
       'followers': FieldValue.arrayUnion([uid]),
     });
  }

  //Un-Follow a user
  Future unFollowUser(String userUID) async {
    userPublicProfileCollection.document(uid).updateData({
      'following': FieldValue.arrayRemove([userUID]),
    });
    userPublicProfileCollection.document(userUID).updateData({
      'followers': FieldValue.arrayRemove([uid]),
    });
  }

  // Get following list
  Future<List<UserProfile>> retrieveFollowingList() async {
    List<UserProfile> followingList;
    UserProfile followingListUID;
    try {
      await userPublicProfileCollection.document(uid).get().then((value) => {
        if(value.exists) {
          followingListUID = UserProfile(
            following: List<String>.from(value.data['following']) ?? [''],
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
      await tripsCollectionUnordered.document(tripDocID).updateData({
        'accessUsers': FieldValue.arrayUnion([uid]),
      }).then((value) =>
      {
        retrieveUserPublicProfile(uid).then((value) =>
        {
          tripsCollectionUnordered.document(tripDocID)
              .collection('Members')
              .document(uid)
              .setData({
            'displayName': value.displayName ?? '',
            'firstname': value.firstname ?? '',
            'lastname': value.lastname ?? '',
            'uid': uid,
            'urlToImage': value.urlToImage ?? '',
          })
        })
      });
    } catch(e){
      print('Error joining trip: ${e.toString()}');
    }

     await userPublicProfileCollection.document(uid).updateData({
       "tripsJoined": FieldValue.increment(1),
     });

  }


  // Leave Trip
  Future leaveTrip() async {

     tripsCollectionUnordered.document(tripDocID).updateData({
      'accessUsers': FieldValue.arrayRemove([uid]),
    });
     tripsCollectionUnordered.document(tripDocID).collection('Members').document(uid).delete();

     userCollection.document(uid).updateData({
      'accessTrips': FieldValue.arrayRemove([tripDocID]),
    });
     userPublicProfileCollection.document(uid).updateData({
      "tripsJoined": FieldValue.increment(-1),
    });
  }
  // Add new trip
  Future addNewTripData(List<String> accessUsers, String comment, String displayName,
      String endDate, String firstname, String lastname, Timestamp endDateTimeStamp, Timestamp startDateTimeStamp, bool ispublic, String location, String ownerID,
      String startDate, String travelType, File urlToImage)

  async {
    var key = tripsCollectionUnordered.document().documentID;
    if (ispublic) {
      var addTripRef =  tripsCollectionUnordered.document(key);
      try {
         addTripRef.setData(
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

      } catch (e){
        print("Error saving trip: ${e.toString()}");
      }
      try {
         addTripRef.collection('Members').document(ownerID).setData({
           'displayName' : displayName,
           'firstname': firstname,
           'lastname' : lastname,
           'uid' : ownerID,
           'urlToImage' : '',
         });
      } catch(e){
        print(e.toString());
      }

    } else {
      var addTripRef = privateTripsCollectionUnordered.document(key);
      try {
         addTripRef.setData({
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
      }
      catch (e) {
        print("Error saving private trip: ${e.toString()}");
      }
      try {
        addTripRef.collection('Members').document(ownerID).setData({
          'displayName' : displayName,
          'firstname': firstname,
          'lastname' : lastname,
          'uid' : ownerID,
          'urlToImage' : '',
        });
      } catch(e){
        print(e.toString());
      }
    }

    try {
      await flightCollection.document(key).setData({});
    }catch (e) {
      print('Error adding Flight: ${e.toString()}');
    }

    try {
      await userCollection.document(ownerID).updateData({'trips': FieldValue.arrayUnion([key])});
    }catch (e) {
      print('Error adding new trip to user document: ${e.toString()}');
    }
//     await addTripRef.updateData({"documentId": addTripRef.documentID});

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

          return await tripsCollectionUnordered.document(key).updateData({
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

          return await privateTripsCollectionUnordered.document(key).updateData({
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
        var addTripRef = await tripsCollectionUnordered.document(trip.documentId).setData(
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
           privateTripsCollectionUnordered.document(trip.documentId).delete();
        } catch (e){
          print("Error deleting private trip: ${e.toString()}");
        }
      } catch (e) {
        print("Error saving trip: ${e.toString()}");
      }
    } else {
      try {
        var addTripRef = await privateTripsCollectionUnordered.document(trip.documentId)
            .setData({
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
           tripsCollectionUnordered.document(trip.documentId).delete();
        } catch (e){
          print("Error deleting public trip: ${e.toString()}");
        }
      }
      catch (e) {
        print("Error saving private trip: ${e.toString()}");
      }
    }
  }
// Delete trip
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
    try {
      await privateTripsCollectionUnordered.document(tripDocID).delete();
    }catch (e) {
      print('Error deleting Trip: ${e.toString()}');
    }
  }
  // Update trip with new field
  Future updateTrip(String documentID) async {
    var updateTripRef = tripsCollectionUnordered.document(documentID);
    await updateTripRef.updateData({
      'dateCreatedTimeStamp': FieldValue.serverTimestamp()
    });
  }


// Edit Trip
  Future editTripData(String comment, String documentID, String endDate, Timestamp endDateTimeStamp,
      bool ispublic, String location, String startDate, String travelType, File urlToImage)

  async {
    var addTripRef = ispublic ? tripsCollectionUnordered.document(documentID) : privateTripsCollectionUnordered.document(documentID);


    await addTripRef.updateData({
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

  //Add items the user is Bringing
  Future addItemToBringingList(String tripDocID, String item, String displayName) async {
    String key = bringListCollection.document().documentID;
    try {
      var ref = bringListCollection.document(tripDocID).collection('Items')
          .document(key);
      ref.setData({
        'item': item,
        'displayName': displayName,
        'documentID': key
      });
    } catch (e) {
      print('Error saving item to Bringing collection: ${e.toString()}');
    }
  }

  List<Bringing> _retrieveBringingItems(QuerySnapshot snapshot) {
        return snapshot.documents.map((doc) {
            return Bringing(
            displayName: doc.data['displayName'] ?? '',
            item: doc.data['item'] ?? '',
            documentID: doc.data['documentID'] ?? ''
        );
      }).toList();
  }
  Stream<List<Bringing>> getBringingList(String docID){
    return bringListCollection.document(docID).collection('Items').snapshots().map(_retrieveBringingItems);
  }

  //Remove item from Bring list
  Future removeItemFromBringingList(String tripDocID, String documentID) async {
    try {
      var ref = bringListCollection.document(tripDocID).collection('Items')
          .document(documentID);
      ref.delete();
    } catch (e) {
      print('Error deleting item from Bringing collection: ${e.toString()}');
    }
  }

  //Create a list of items user wants others to bring
  Future addItemToNeedList(String docID, String item, String displayName) async {
    String key = needListCollection.document().documentID;
    try {
      var ref = needListCollection.document(docID).collection('Items')
          .document(key);
      ref.setData({
        'item': item,
        'displayName': displayName,
        'documentID': key
      });
    } catch (e) {
      print('Error saving item to Need collection: ${e.toString()}');
    }
  }

  List<Need> _retrieveNeedItems(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return Need(
          displayName: doc.data['displayName'] ?? '',
          item: doc.data['item'] ?? '',
          documentID: doc.data['documentID'] ?? ''
      );
    }).toList();
  }
  Stream<List<Need>> getNeedList(String docID){
    return needListCollection.document(docID).collection('Items').snapshots().map(_retrieveNeedItems);
  }

  //Remove item from Need list
  Future removeItemFromNeedList(String tripDocID, String documentID) async {
    try {
      var ref = needListCollection.document(tripDocID).collection('Items')
          .document(documentID);
      ref.delete();
    } catch (e) {
      print('Error deleting item from Bringing collection: ${e.toString()}');
    }
  }


  //Get all members from Trip
  Future<List<Members>> retrieveMembers(String docID, bool pubic) async {
    if(pubic) {
      try {
        var ref = await tripsCollectionUnordered.document(docID).collection(
            'Members').getDocuments();
        List<Members> memberList = ref.documents.map((doc) {
          return Members(
            displayName: doc.data['displayName'] ?? '',
            firstname: doc.data['firstname'] ?? '',
            lastname: doc.data['lastname'] ?? '',
            urlToImage: doc.data['urlToImage'] ?? '',
          );
        }).toList();
        memberList.sort((a, b) => a.lastname.compareTo(b.lastname));
        return memberList;
      } catch (e) {
        print(e.toString());
        return null;
      }
    } else {
      try {
        var ref = await privateTripsCollectionUnordered.document(docID).collection(
            'Members').getDocuments();
        List<Members> memberList = ref.documents.map((doc) {
          return Members(
            displayName: doc.data['displayName'] ?? '',
            firstname: doc.data['firstname'] ?? '',
            lastname: doc.data['lastname'] ?? '',
            urlToImage: doc.data['urlToImage'] ?? '',
          );
        }).toList();
        memberList.sort((a, b) => a.lastname.compareTo(b.lastname));
        return memberList;
      } catch (e) {
        print(e.toString());
        return null;
      }
    }

  }


// Get all trips
  List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {

    return snapshot.documents.map((doc) {
        return Trip(
          accessUsers: List<String>.from(doc.data['accessUsers']) ?? null,
          comment: doc.data['comment'] ?? '',
          dateCreatedTimeStamp: doc.data['dateCreatedTimeStamp'],
          displayName: doc.data['displayName'] ?? '',
          documentId: doc.data['documentId'] ?? '',
          endDate: doc.data['endDate'] ?? '',
          endDateTimeStamp: doc.data['endDateTimeStamp'],
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


  Future<List<Trip>> privateTripList() async {
    var ref = await privateTripCollection.where(
        'accessUsers', arrayContainsAny: [uid]).getDocuments();
    return ref.documents.map((doc) {
        return Trip(
          accessUsers: List<String>.from(doc.data['accessUsers']) ?? null,
          comment: doc.data['comment'] ?? '',
          dateCreatedTimeStamp: doc.data['dateCreatedTimeStamp'],
          displayName: doc.data['displayName'] ?? '',
          documentId: doc.data['documentId'] ?? '',
          endDate: doc.data['endDate'] ?? '',
          endDateTimeStamp: doc.data['endDateTimeStamp'],
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

  // Add new lodging

  Future addNewLodgingData(String comment, String displayName, String documentID, String link, String lodgingType, String uid, File urlToImage, String tripName) async {

    var key = lodgingCollection.document().documentID;
    print(documentID);

    var addNewLodgingRef = lodgingCollection.document(documentID).collection('lodging').document(key);
    addNewLodgingRef.setData(
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

      return await addNewLodgingRef.updateData({
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

    var editLodgingRef = lodgingCollection.document(documentID).collection('lodging').document(fieldID);

    try {
      editLodgingRef.updateData(
          {'comment': comment,
            'displayName': displayName,
            'link': link,
            'lodgingType' : lodgingType,
            'urlToImage': '',


          });
    } catch (e) {
      print('Error editing lodging: ${e.toString()}');
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

        return await editLodgingRef.updateData({
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
  Future removeLodging(String fieldID){
    try {
      return lodgingCollection.document(tripDocID).collection('lodging').document(fieldID).delete();
    } catch (e) {
      print('Error deleting activity: ${e.toString()}');
    }
  }

// Add new activity
  Future addNewActivityData(String comment, String displayName, String documentID,
      String link, String activityType, String uid, File urlToImage, String tripName) async {
    var key = activitiesCollection.document().documentID;

    var addNewActivityRef = activitiesCollection.document(documentID).collection('activity').document(key);

    try {
      addNewActivityRef.setData(
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

        return await addNewActivityRef.updateData({
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

    var addNewActivityRef = activitiesCollection.document(documentID).collection('activity').document(fieldID);

    try {
      addNewActivityRef.updateData(
      {'comment': comment,
        'displayName': displayName,
        'link': link,
        'activityType' : activityType,
        'urlToImage': '',


      });
    } catch (e) {
      print('Error editing activity: ${e.toString()}');
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

        return await addNewActivityRef.updateData({
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
  Future removeActivity(String fieldID){
    try {
      return activitiesCollection.document(tripDocID).collection('activity').document(fieldID).delete();
    } catch (e) {
      print('Error deleting activity: ${e.toString()}');
    }
  }
  //Get Activity List
  Stream<List<LodgingData>> get lodgingList {
    return lodgingCollection.document(tripDocID).collection('lodging').snapshots().map(_lodgingListFromSnapshot);
  }

  List<ActivityData> _activitiesListFromSnapshot(QuerySnapshot snapshot){
    List<ActivityData> activitiesList = snapshot.documents.map((doc){
      return ActivityData(
        comment: doc.data['comment'] ?? '',
        activityType: doc.data['activityType'] ?? '',
        displayName: doc.data['displayName'] ?? '',
        fieldID: doc.data['fieldID'] ?? '',
        link: doc.data['link'] ?? '',
        uid: doc.data['uid'] ?? '',
        urlToImage: doc.data['urlToImage'] ?? '',
        vote: doc.data['vote'] ?? 0,
        voters: List<String>.from(doc.data['voters']) ?? [''],
      );
    }).toList();
    activitiesList.sort((a,b) => b.vote.compareTo(a.vote));
    return activitiesList;
  }

  Stream<List<ActivityData>> get activityList {
    return activitiesCollection.document(tripDocID).collection('activity').snapshots().map(_activitiesListFromSnapshot);
  }

  //Get all users
  List<UserProfile> _userListFromSnapshot(QuerySnapshot snapshot){
    List<UserProfile> userList =  snapshot.documents.map((doc){
      return UserProfile(
        displayName: doc.data['displayName'] ?? '',
        email: doc.data['email'] ?? '',
        following: List<String>.from(doc.data['following']) ?? [''],
        followers: List<String>.from(doc.data['followers']) ?? [''],
        firstName: doc.data['firstName'] ?? '',
        lastName: doc.data['lastName'] ?? '',
        uid: doc.data['uid'] ?? '',
        urlToImage: doc.data['urlToImage'] ?? '',
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
      var ref = await userPublicProfileCollection.getDocuments();
      List<UserProfile> userList = ref.documents.map((doc) {
        return UserProfile(
          displayName: doc.data['displayName'] ?? '',
          email: doc.data['email'] ?? '',
          following: List<String>.from(doc.data['following']) ?? [''],
          followers: List<String>.from(doc.data['followers']) ?? [''],
          firstName: doc.data['firstName'] ?? '',
          lastName: doc.data['lastName'] ?? '',
          uid: doc.data['uid'] ?? '',
          urlToImage: doc.data['urlToImage'] ?? '',
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
    var data = snapshot.data;
      return UserProfile(
        displayName: data['displayName'] ?? '',
        email: data['email'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
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
  List<LodgingData> _lodgingListFromSnapshot(QuerySnapshot snapshot){
    List<LodgingData> lodgingList = snapshot.documents.map((doc){
      return LodgingData(
        comment: doc.data['comment'] ?? '',
        lodgingType: doc.data['lodgingType'] ?? '',
        displayName: doc.data['displayName'] ?? '',
        fieldID: doc.data['fieldID'] ?? '',
        link: doc.data['link'] ?? '',
        uid: doc.data['uid'] ?? '',
        urlToImage: doc.data['urlToImage'] ?? '',
        vote: doc.data['vote'] ?? 0,
        voters: List<String>.from(doc.data['voters']) ?? [''],
      );
    }).toList();
    lodgingList.sort((a,b) => b.vote.compareTo(a.vote));
    return lodgingList;
  }




  //Query for My Crew Trips
  List<Trip> _crewTripListFromSnapshot(QuerySnapshot snapshot){
    try {
      return snapshot.documents.map((doc) {
        return Trip(
          accessUsers: List<String>.from(doc.data['accessUsers']) ?? null,
          comment: doc.data['comment'] ?? '',
          displayName: doc.data['displayName'] ?? '',
          documentId: doc.data['documentId'] ?? '',
          endDate: doc.data['endDate'] ?? '',
          endDateTimeStamp: doc.data['endDateTimeStamp'],
          favorite: List<String>.from(doc.data['favorite']) ?? [''],
          ispublic: doc.data['ispublic'] ?? null,
          location: doc.data['location'] ?? '',
          ownerID: doc.data['ownerID'] ?? '',
          startDate: doc.data['startDate'] ?? '',
          travelType: doc.data['travelType'] ?? '',
          urlToImage: doc.data['urlToImage'] ?? '',
        );
      }).toList();
    } catch (e){
      print(e.toString());
    }
  }
//  endDateTimeStamp: DateFormat.yMd()
//      .format(doc.data['endDateTimeStamp'].toDate()).toString(),
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
      await activitiesCollection.document(tripDocID).collection('activity').document(fieldID).updateData({
        'vote':
        FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await activitiesCollection.document(tripDocID).collection('activity').document(fieldID).updateData({
        'voters':
        FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
  Future removeVoteFromActivity(String uid, String fieldID) async {
    try {
      await activitiesCollection.document(tripDocID).collection('activity').document(fieldID).updateData({
        'vote':
        FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await activitiesCollection.document(tripDocID).collection('activity').document(fieldID).updateData({
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
      await lodgingCollection.document(tripDocID).collection('lodging').document(fieldID).updateData({
        'vote':
        FieldValue.increment(1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await lodgingCollection.document(tripDocID).collection('lodging').document(fieldID).updateData({
        'voters':
        FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
    }
  }
  Future removeVoteFromLodging(String uid, String fieldID) async {
    try {
      await lodgingCollection.document(tripDocID).collection('lodging').document(fieldID).updateData({
        'vote':
        FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error updating vote count. ${e.toString()}');
    }
    try {
      return await lodgingCollection.document(tripDocID).collection('lodging').document(fieldID).updateData({
        'voters':
        FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      print('Error updating voters. ${e.toString()}');
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
  // Clear all notifications
  Future removeAllNotificationData() async {
    try {
      return await notificationCollection.document(uid).collection('notifications').getDocuments().then((QuerySnapshot val) => {
        val.documents.forEach((val) => {
          notificationCollection.document(uid).collection('notifications').document(val.documentID).delete()
        })
      });
    } catch (e) {
      print('Error deleting all notificatons: ${e.toString()}');
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
    return notificationCollection.document(uid).collection('notifications').orderBy('timestamp', descending: true).snapshots().map(_notificationListFromSnapshot);
  }


  // Add new chat message
  Future addNewChatMessage(String displayName, String message, String uid, Map status) async {
    var key = chatCollection.document().documentID;

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
    var db = chatCollection.document(tripDocID).collection('messages').where('status.$uid' ,isEqualTo: false);
    QuerySnapshot snapshot = await db.getDocuments();
    for(var i =0; i< snapshot.documents.length;i++) {
      chatCollection.document(tripDocID).collection('messages').document(snapshot.documents[i].documentID).updateData({'status.$uid': true});
    }
  }

  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot snapshot){

    return snapshot.documents.map((doc){

      return ChatData(
        displayName: doc.data['displayName'] ?? '',
        message: doc.data['message'] ?? '',
        timestamp: doc.data['timestamp'] ?? Timestamp.now(),
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
      return chatCollection.document(tripDocID).collection('messages').where('status.$uid' ,isEqualTo: false).snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      print("Could not load chat notification list: ${e.toString()}");
    }
  }

}
