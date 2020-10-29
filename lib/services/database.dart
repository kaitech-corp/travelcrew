import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/locator.dart';
import 'analytics_service.dart';

var userService = locator<UserService>();
var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

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
  final CollectionReference uniqueCollection = FirebaseFirestore.instance.collection('unique');
  final CollectionReference feedbackCollection = FirebaseFirestore.instance.collection('feedback');
  final CollectionReference reportsCollection = FirebaseFirestore.instance.collection('reports');
  final CollectionReference adsCollection = FirebaseFirestore.instance.collection('tripAds');





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
        'blockedList': [],
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


  // Add new trip
  Future addNewTripData(List<String> accessUsers, String comment,
      String endDate, String firstName, String lastName, Timestamp endDateTimeStamp, Timestamp startDateTimeStamp, bool ispublic, String location,
      String startDate, String travelType, File urlToImage, GeoPoint geoPoint, String tripName)
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
              'displayName': currentUserProfile.displayName,
              'documentId': key,
              'endDate': endDate,
              'endDateTimeStamp': endDateTimeStamp,
              'ispublic': ispublic,
              'location': location,
              'ownerID': userService.currentUserID,
              'startDate': startDate,
              'startDateTimeStamp': startDateTimeStamp,
              'tripName': tripName,
              'tripGeoPoint': geoPoint,
              'travelType': travelType,
              'urlToImage': '',
            });

         _analyticsService.createTrip(true);
      } catch (e){
        print("Error saving trip: ${e.toString()}");
        _analyticsService.writeError('Error saving new public trip:  ${e.toString()}');
      }
      try {
         addTripRef.collection('Members').doc(userService.currentUserID).set({
           'displayName' : currentUserProfile.displayName,
           'firstName': firstName,
           'lastname' : lastName,
           'uid' : userService.currentUserID,
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
          'displayName': currentUserProfile.displayName,
          'documentId': key,
          'endDate': endDate,
          'endDateTimeStamp': endDateTimeStamp,
          'ispublic': ispublic,
          'location': location,
          'ownerID': userService.currentUserID,
          'startDate': startDate,
           'startDateTimeStamp': startDateTimeStamp,
           'tripName': tripName,
           'tripGeoPoint': geoPoint,
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
        addTripRef.collection('Members').doc(userService.currentUserID).set({
          'displayName' : currentUserProfile.displayName,
          'firstName': firstName,
          'lastName' : lastName,
          'uid' : userService.currentUserID,
          'urlToImage' : '',
        });
      } catch(e){
        print(e.toString());
      }
    }

    try {
      await userCollection.doc(userService.currentUserID).update({'trips': FieldValue.arrayUnion([key])});
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
              'tripName': trip.tripName,
              'tripGeoPoint': trip.tripGeoPoint,
              'travelType': trip.travelType,
              'urlToImage': trip.urlToImage,
            });
        try {
           privateTripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          print("Error deleting private trip: ${e.toString()}");
        }
        trip.accessUsers.forEach((member) {
          CloudFunction().addMember(trip.documentId, member);
        });
      } catch (e) {

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
          'tripName': trip.tripName,
          'tripGeoPoint': trip.tripGeoPoint,
          'travelType': trip.travelType,
          'urlToImage': trip.urlToImage,
        });
        try {
           tripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          print("Error deleting public trip: ${e.toString()}");
        }
        trip.accessUsers.forEach((member) {
          CloudFunction().addPrivateMember(trip.documentId, member);
        });
      }
      catch (e) {
        print("Error saving private trip: ${e.toString()}");
        _analyticsService.writeError('Error converting to private trip:  ${e.toString()}');
      }
    }
  }


// Edit Trip
  Future editTripData(
      String comment,
      String documentID,
      String endDate,
      Timestamp endDateTimeStamp,
      bool ispublic,
      String location,
      String startDate,
      Timestamp startDateTimeStamp,
      String travelType,
      File urlToImage,
      String tripName,
      GeoPoint tripGeoPoint)
  async {
    var addTripRef = ispublic ? tripsCollectionUnordered.doc(documentID) : privateTripsCollectionUnordered.doc(documentID);


    await addTripRef.update({
      "comment": comment,
      "endDate": endDate,
      "endDateTimeStamp": endDateTimeStamp,
      "ispublic": ispublic,
      "location": location,
      "startDate": startDate,
      'startDateTimeStamp': startDateTimeStamp,
      'tripName': tripName,
      'tripGeoPoint': tripGeoPoint,
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

  // Get following list
  Stream<List<UserProfile>> retrieveFollowingList() async*{
      var user = await usersList();
      var followingList =
          user.where((user) => currentUserProfile.following.contains(user.uid)).toList();

    yield followingList;
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

  //Get all members from Trip
  Future<List<Members>> retrieveMembers(String docID, bool ispubic) async {
    if(ispubic) {
      try {
        var ref = await tripsCollectionUnordered.doc(docID).collection(
            'Members').get();
        List<Members> memberList = ref.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return Members(
            displayName: data['displayName'] ?? '',
            firstName: data['firstName'] ?? '',
            lastName: data['lastName'] ?? '',
            uid: data['uid'] ?? '',
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
              uid: data['uid'] ?? '',
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

  // Get Trip
  Future<Trip> getTrip(String documentID) async {

    var ref = await tripsCollectionUnordered.doc(documentID).get();
    if (ref.exists){
        Map<String, dynamic> data = ref.data();
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
          startDateTimeStamp: data['startDateTimeStamp'],
          tripGeoPoint: data['tripGeoPoint'] ?? null,
          tripName: data['tripName'] ?? '',
          travelType: data['travelType'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
    }
  }
  // Get Private Trip
  Future<Trip> getPrivateTrip(String documentID) async {

    var ref = await privateTripsCollectionUnordered.doc(documentID).get();
    if (ref.exists){
      Map<String, dynamic> data = ref.data();
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
        startDateTimeStamp: data['startDateTimeStamp'],
        tripGeoPoint: data['tripGeoPoint'] ?? null,
        tripName: data['tripName'] ?? '',
        travelType: data['travelType'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );
    }
  }

// Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {

    List<Trip> trips = snapshot.docs.map((doc) {
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
        startDateTimeStamp: data['startDateTimeStamp'],
        tripGeoPoint: data['tripGeoPoint'] ?? null,
        tripName: data['tripName'] ?? '',
        travelType: data['travelType'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
      );
    }).toList();
    trips.sort((a,b) => a.startDateTimeStamp.compareTo(b.startDateTimeStamp));

    return trips;
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
          startDateTimeStamp: data['startDateTimeStamp'],
          tripGeoPoint: data['tripGeoPoint'] ?? null,
          tripName: data['tripName'] ?? '',
          travelType: data['travelType'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
      }).toList();
  }

  // Add new lodging

  Future addNewLodgingData(String comment, String displayName, String documentID,
      String link, String lodgingType, String uid, File urlToImage, String tripName,
      String startTime, String endTime) async {

    var key = lodgingCollection.doc().id;
    print(documentID);

    var addNewLodgingRef = lodgingCollection.doc(documentID).collection('lodging').doc(key);
    addNewLodgingRef.set(
      {'comment': comment,
        'displayName': displayName,
        'endTime': endTime,
        'fieldID': key,
        'link': link,
        'lodgingType' : lodgingType,
        'tripName': tripName,
        'startTime': startTime,
        'uid': uid,
        'urlToImage': '',
        'voters': [],
    });

    // if (urlToImage != null) {
    //   String urlforImage;
    //   StorageReference storageReference = FirebaseStorage.instance
    //       .ref()
    //       .child('lodging/$key');
    //   StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
    //   await uploadTask.onComplete;
    //   print('File Uploaded');
    //
    //   return await addNewLodgingRef.update({
    //     "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
    //       urlforImage = fileURL;
    //       return urlforImage;
    //     })
    //   });
    // }
  }

  // Edit Lodging
  Future editLodgingData(String comment, String displayName, String documentID,
      String link, String lodgingType, File urlToImage, String fieldID,
      String startTime, String endTime) async {

    var editLodgingRef = lodgingCollection.doc(documentID).collection('lodging').doc(fieldID);

    try {
      editLodgingRef.update(
          {'comment': comment,
            'displayName': displayName,
            'link': link,
            'lodgingType' : lodgingType,
            'urlToImage': '',
            'startTime': startTime,
            'endTime': endTime,

          });
    } catch (e) {
      print('Error editing lodging: ${e.toString()}');
      _analyticsService.writeError('Error editing lodging:  ${e.toString()}');
    }

    // try {
    //   if (urlToImage != null) {
    //     String urlforImage;
    //     StorageReference storageReference = FirebaseStorage.instance
    //         .ref()
    //         .child('lodging/$fieldID');
    //     StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
    //     await uploadTask.onComplete;
    //     print('File Uploaded');
    //
    //     return await editLodgingRef.update({
    //       "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
    //         urlforImage = fileURL;
    //         return urlforImage;
    //       })
    //     });
    //   }
    // } catch (e) {
    //   print('Error updating lodging image: ${e.toString()}');
    // }
  }


// Add new activity
  Future addNewActivityData(String comment, String displayName, String documentID,
      String link, String activityType, String uid, File urlToImage, String tripName,
      String startTime, String endTime) async {
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
        'voters': [],
        'startTime': startTime,
        'endTime': endTime,
      });
    } catch (e) {
      print('Error adding new activity: ${e.toString()}');
      _analyticsService.writeError('Error adding new activity:  ${e.toString()}');
    }

    // try {
    //   if (urlToImage != null) {
    //     String urlforImage;
    //     StorageReference storageReference = FirebaseStorage.instance
    //         .ref()
    //         .child('activity/$key');
    //     StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
    //     await uploadTask.onComplete;
    //     print('File Uploaded');
    //
    //     return await addNewActivityRef.update({
    //       "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
    //         urlforImage = fileURL;
    //         return urlforImage;
    //       })
    //     });
    //   }
    // } catch (e) {
    //   print('Error updating activity image: ${e.toString()}');
    // }
  }

  // Edit activity
  Future editActivityData(String comment, String displayName, String documentID,
      String link, String activityType, File urlToImage, String fieldID,
      String startTime, String endTime) async {

    var addNewActivityRef = activitiesCollection.doc(documentID).collection('activity').doc(fieldID);

    try {
      addNewActivityRef.update(
      {'comment': comment,
        'displayName': displayName,
        'link': link,
        'activityType' : activityType,
        'urlToImage': '',
        'startTime': startTime,
        'endTime': endTime,

      });
    } catch (e) {
      print('Error editing activity: ${e.toString()}');
      _analyticsService.writeError('Error editing activity:  ${e.toString()}');
    }

    // try {
    //   if (urlToImage != null) {
    //     String urlforImage;
    //     StorageReference storageReference = FirebaseStorage.instance
    //         .ref()
    //         .child('activity/$fieldID');
    //     StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
    //     await uploadTask.onComplete;
    //     print('File Uploaded');
    //
    //     return await addNewActivityRef.update({
    //       "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
    //         urlforImage = fileURL;
    //         return urlforImage;
    //       })
    //     });
    //   }
    // } catch (e) {
    //   print('Error updating activity image: ${e.toString()}');
    // }
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
        endTime: data['endTime'] ?? '',
        startTime: data['startTime'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
        voters: List<String>.from(data['voters']) ?? [''],
      );
    }).toList();
    lodgingList.sort((a,b) => b.voters.length.compareTo(a.voters.length));
    return lodgingList;
  }
  //Get Lodging List
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
        endTime: data['endTime'] ?? '',
        startTime: data['startTime'] ?? '',
        link: data['link'] ?? '',
        uid: data['uid'] ?? '',
        urlToImage: data['urlToImage'] ?? '',
        voters: List<String>.from(data['voters']) ?? [''],
      );
    }).toList();
    activitiesList.sort((a,b) => b.voters.length.compareTo(a.voters.length));
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
    return userPublicProfileCollection.doc(userService.currentUserID).snapshots()
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
          startDateTimeStamp: data['startDateTimeStamp'],
          tripGeoPoint: data['tripGeoPoint'] ?? null,
          tripName: data['tripName'] ?? '',
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
    return tripCollection.where('favorite', arrayContainsAny: [userService.currentUserID]).snapshots()
        .map(_tripListFromSnapshot);
  }

// check uniqueness
  Future addToUniqueDocs(String key2){
    try {
      uniqueCollection.doc(key2).set({
      });
    } catch(e){
      print(e.toString());
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
          ispublic: data['ispublic'] ?? false,
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
    return notificationCollection.doc(userService.currentUserID).collection('notifications').orderBy('timestamp', descending: true).snapshots().map(_notificationListFromSnapshot);
  }


  // Add new chat message
  Future addNewChatMessage(String displayName, String message, String uid, Map status) async {
    var key = chatCollection.doc().id;

    try {
      return await chatCollection.doc(tripDocID).collection('messages').doc(key).set(
          {
            'displayName': displayName,
            'fieldID': key,
            'message': message,
            'status': status,
            'timestamp': FieldValue.serverTimestamp(),
            'uid': uid,
          });
    } catch (e) {
      _analyticsService.writeError('Error writing new chat:  ${e.toString()}');
    }
  }
  // Delete a chat message
  Future deleteChatMessage(String fieldID, String tripDocID) async {
    try {
      return await chatCollection.doc(tripDocID).collection('messages').doc(fieldID).delete();
    } catch (e) {
      _analyticsService.writeError('Error deleting new chat:  ${e.toString()}');
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

    try {
      return snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data();
        return ChatData(
          displayName: data['displayName'] ?? '',
          fieldID: data['fieldID'] ?? '',
          message: data['message'] ?? '',
          timestamp: data['timestamp'] ?? Timestamp.now(),
          uid: data['uid'] ?? '',
        );
      }).toList();
    } catch (e) {
      // AnalyticsService().writeError(e.toString());
      print("Error: ${e.toString()}");
    }
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
      return chatCollection.doc(tripDocID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false).snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      print("Could not load chat notification list: ${e.toString()}");
    }
  }


  Future<List<TCFeedback>> feedback() async {
    try {
      var ref = await feedbackCollection.get();
      List<TCFeedback> feedback = ref.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return TCFeedback(
            fieldID: data['fieldID'] ?? '',
            message: data['message'] ?? '',
            uid: data['uid'] ?? '',
            timestamp: data['timestamp'] ?? null,
          );
        }).toList();
      feedback.sort((a,b) => a.timestamp.compareTo(b.timestamp));

      return feedback;
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<List<TCReports>> reports() async {
  //   try {
  //     var ref = await reportsCollection.get();
  //     List<TCFeedback> feedback = ref.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data();
  //       return TCFeedback(
  //         message: data['message'] ?? '',
  //         uid: data['uid'] ?? '',
  //         timestamp: data['timestamp'] ?? null,
  //       );
  //     }).toList();
  //     feedback.sort((a,b) => a.timestamp.compareTo(b.timestamp));
  //
  //     return feedback;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  // Get all Ads
  List<TripAds> _adListFromSnapshot(QuerySnapshot snapshot){

      return snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data();
        return TripAds(
          tripName: data['tripName'] ?? '',
          documentID: data['documentID'] ?? '',
          link: data['link'] ?? '',
          location: data['location'] ?? '',
          dateCreated: data['dateCreated'] ?? null,
          clicks: data['clicks'] ?? 0,
          favorites: List<String>.from(data['favorites']) ?? null,
          clickers: List<String>.from(data['clickers']) ?? null,
          urlToImage: data['urlToImage'] ?? '',
        );
      }).toList();

  }

  Stream<List<TripAds>> get adList {
      return adsCollection.snapshots().map(_adListFromSnapshot);
  }

  Future createAd() async {
    var key = adsCollection.doc().id;
    return await adsCollection.doc(key).set({
      'tripName': 'Cathedral Rock',
      'documentID' : key,
      'location': 'Sedona, Arizona',
      'dateCreated': FieldValue.serverTimestamp(),
      'clicks' : 0,
      'favorites': [],
      'clickers': [],
      'urlToImage': 'https://www.tripstodiscover.com/wp-content/uploads/2016/10/bigstock-Cathedral-Rock-in-Sedona-Ariz-92403158-3-1.jpg',
    });
  }

}
