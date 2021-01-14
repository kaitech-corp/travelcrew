import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travelcrew/models/custom_objects.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:travelcrew/services/cloud_functions.dart';
import 'package:travelcrew/services/constants.dart';
import 'package:travelcrew/services/locator.dart';
import 'package:travelcrew/services/push_notifications.dart';
import 'package:travelcrew/services/tc_functions.dart';
import 'analytics_service.dart';

var userService = locator<UserService>();
var currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

class DatabaseService {

  final String uid;
  var tripDocID;
  var userID;
  DatabaseService({this.tripDocID, this.uid, this.userID});
  final AnalyticsService _analyticsService = AnalyticsService();
  final FirebaseMessaging _fcm = FirebaseMessaging();


  //  All collection references

  final CollectionReference userCollection = FirebaseFirestore.instance.collection("users");
  final CollectionReference userPublicProfileCollection = FirebaseFirestore.instance.collection("userPublicProfile");
  final Query allUsersCollection = FirebaseFirestore.instance.collection("userPublicProfile").orderBy('lastname').orderBy('firstname');
  final Query tripCollection = FirebaseFirestore.instance.collection("trips").orderBy('endDateTimeStamp').where('ispublic', isEqualTo: true);
  final Query privateTripCollection = FirebaseFirestore.instance.collection("privateTrips").orderBy('endDateTimeStamp');
  final CollectionReference tripsCollectionUnordered = FirebaseFirestore.instance.collection("trips");
  final CollectionReference privateTripsCollectionUnordered = FirebaseFirestore.instance.collection("privateTrips");
  final CollectionReference transportCollection =  FirebaseFirestore.instance.collection("transport");
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
  final CollectionReference dmChatCollection = FirebaseFirestore.instance.collection('dmChat');
  final CollectionReference suggestionsCollection = FirebaseFirestore.instance.collection('suggestions');
  final CollectionReference tokensCollection = FirebaseFirestore.instance.collection('tokens');
  final CollectionReference addReviewCollection = FirebaseFirestore.instance.collection('addReview');
  final CollectionReference versionCollection = FirebaseFirestore.instance.collection('version');


  // Shows latest app version to display in main menu.
  Future<String> getVersion() async{
    try {
      //TODO change version doc for new releases
      var ref = await versionCollection.doc('version2_0_2').get();
      Map<String, dynamic> data = ref.data();


      return data['version'] ?? '';
    } catch (e) {
      CloudFunction().logError(e.toString());
      return '';

    }

  }

  // Saves tokens for push notifications. Saves only after user navigates to the main screen.
  saveDeviceToken() async {
    // Get the current user
    String uid = userService.currentUserID;
    // FirebaseUser user = await _auth.currentUser();

    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    try {
      var ref = await tokensCollection.doc(uid).collection('tokens')
          .doc(fcmToken).get();
      // Save it to Firestore
      if (!ref.exists) {
        if (fcmToken != null) {
          var tokens = tokensCollection
              .doc(uid)
              .collection('tokens')
              .doc(fcmToken);

          await tokens.set({
            'token': fcmToken,
            'createdAt': FieldValue.serverTimestamp(), // optional
            'platform': Platform.operatingSystem // optional
          });
        }
      }
    } catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  //Updates user info after signup
  Future updateUserData(String firstName, String lastName, String email, String uid) async {
    try {
      String action = 'Updating User data.';
      CloudFunction().logEvent(action);
      return await userCollection.doc(uid).set({
        'firstName': firstName,
        'lastName' : lastName,
        'email': email,
        'uid': uid
      });
    } catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  //Checks whether user has a Public Profile on Firestore to know whether to
  // send user to complete profile page or not.

  Future<bool> checkUserHasProfile() async {
    var ref = userCollection.doc(uid);
    var refSnapshot = await ref.get();

    return refSnapshot.exists;
    }
//Updates public profile after sign up
  Future updateUserPublicProfileData(String displayName, String firstName, String lastName, String email, int tripsCreated, int tripsJoined, String uid, File urlToImage) async {
    var ref = userPublicProfileCollection.doc(uid);
     try {
       String action = 'Updating public profile after sign up';
       CloudFunction().logEvent(action);
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
        'urlToImage': '',
        'hometown':  '',
        'instagramLink':  '',
        'facebookLink':  '',
        'topDestinations': ['','',''],
           });
     } catch (e) {
       print('Error creating Public: ${e.toString()}');
       _analyticsService.writeError('Error creating Public: ${e.toString()}');
       CloudFunction().logError(e.toString());
     }
     if (urlToImage != null) {
       String urlforImage;
       
       try {
         String action = 'Saving and updating User profile picture';
         CloudFunction().logEvent(action);
         Reference storageReference = FirebaseStorage.instance
             .ref()
             .child('users/$uid');
         UploadTask uploadTask = storageReference.putFile(urlToImage);
         await uploadTask.whenComplete(() => print('File Uploaded'));

         
         return await ref.update({
           'urlToImage': await storageReference.getDownloadURL().then((fileURL) {
             urlforImage = fileURL;
             return urlforImage;
           })
         });
       } catch (e) {
        print('Error updating with image url: ${e.toString()}');
        _analyticsService.writeError('Error updating public profile with image url: ${e.toString()}');
        CloudFunction().logError(e.toString());
       }
     }
  }

  // Edit Public Profile page
  Future editPublicProfileData(UserPublicProfile userProfile, File urlToImage) async {
    var ref = userPublicProfileCollection.doc(uid);
    print(userProfile.hometown);
    try {
      String action = 'Editing Public Profile page';
      CloudFunction().logEvent(action);
      await ref.update({
        'displayName': userProfile.displayName,
        'firstName': userProfile.firstName,
        'lastName' : userProfile.lastName,
        'hometown': userProfile.hometown,
        'instagramLink': userProfile.instagramLink,
        'facebookLink': userProfile.facebookLink,
        'topDestinations': userProfile.topDestinations,
      });
    } catch (e) {
      print('Error editing Public Profile: ${e.toString()}');
      _analyticsService.writeError('Error editing Public Profile: ${e.toString()}');
      CloudFunction().logError(e.toString());
    }
    if (urlToImage != null) {
      String urlforImage;

      try {
        String action = 'Saving user profile picture after editing Public Profile page';
        CloudFunction().logEvent(action);
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('users/$uid');
        UploadTask uploadTask = storageReference.putFile(urlToImage);
        await uploadTask.whenComplete(() => print('File Uploaded'));

        return await ref.update({
          'urlToImage': await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      } catch (e) {
        print('Error updating with image url: ${e.toString()}');
        _analyticsService.writeError('Error editing Public Profile with image url: ${e.toString()}');
        CloudFunction().logError(e.toString());
      }
    }
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
        String action = 'Adding new trip';
        CloudFunction().logEvent(action);
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
        CloudFunction().logError(e.toString());
      }
      try {
        String action = 'Saving member data to new Trip';
        CloudFunction().logEvent(action);
         addTripRef.collection('Members').doc(userService.currentUserID).set({
           'displayName' : currentUserProfile.displayName,
           'firstName': firstName,
           'lastname' : lastName,
           'uid' : userService.currentUserID,
           'urlToImage' : '',
         });
      } catch(e){
        CloudFunction().logError(e.toString());
      }

    } else {
      var addTripRef = privateTripsCollectionUnordered.doc(key);
      try {
        String action = 'Saving new private Trip';
        CloudFunction().logEvent(action);
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
        CloudFunction().logError(e.toString());
      }
      try {
        String action = 'Saving member data to new private Trip';
        CloudFunction().logEvent(action);
        addTripRef.collection('Members').doc(userService.currentUserID).set({
          'displayName' : currentUserProfile.displayName,
          'firstName': firstName,
          'lastName' : lastName,
          'uid' : userService.currentUserID,
          'urlToImage' : '',
        });
      } catch(e){
        CloudFunction().logError(e.toString());
      }
    }

    try {
      String action = 'adding user uid to trip access members field';
      CloudFunction().logEvent(action);
      await userCollection.doc(userService.currentUserID).update({'trips': FieldValue.arrayUnion([key])});
    }catch (e) {
      CloudFunction().logError(e.toString());
    }
//     await addTripRef.update({"documentId": addTripRef.id});

    if (urlToImage != null) {
      if(ispublic) {
        try {
          String action = 'Saving Trip image';
          CloudFunction().logEvent(action);
          String urlforImage;
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('trips/$key');
          UploadTask uploadTask = storageReference.putFile(urlToImage);
          await uploadTask.whenComplete(() => print('File Uploaded'));

          return await tripsCollectionUnordered.doc(key).update({
            "urlToImage": await storageReference.getDownloadURL().then((
                fileURL) {
              urlforImage = fileURL;
              return urlforImage;
            })
          });
        } catch (e) {
          CloudFunction().logError(e.toString());
        }
      } else {
        try {
          String action = 'Saving private trip image';
          CloudFunction().logEvent(action);
          String urlforImage;
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('trips/$key');
          UploadTask uploadTask = storageReference.putFile(urlToImage);
          await uploadTask.whenComplete(() => print('File Uploaded'));

          return await privateTripsCollectionUnordered.doc(key).update({
            "urlToImage": await storageReference.getDownloadURL().then((
                fileURL) {
              urlforImage = fileURL;
              return urlforImage;
            })
          });
        } catch (e) {
          CloudFunction().logError(e.toString());
        }
      }
    }
  }
  // Convert trip (private or public)
  Future convertTrip(Trip trip)
  async {
    if (!trip.ispublic) {
      try {
        String action = 'Converting trip from private to public';
        CloudFunction().logEvent(action);
        await tripsCollectionUnordered.doc(trip.documentId).set(
            {
              'favorite': trip.favorite,
              'accessUsers': trip.accessUsers,
              'comment': trip.comment,
              'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
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
          String action = 'Deleting private trip after converting to public';
          CloudFunction().logEvent(action);
           privateTripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          CloudFunction().logError(e.toString());
        }
        trip.accessUsers.forEach((member) {
          CloudFunction().addMember(trip.documentId, member);
        });
      } catch (e) {
        CloudFunction().logError(e.toString());
        _analyticsService.writeError('Error converting to public trip:  ${e.toString()}');
      }
    } else {
      try {
        String action = 'Converting trip from public to private';
        CloudFunction().logEvent(action);
        await privateTripsCollectionUnordered.doc(trip.documentId)
            .set({
          'favorite': trip.favorite,
          'accessUsers': trip.accessUsers,
          'comment': trip.comment,
          'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
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
          String action = 'Deleting public trip after converting it to private';
          CloudFunction().logEvent(action);
           tripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          CloudFunction().logError(e.toString());
        }
        trip.accessUsers.forEach((member) {
          CloudFunction().addPrivateMember(trip.documentId, member);
        });
      }
      catch (e) {
        _analyticsService.writeError('Error converting to private trip:  ${e.toString()}');
        CloudFunction().logError(e.toString());
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


    try {
      String action = 'Editing Trip';
      CloudFunction().logEvent(action);
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
    } catch (e) {
      CloudFunction().logError(e.toString());
    }
    try {
      String action = 'Updating image after editing trip';
      CloudFunction().logEvent(action);
      if (urlToImage != null) {
        String urlforImage;
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('trips/${addTripRef.id}');
        UploadTask uploadTask = storageReference.putFile(urlToImage);
        await uploadTask.whenComplete(() => print('File Uploaded'));

        return await addTripRef.update({
          "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
            urlforImage = fileURL;
            return urlforImage;
          })
        });
      }
    } catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  Future<UserPublicProfile> followingList() async{
    var ref = await userPublicProfileCollection.doc(currentUserProfile.uid).get();
    if(ref.exists){
      Map<String, dynamic> data = ref.data();
      return UserPublicProfile(
        following: List<String>.from(data['following']) ?? [],
      );
    }
  }
  // Get following list
  Stream<List<UserPublicProfile>> retrieveFollowingList() async*{
      var user = await usersList();
      var followingRef = await followingList();
    var ref =
          user.where((user) => followingRef.following.contains(user.uid)).toList();

    yield ref;
  }

  Stream<List<UserPublicProfile>> retrieveFollowList(UserPublicProfile currentUser) async*{
    var user = await usersList();
    List<String> followList = new List.from(currentUser.following)..addAll(currentUser.followers);
    List<UserPublicProfile> newList =
    user.where((user) => followList.contains(user.uid)).toList();
    yield newList;
  }

  List<Bringing> _retrieveBringingItems(QuerySnapshot snapshot) {
        try {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
              return Bringing(
              displayName: data['displayName'] ?? '',
              item: data['item'] ?? '',
              documentID: data['documentID'] ?? '',
              voters: List<String>.from(data['voters']) ?? [],
          );
                }).toList();
        } catch (e) {
          CloudFunction().logError(e.toString());
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            return Bringing(
              displayName: data['displayName'] ?? '',
              item: data['item'] ?? '',
              documentID: data['documentID'] ?? '',
            );
          }).toList();
        }
  }
  Stream<List<Bringing>> getBringingList(String docID){
    return bringListCollection.doc(docID).collection('Items').snapshots().map(_retrieveBringingItems);
  }

  List<Need> _retrieveNeedItems(QuerySnapshot snapshot) {
    try {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return Need(
            displayName: data['displayName'] ?? '',
            item: data['item'] ?? '',
            documentID: data['documentID'] ?? ''
        );
      }).toList();
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }
  Stream<List<Need>> getNeedList(String docID){
    return needListCollection.doc(docID).collection('Items').snapshots().map(_retrieveNeedItems);
  }

  //Get all members from Trip
  Future<List<Members>> retrieveMembers(String docID, bool ispubic) async {
    if(ispubic) {
      try {
        String action = 'Get all members from Trip';
        CloudFunction().logEvent(action);
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
        CloudFunction().logError(e.toString());
        return null;
      }
    } else {
      try {
        String action = 'Get all members from private trip';
        CloudFunction().logEvent(action);
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
        CloudFunction().logError(e.toString());
        return null;
      }
    }


  }

  // Get Trip
  Future<Trip> getTrip(String documentID) async {

    var ref = await tripsCollectionUnordered.doc(documentID).get();
    try {
      String action = 'Get single trip by document ID';
      CloudFunction().logEvent(action);
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
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }
  // Get Private Trip
  Future<Trip> getPrivateTrip(String documentID) async {

    var ref = await privateTripsCollectionUnordered.doc(documentID).get();
    try {
      String action = 'Get single private trip by document ID';
      CloudFunction().logEvent(action);
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
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }

// Get all trips
    List<Trip> _tripListFromSnapshot(QuerySnapshot snapshot) {

    try {
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
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }
  // get trips stream
  Stream<List<Trip>> get trips {
    return tripCollection.snapshots()
        .map(_tripListFromSnapshot);
  }


  Future<List<Trip>> privateTripList() async {
    try {
      String action = 'Retrieve private trip list by uid';
      CloudFunction().logEvent(action);
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
        }).toList().reversed.toList();
    } catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  // Add new lodging

  Future addNewLodgingData(String comment, String displayName, String documentID,
      String link, String lodgingType, String uid, File urlToImage, String tripName,
      String startTime, String endTime) async {

    var key = lodgingCollection.doc().id;
    print(documentID);

    try {
      String action = 'Add new lodging for $documentID';
      CloudFunction().logEvent(action);
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
    } catch (e) {
      CloudFunction().logError(e.toString());
    }

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
      String action = 'Editing lodging for $documentID';
      CloudFunction().logEvent(action);
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
      CloudFunction().logError(e.toString());
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
      String action = 'Add new activity for $documentID';
      CloudFunction().logEvent(action);
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
      CloudFunction().logError(e.toString());
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
      String action = 'Editing activity for $documentID';
      CloudFunction().logEvent(action);
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
      CloudFunction().logError(e.toString());
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
    try {
      List<LodgingData> lodgingList = snapshot.docs.map((doc) {
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
      lodgingList.sort((a, b) => b.voters.length.compareTo(a.voters.length));
      return lodgingList;
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }
  //Get Lodging List
  Stream<List<LodgingData>> get lodgingList {
    return lodgingCollection.doc(tripDocID).collection('lodging').snapshots().map(_lodgingListFromSnapshot);
  }

  List<ActivityData> _activitiesListFromSnapshot(QuerySnapshot snapshot){
    try {
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
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  Stream<List<ActivityData>> get activityList {
    return activitiesCollection.doc(tripDocID).collection('activity').snapshots().map(_activitiesListFromSnapshot);
  }

  //Get all users
  List<UserPublicProfile> _userListFromSnapshot(QuerySnapshot snapshot){

    try {
      List<UserPublicProfile> userList =  snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data();
        return UserPublicProfile(
          displayName: data['displayName'] ?? '',
          email: data['email'] ?? '',
          following: List<String>.from(data['following']) ?? [''],
          followers: List<String>.from(data['followers']) ?? [''],
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          uid: data['uid'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
          hometown: data['hometown'] ?? '',
          instagramLink: data['instagramLink'] ?? '',
          facebookLink: data['facebookLink'] ?? '',
          topDestinations: List<String>.from(data['topDestinations']) ?? [''],
        );
      }).toList();
      userList.sort((a,b) => a.displayName.compareTo(b.displayName));

      return userList;
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }
  // get all users
  Stream<List<UserPublicProfile>> get userList {
    return userPublicProfileCollection.snapshots()
        .map(_userListFromSnapshot);
  }
  //Get all users Future Builder
  Future<List<UserPublicProfile>> usersList() async {
    try {
      var ref = await userPublicProfileCollection.get();
      List<UserPublicProfile> userList = ref.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return UserPublicProfile(
          displayName: data['displayName'] ?? '',
          email: data['email'] ?? '',
          following: List<String>.from(data['following']) ?? [''],
          followers: List<String>.from(data['followers']) ?? [''],
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          uid: data['uid'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
          hometown: data['hometown'] ?? '',
          instagramLink: data['instagramLink'] ?? '',
          facebookLink: data['facebookLink'] ?? '',
          topDestinations: List<String>.from(data['topDestinations']) ?? [''],
        );
      }).toList();
      userList.sort((a,b) => a.displayName.compareTo(b.displayName));
      return userList;
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
    }


  // Get current user public profile
  UserPublicProfile _userPublicProfileSnapshot(DocumentSnapshot snapshot){
    try {
      Map<String, dynamic> data = snapshot.data();
        return UserPublicProfile(
          displayName: data['displayName'] ?? '',
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          following: List<String>.from(data['following']) ?? [''],
          followers: List<String>.from(data['followers']) ?? [''],
          lastName: data['lastName'] ?? '',
          uid: data['uid'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
          hometown: data['hometown'] ?? '',
          instagramLink: data['instagramLink'] ?? '',
          facebookLink: data['facebookLink'] ?? '',
          topDestinations: List<String>.from(data['topDestinations']) ?? [''],
        );
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
    }

  }

  // get current use public profile
  Stream<UserPublicProfile> get currentUserPublicProfile {
    return userPublicProfileCollection.doc(userService.currentUserID).snapshots()
        .map(_userPublicProfileSnapshot);
  }

  // Get
  List<TransportationData> _transportListFromSnapshot(QuerySnapshot snapshot) {
    // var list2 = List();
    // List<TransportationData> listOfModes = List();
    try {
      List<TransportationData> transportList =  snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return TransportationData(
          mode: data['mode'] ?? '',
          carpoolingWith: data['carpoolingWith'] ?? '',
          canCarpool: data['canCarpool'] ?? false,
          airline: data['airline'] ?? '',
          fieldID: data['fieldID'] ?? '',
          flightNumber: data['flightNumber'] ?? '',
          displayName: data['displayName'] ?? '',
          comment:  data['comment'] ?? '',
          tripDocID: data['tripDocID'] ?? '',
          uid: data['uid'] ?? '',
        );
      }).toList();

      return transportList;
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  Stream<List<TransportationData>> get transportList {
      return transportCollection.doc(tripDocID).collection('mode').snapshots().map(_transportListFromSnapshot);
  }

  //Query for My Crew Trips
  List<Trip> _privateTripListFromSnapshot(QuerySnapshot snapshot){
    try {
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
          startDateTimeStamp: data['startDateTimeStamp'],
          tripGeoPoint: data['tripGeoPoint'] ?? null,
          tripName: data['tripName'] ?? '',
          travelType: data['travelType'] ?? '',
          urlToImage: data['urlToImage'] ?? '',
        );
      }).toList().reversed.toList();
    } catch (e){
      CloudFunction().logError(e.toString());
      return null;
    }
  }

  //Query for current My Crew Trips
  List<Trip> _currentCrewTripListFromSnapshot(QuerySnapshot snapshot){
    try {
      final now = DateTime.now().toUtc();
      var tomorrow = DateTime(now.year, now.month, now.day + 1);
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
      List<Trip> crewTrips = trips.where((trip) =>
          trip.endDateTimeStamp.toDate().isAfter(tomorrow)).toList();
      return crewTrips;
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }

  //Query for past My Crew Trips
  List<Trip> _pastCrewTripListFromSnapshot(QuerySnapshot snapshot){
    try {
      final now = DateTime.now().toUtc();
      var yesterday = DateTime(now.year, now.month, now.day - 1);
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
      List<Trip> crewTrips = trips.where((trip) => yesterday.isAfter(trip.endDateTimeStamp.toDate())).toList().reversed.toList();
      return crewTrips;
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  Stream<List<Trip>> get currentCrewTrips {
    return tripCollection.where('accessUsers', arrayContainsAny: [userService.currentUserID]).snapshots()
        .map(_currentCrewTripListFromSnapshot);
  }
  Stream<List<Trip>> get pastCrewTrips {
    return tripCollection.where('accessUsers', arrayContainsAny: [userService.currentUserID]).snapshots()
        .map(_pastCrewTripListFromSnapshot);
  }
  Stream<List<Trip>> pastCrewTripsCustom(String uid) {
    return tripCollection.where('accessUsers', arrayContainsAny: [uid]).snapshots()
        .map(_pastCrewTripListFromSnapshot);
  }

  Stream<List<Trip>> get privateTrips {
    return privateTripCollection.where('accessUsers', arrayContainsAny: [userService.currentUserID]).snapshots()
        .map(_privateTripListFromSnapshot);
  }

  Stream<List<Trip>> get favoriteTrips {
    return tripCollection.where('favorite', arrayContainsAny: [userService.currentUserID]).snapshots()
        .map(_tripListFromSnapshot);
  }

// check uniqueness to avoid duplicate function calls or writes
  Future addToUniqueDocs(String key2){
    try {
      String action = 'creating unique key';
      CloudFunction().logEvent(action);
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
          ownerID: data['ownerID'] ?? '',
          ownerDisplayName: data['ownerDisplayName'] ?? '',
          fieldID: data['fieldID'] ?? '',
          ispublic: data['ispublic'] ?? false,
          message: data['message'] ?? '',
          timestamp: data['timestamp'] ?? Timestamp.now(),
          type: data['type'] ?? '',
          uid: data['uid'] ?? '',
        );
      }).toList();
    } catch (e) {
      CloudFunction().logError(e.toString());
      return null;
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
      CloudFunction().logError(e.toString());
    }
  }

// Clear chat notifications.
  Future clearChatNotifications() async {
    try {
      var db = chatCollection.doc(tripDocID).collection('messages').where('status.$uid' ,isEqualTo: false);
      QuerySnapshot snapshot = await db.get();
      for(var i =0; i< snapshot.docs.length;i++) {
        chatCollection.doc(tripDocID).collection('messages').doc(snapshot.docs[i].id).update({'status.$uid': true});
      }
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  // Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot snapshot){

    try {
      return snapshot.docs.map((doc){
        Map<String, dynamic> data = doc.data();
        return ChatData(
          chatID: data['chatID'] ?? '',
          displayName: data['displayName'] ?? '',
          fieldID: data['fieldID'] ?? '',
          message: data['message'] ?? '',
          timestamp: data['timestamp'] ?? Timestamp.now(),
          uid: data['uid'] ?? '',
        );
      }).toList();
    } catch (e) {
      // AnalyticsService().writeError(e.toString());
      CloudFunction().logError(e.toString());
      return null;
    }
  }
//Stream chats
  Stream<List<ChatData>> get chatList {
    try {
      return chatCollection.doc(tripDocID).collection('messages')
      .orderBy('timestamp', descending: true)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }
  Stream<List<ChatData>> get chatListNotification {
    try {
      return chatCollection.doc(tripDocID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false).snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      CloudFunction().logError(e.toString());
      return null;
    }
  }

// Feedback Data stream snapshot
  List<TCFeedback> _feedbackSnapshot (QuerySnapshot snapshot) {

    List<TCFeedback> feedback = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data();
          return TCFeedback(
            fieldID: data['fieldID'] ?? '',
            message: data['message'] ?? '',
            uid: data['uid'] ?? '',
            timestamp: data['timestamp'] ?? null,
          );
        }).toList();
      feedback.sort((a,b) => b.timestamp.compareTo(a.timestamp));

      return feedback;

  }

  //Stream Feedback data
  Stream<List<TCFeedback>> get feedback {
     return feedbackCollection.snapshots().map(_feedbackSnapshot);
  }


  //Read feedback data from users. Only shown on admin page.
  // Future<List<TCFeedback>> feedback() async {
  //   try {
  //     var ref = await feedbackCollection.get();
  //     List<TCFeedback> feedback = ref.docs.map((doc) {
  //       Map<String, dynamic> data = doc.data();
  //       return TCFeedback(
  //         fieldID: data['fieldID'] ?? '',
  //         message: data['message'] ?? '',
  //         uid: data['uid'] ?? '',
  //         timestamp: data['timestamp'] ?? null,
  //       );
  //     }).toList();
  //     feedback.sort((a,b) => b.timestamp.compareTo(a.timestamp));
  //
  //     return feedback;
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

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

      try {
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
      } on Exception catch (e) {
        CloudFunction().logError(e.toString());
        return null;
      }

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

  // Add new direct message
  Future addNewDMChatMessage(String displayName, String message, String uid, Map status) async {
    var key = chatCollection.doc().id;

    String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);

    var ref = await dmChatCollection.doc(chatID).get();
    if(!ref.exists) {
      await dmChatCollection.doc(chatID).set({
        'ids': [userID, userService.currentUserID],
        'lastUpdatedTimestamp': FieldValue.serverTimestamp(),
      });
    } else{
      await dmChatCollection.doc(chatID).update({
        'lastUpdatedTimestamp': FieldValue.serverTimestamp(),
      });
    }
    try {
      return await dmChatCollection.doc(chatID).collection('messages').doc(key).set(
          {
            'chatID': chatID,
            'displayName': displayName,
            'fieldID': key,
            'message': message,
            'status': status,
            'timestamp': FieldValue.serverTimestamp(),
            'uid': uid,
          });
    } catch (e) {
      _analyticsService.writeError('Error writing new chat:  ${e.toString()}');
      CloudFunction().logError(e.toString());
    }
  }
  // Delete a chat message
  Future deleteDMChatMessage({ChatData message}) async {
    // String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);
    try {
      return await dmChatCollection.doc(message.chatID).collection('messages').doc(message.fieldID).delete();
    } catch (e) {
      _analyticsService.writeError('Error deleting new chat:  ${e.toString()}');
      CloudFunction().logError(e.toString());
    }
  }

  // Clear DM chat notifications.
  Future clearDMChatNotifications() async {
    try {
      String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);
      var db = dmChatCollection.doc(chatID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false);
      QuerySnapshot snapshot = await db.get();
      snapshot.docs.forEach((doc) {
        dmChatCollection.doc(chatID).collection('messages').doc(doc.id).update({'status.${userService.currentUserID}': true});
      });
    } on Exception catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  // Get all direct message chat messages
  Stream<List<ChatData>> get dmChatList {
    String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);
    try {
      return dmChatCollection.doc(chatID).collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      _analyticsService.writeError(e.toString());
      CloudFunction().logError(e.toString());
    }
  }

  Stream<List<ChatData>> get dmChatListNotification {
    String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);
    try {
      return dmChatCollection.doc(chatID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      CloudFunction().logError(e.toString());
    }
  }

  // Get user list of DM chats
  Stream<List<UserPublicProfile>> retrieveDMChats() async*{
    List<String> _uidsOfAllChats = [];
    var user = await usersList();
    List<UserPublicProfile> sortedUserList = [];

      var ref = await dmChatCollection.orderBy('lastUpdatedTimestamp',descending: true).where(
          'ids', arrayContains: userService.currentUserID).get();
      ref.docs.forEach((doc) {
        _uidsOfAllChats.add(doc.id);
      });
      var _idList = [];
      _uidsOfAllChats.forEach((id) {
        var _y = id.split('_');
        _y.remove(userService.currentUserID);
        _idList.add(_y[0]);
      });

      _idList.forEach((profile) {
        sortedUserList.add(user.where((element) => profile == element.uid).first);
      });
    yield sortedUserList;
  }

  // Get Access users for Crew list
  // Get user list of DM chats
  Stream<List<UserPublicProfile>> getcrewList(List<String> accessUsers) async*{
    var users = await usersList();
    List<UserPublicProfile> crewList = [];

    yield users.where((user) => accessUsers.contains(user.uid)).toList();
  }


  Future writeSuggestions() async{
    var ref = suggestionsCollection;
    urls.forEach((url) {
      var key = suggestionsCollection.doc().id;
      ref.doc(key).set({
        'fieldID': key,
        'url': url,
        'timestamp': FieldValue.serverTimestamp(),
        'tags': [],
      });
    });
  }

  // Get all Suggestions
  List<Suggestions> _suggestionListFromSnapshot(QuerySnapshot snapshot){

    return snapshot.docs.map((doc){
      Map<String, dynamic> data = doc.data();
      return Suggestions(
        url: data['url'] ?? '',
        timestamp: data['timestamp'] ?? null,
        fieldID: data['fieldID'] ?? '',
      );
    }).toList();

  }

  Stream<List<Suggestions>> get suggestionList {
    return suggestionsCollection.snapshots().map(_suggestionListFromSnapshot);
  }

  // Delete a suggestion
  Future deleteSuggestion({String fieldID}) async {
      return await suggestionsCollection.doc(fieldID).delete();
  }

  //Check if user already submitted or view app Review this month
  Future<bool> appReviewExists(String docID) async {
    var ref = await addReviewCollection.doc(currentUserProfile.uid).collection('review').get();

    return ref.docs.contains(docID);
  }


}


