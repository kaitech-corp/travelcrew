import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import '../../models/activity_model.dart';
import '../../models/chat_model.dart';
import '../../models/cost_model.dart';
import '../../models/custom_objects.dart';
import '../../models/lodging_model.dart';
import '../../models/settings_model.dart';
import '../../models/split_model.dart';
import '../../models/trip_model.dart';
import '../../screens/trip_details/split/split_package.dart';
import '../../services/constants/constants.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/functions/tc_functions.dart';
import '../../services/locator.dart';
import '../../services/navigation/navigation_service.dart';
import '../../services/notifications/notifications.dart';
import 'analytics_service.dart';

UserService userService = locator<UserService>();
NavigationService navigationService = locator<NavigationService>();
ValueNotifier<String> urlToImage = ValueNotifier<String>('');
UserPublicProfile currentUserProfile = locator<UserProfileService>().currentUserProfileDirect();

////Database class for all firebase api functions
class DatabaseService {
  
  DatabaseService({this.uid,this.fieldID,this.tripDocID, this.userID,
    this.itemDocID});
  ////uid parameter
  String? uid;
  ////tripDocID parameter
  String? tripDocID;
  ////itemDocID parameter
  String? itemDocID;
  ////userID parameter
  String? userID;
  ////fieldID parameter
  String? fieldID;
  final AnalyticsService _analyticsService = AnalyticsService();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;


  ///  All collection references

  final CollectionReference<Object?> userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference<Object?> userPublicProfileCollection = FirebaseFirestore.instance.collection('userPublicProfile');
  final Query<Object?> allUsersCollection = FirebaseFirestore.instance.collection('userPublicProfile').orderBy('lastname').orderBy('firstname');
  final Query<Object?> tripCollection = FirebaseFirestore.instance.collection('trips').orderBy('endDateTimeStamp').where('ispublic', isEqualTo: true);
  final Query<Object?> privateTripCollection = FirebaseFirestore.instance.collection('privateTrips').orderBy('endDateTimeStamp');
  final CollectionReference<Object?> tripsCollectionUnordered = FirebaseFirestore.instance.collection('trips');
  final CollectionReference<Object?>  privateTripsCollectionUnordered = FirebaseFirestore.instance.collection('privateTrips');
  final CollectionReference<Object?>  transportCollection =  FirebaseFirestore.instance.collection('transport');
  final CollectionReference<Object?>  lodgingCollection =  FirebaseFirestore.instance.collection('lodging');
  final CollectionReference<Object?>  activitiesCollection =  FirebaseFirestore.instance.collection('activities');
  final CollectionReference<Object?>  chatCollection =  FirebaseFirestore.instance.collection('chat');
  final CollectionReference<Object?>  notificationCollection = FirebaseFirestore.instance.collection('notifications');
  final CollectionReference<Object?>  bringListCollection = FirebaseFirestore.instance.collection('bringList');
  final CollectionReference<Object?>  needListCollection = FirebaseFirestore.instance.collection('needList');
  final CollectionReference<Object?>  uniqueCollection = FirebaseFirestore.instance.collection('unique');
  final CollectionReference<Object?>  feedbackCollection = FirebaseFirestore.instance.collection('feedback');
  final CollectionReference<Object?>  reportsCollection = FirebaseFirestore.instance.collection('reports');
  final CollectionReference<Object?>  adsCollection = FirebaseFirestore.instance.collection('tripAds');
  final CollectionReference<Object?>  dmChatCollection = FirebaseFirestore.instance.collection('dmChat');
  final CollectionReference<Object?>  suggestionsCollection = FirebaseFirestore.instance.collection('suggestions');
  final CollectionReference<Object?>  tokensCollection = FirebaseFirestore.instance.collection('tokens');
  final CollectionReference<Object?>  addReviewCollection = FirebaseFirestore.instance.collection('addReview');
  final CollectionReference<Object?>  versionCollection = FirebaseFirestore.instance.collection('version');
  final CollectionReference<Object?>  splitItemCollection = FirebaseFirestore.instance.collection('splitItem');
  final CollectionReference<Object?>  costDetailsCollection = FirebaseFirestore.instance.collection('costDetails');
  final CollectionReference<Object?>  settingsCollection = FirebaseFirestore.instance.collection('settings');

  //// Shows latest app version to display in main menu.
  Future<String> getVersion() async{
    try {
      // TODO(Randy): change version doc for new releases
      final DocumentSnapshot<Object?> ref =
      await versionCollection.doc('version3_0_8').get();
      final Map<String, dynamic> data = ref.data()! as Map<String, dynamic>;
      final String version = data['version'] as String;
      if(version.isNotEmpty){
        return version;
      } else {
        return '';
      }
    } catch (e) {
      CloudFunction().logError('Error retrieving version:  ${e.toString()}');
      return '';
    }
  }
////Save device token to use in cloud messaging.
  Future<void> saveDeviceToken() async {
    try {
      /// Get the token for this device
      final String? fcmToken = await _fcm.getToken();
      final DocumentSnapshot<Map<String, dynamic>> ref = await tokensCollection.doc(uid).collection('tokens')
          .doc(fcmToken).get();
      /// Save it to Firestore
      if (!ref.exists || ref.id != fcmToken) {
        if (fcmToken != null) {
          final DocumentReference<Map<String, dynamic>> tokens = tokensCollection
              .doc(uid)
              .collection('tokens')
              .doc(fcmToken);

          await tokens.set(<String, dynamic>{
            'token': fcmToken,
            'createdAt': FieldValue.serverTimestamp(), /// optional
            'platform': Platform.operatingSystem /// optional
          });
        }
      }
    } catch (e) {
      CloudFunction().logError('Error saving token:  ${e.toString()}');
    }
  }


  ///Checks current users saved Settings for on their device.
  Future<UserNotificationSettingsData> getUserNotificationSettings ()async{
    final DocumentSnapshot<Object?> ref = await notificationCollection.doc(userService.currentUserID).get();
    if(ref.exists){
      final Map<String, dynamic> settings = ref.data()! as Map<String, dynamic>;
      return UserNotificationSettingsData.fromData(settings);
    }else{
      final bool status = await SettingsNotifications().permissionStatus();
      settingsCollection.doc(userService.currentUserID).update(
          UserNotificationSettingsData(
            isPushNotificationsOn: status,
            isDirectMessagingOn: true,
            isTripChangeOn: true,
            isTripChatOn: true,
          ).toJson());
      return UserNotificationSettingsData().fakerData();
    }
  }

  void changeDMSettings(bool response){
    settingsCollection.doc(userService.currentUserID).update(<String, dynamic>{
      'isDirectMessagingOn': response,
    });
  }
  void changeTripNotificationSettings(bool response){
    settingsCollection.doc(userService.currentUserID).update(<String, dynamic>{
      'isTripChangeOn': response,
    });
  }
  void changeTripChatNotificationSettings(bool response){
    settingsCollection.doc(userService.currentUserID).update(<String, dynamic>{
      'isTripChatOn': response,
    });
  }



  Future<UserPublicProfile> getUserProfile(String uid) async{
    try{
      final DocumentSnapshot<Object?> userData = await userPublicProfileCollection.doc(uid).get();
      if(userData.exists) {
        // final Map<String, dynamic> data = userData.data()! as Map<String, dynamic>;
        return UserPublicProfile.fromDocument(userData);
      }
    } catch(e){
      CloudFunction().logError('Error retrieving single user profile:  ${e.toString()}');
      // print('Error retrieving single user profile:  ${e.toString()}');
      // return ;
    }
    return defaultProfile;
    // return UserPublicProfile();
  }

  ///Updates user info after signup
  Future<void> updateUserData(
      String? firstName, String? lastName, String? email, String uid) async {
    try {
      const String action = 'Updating User data.';
      CloudFunction().logEvent(action);
      return await userCollection.doc(uid).set(<String, dynamic>{
        'firstName': firstName,
        'lastName' : lastName,
        'email': email,
        'uid': uid
      });
    } catch (e) {
      CloudFunction().logError('Error updating user data:  ${e.toString()}');
    }
  }
///Creates Firestore document files for newly created split item.
  Future<void> createSplitItem(SplitObject splitObject) async{
    final DocumentReference<Map<String, dynamic>> ref = splitItemCollection.doc(splitObject.tripDocID)
        .collection('Item').doc(splitObject.itemDocID);
    final DocumentSnapshot<Map<String, dynamic>> ref2 = await ref.get();
    if(!ref2.exists) {
      try {
        for (final String element in splitObject.userSelectedList) {
          createSplitItemCostDetailsPerUser(splitObject, element);
        }
        return await ref.set(splitObject.toJson());

      } catch (e) {
        CloudFunction().logError('Error from create split item function: $e');
      }
    } else {
      try {
        for (final String element in splitObject.userSelectedList) {
          createSplitItemCostDetailsPerUser(splitObject, element);
        }
        return await ref.update(splitObject.toJson());

      } catch (e) {
        CloudFunction()
            .logError('Error from create split item function: $e');
      }
    }
  }

  //// delete SplitObject
  void deleteSplitObject(SplitObject splitObject){
    final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection.doc(splitObject.tripDocID)
        .collection('Item').doc(splitObject.itemDocID);
    try {
      try {
        for (final String element in splitObject.userSelectedList) {
          costDetailsCollection.doc(splitObject.itemDocID)
              .collection('Users')
              .doc(element).delete();
        }
      } catch (e) {
        CloudFunction()
            .logError('Error deleting user cost details documents: '
            '${e.toString()}');
      }
      ref2.delete();
    } catch (e) {
      CloudFunction()
          .logError('Error marking cost data as paid: $e');
    }
  }

  //// Check Split Item exists
  Future<bool> checkSplitItemExist(String itemDocID) async{
    final DocumentSnapshot<Map<String, dynamic>> ref = await splitItemCollection.doc(tripDocID)
        .collection('Item').doc(itemDocID).get();
    if(ref.exists) {
      return true;
    } else {
      return false;
    }
  }
  //// Stream in split item
  List<SplitObject> _splitItemDataFromSnapshot(QuerySnapshot<Object?> snapshot) {
    try {
      final List<SplitObject> splitItemData =  snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return SplitObject.fromDocument(doc);
      }).toList();

      return splitItemData;
    } catch (e) {
      CloudFunction().logError('Error retrieving split list:  ${e.toString()}');
      return <SplitObject>[];
    }
  }
  //// Stream in split item
  Stream<List<SplitObject>> get splitItemData {
    return splitItemCollection
        .doc(tripDocID)
        .collection('Item')
        .snapshots().map(_splitItemDataFromSnapshot);
  }
  //// Create split item cost details
  Future<void> createSplitItemCostDetailsPerUser(
      SplitObject splitObject, String userUID) async{
    late bool paid; 
    if (userUID == splitObject.purchasedByUID){
      paid = true;
    } else {
      paid = false;
    }
    final CostObject costObject = CostObject(
        tripDocID: splitObject.tripDocID,
        itemDocID: splitObject.itemDocID,
        lastUpdated: Timestamp.now(),
        paid: paid,
        uid: userUID,
        amountOwe: SplitPackage()
            .standardSplit(splitObject
            .userSelectedList.length, splitObject.itemTotal),);

    final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
        .doc(costObject.itemDocID)
        .collection('Users')
        .doc(costObject.uid);
    /// var ref2 = await ref.get();
    /// if(!ref2.exists) {
      try {
        return ref.set(costObject.toJson());
      } catch (e) {
        CloudFunction().logError('Error from create split item function: $e');
      }
    /// }
  }

  //// Mark as paid
   void markAsPaid(CostObject costObject, SplitObject splitObject){
    final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
        .doc(costObject.itemDocID)
        .collection('Users')
        .doc(costObject.uid);
    final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection.doc(splitObject.tripDocID)
        .collection('Item').doc(splitObject.itemDocID);

      try {
         ref.update(<String, dynamic>{
          'paid': costObject.paid,
          'datePaid': FieldValue.serverTimestamp(),
        }
        );
         ref2.update(<String, dynamic>{
          'lastUpdated':FieldValue.serverTimestamp(),
        });
      } catch (e) {
        CloudFunction().logError('Error marking cost data as paid: $e');
      }
  }

  //// Update remaining balance
  void updateRemainingBalance(
      SplitObject splitObject, double amountRemaining, List<String> uidList){
    final DocumentReference<Map<String, dynamic>> ref = splitItemCollection.doc(splitObject.tripDocID)
        .collection('Item').doc(splitObject.itemDocID);
    try {
      ref.update(<String, dynamic>{
        'amountRemaining': amountRemaining,
        'lastUpdated': FieldValue.serverTimestamp(),
        'userSelectedList': uidList,
      });


    } catch (e) {
      CloudFunction().logError('Error marking cost data as paid: $e');
    }
  }
  //// deleteCostObject and recreate the split object with remaining members
  void deleteCostObject(CostObject costObject, SplitObject splitObject){
    final DocumentReference<Map<String, dynamic>> ref = costDetailsCollection
        .doc(costObject.itemDocID)
        .collection('Users')
        .doc(costObject.uid);
    final DocumentReference<Map<String, dynamic>> ref2 = splitItemCollection
        .doc(splitObject.tripDocID)
        .collection('Item')
        .doc(splitObject.itemDocID);
    try {
       splitObject.userSelectedList.remove(costObject.uid);
       ref.delete();
       ref2.update(<String, dynamic>{
         'userSelectedList':FieldValue.arrayRemove(<String?>[costObject.uid])
       });
       createSplitItem(splitObject);

       } catch (e) {
      CloudFunction().logError('Error marking cost data as paid: $e');
    }
    /// }
  }
//// Stream in Cost Details
  List<CostObject> _costObjectDataFromSnapshot(QuerySnapshot<Object?> snapshot) {
    try {
      final List<CostObject> costObjectData =  snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return CostObject.fromDocument(doc);
      }).toList();

      return costObjectData;
    } catch (e) {
      CloudFunction()
          .logError('Error in streaming cost details: ${e.toString()}');
      return <CostObject>[];
    }
  }
////Stream cost data
  Stream<List<CostObject>> get costDataList {
    return costDetailsCollection
        .doc(itemDocID)
        .collection('Users')
        .snapshots().map(_costObjectDataFromSnapshot);
  }

  ////Checks whether user has a Public Profile on Firestore to know whether to
  //// send user to complete profile page or not.
  Future<bool> checkUserHasProfile() async {
    final DocumentReference<Object?> ref = userCollection.doc(uid);
    final DocumentSnapshot<Object?> refSnapshot = await ref.get();
    if (refSnapshot.exists){
      saveDeviceToken();
    }
    retrieveProfileImage();

    return refSnapshot.exists;
    }

    ////Retrieve profile image
    Future<void> retrieveProfileImage() async{
      final DocumentReference<Object?> ref2 = userPublicProfileCollection.doc(uid);
      final DocumentSnapshot<Object?> refSnapshot2 = await ref2.get();

      if (refSnapshot2.exists) {
        urlToImage.value = UserPublicProfile.fromDocument(refSnapshot2).urlToImage;
      }
    }

  ////Updates public profile after sign up
  Future<void> updateUserPublicProfileData(
      String? displayName, String? firstName, String? lastName,
      String? email, String? uid,
      File? urlToImage) async {
    final DocumentReference<Object?> ref = userPublicProfileCollection.doc(uid);
     try {
       const String action = 'Updating public profile after sign up';
       CloudFunction().logEvent(action);
       await ref.set(<String, dynamic>{
        'blockedList': <String>[],
        'displayName': displayName,
        'email': email,
         'followers': <String>[],
         'following': <String>[],
        'firstName': firstName,
        'lastName' : lastName,
        'uid': uid,
        'urlToImage': '',
        'hometown':  '',
        'instagramLink':  '',
        'facebookLink':  '',
        'topDestinations': <String>['','',''],
           });
     } catch (e) {
       _analyticsService
           .writeError('Error creating Public Profile: ${e.toString()}');
       CloudFunction()
           .logError('Error creating public profile:  ${e.toString()}');
     }
     if (urlToImage != null && urlToImage.path.isNotEmpty) {
       String urlForImage;
       
       try {
         const String action = 'Saving and updating User profile picture';
         CloudFunction().logEvent(action);
         final Reference storageReference = FirebaseStorage.instance
             .ref()
             .child('users/$uid');
         final UploadTask uploadTask = storageReference.putFile(urlToImage);

         return await ref.update(<String, dynamic>{
           'urlToImage': await storageReference.getDownloadURL().then((String fileURL) {
             urlForImage = fileURL;
             return urlForImage;
           })
         });
       } catch (e) {
        _analyticsService
            .writeError('Error updating public profile with image url: '
            '${e.toString()}');
        CloudFunction()
            .logError('Error saving image for public profile:  '
            '${e.toString()}');
       }
     }
  }

  //// Edit Public Profile page
  Future<void> editPublicProfileData(
      UserPublicProfile userProfile, File urlToImage) async {
    final DocumentReference<Object?> ref = userPublicProfileCollection.doc(uid);
    try {
      const String action = 'Editing Public Profile page';
      CloudFunction().logEvent(action);
      await ref.update(
      <String, dynamic>{
        'displayName': userProfile.displayName,
    'firstName': userProfile.firstName,
    'lastName' : userProfile.lastName,
    'hometown': userProfile.hometown,
    'instagramLink': userProfile.instagramLink,
    'facebookLink': userProfile.facebookLink,
    'topDestinations': userProfile.topDestinations,
    });
    } catch (e) {
      
      _analyticsService
          .writeError('Error editing Public Profile: ${e.toString()}');
      CloudFunction()
          .logError('Error editing public profile:  ${e.toString()}');
    }
    if (urlToImage != null) {
      String urlForImage;

      try {
        const String action = 'Saving user profile picture after editing '
            'Public Profile page';
        CloudFunction().logEvent(action);
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('users/$uid');
        final UploadTask uploadTask = storageReference.putFile(urlToImage);
        

        return await ref.update(<String, dynamic>{
          'urlToImage': await storageReference.getDownloadURL().then((String fileURL) {
            urlForImage = fileURL;
            return urlForImage;
          })
        });
      } catch (e) {
        
        _analyticsService
            .writeError('Error editing Public Profile with image url: '
            '${e.toString()}');
        CloudFunction()
            .logError('Error editing Public Profile with image url:  '
            '${e.toString()}');
      }
    }
  }




  //// Add new trip
  Future<void> addNewTripData(Trip trip, File? urlToImage) async {
    final UserPublicProfile currentUserProfile = await getUserProfile(userService.currentUserID);
    final String key = tripsCollectionUnordered.doc().id;
    if (trip.ispublic) {
      final DocumentReference<Object?> addTripRef =  tripsCollectionUnordered.doc(key);
      try {
        const String action = 'Adding new trip';
        CloudFunction().logEvent(action);
         addTripRef.set(
             <String,dynamic>{
              'favorite': <String>[],
              'accessUsers': <String>[userService.currentUserID],
              'comment': trip.comment,
              'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
              'displayName': currentUserProfile.displayName,
              'documentId': key,
              'endDate': trip.endDate,
              'endDateTimeStamp': trip.endDateTimeStamp,
              'ispublic': trip.ispublic,
              'location': trip.location,
              'ownerID': userService.currentUserID,
              'startDate': trip.startDate,
              'startDateTimeStamp': trip.startDateTimeStamp,
              'tripName': trip.tripName,
              'tripGeoPoint': trip.tripGeoPoint,
              'travelType': trip.travelType,
              'urlToImage': '',
            });

         _analyticsService.createTrip(true);
      } catch (e){
        _analyticsService
            .writeError('Error saving new public trip:  ${e.toString()}');
        CloudFunction()
            .logError('Error saving new public trip:  ${e.toString()}');
      }
      try {
        const String action = 'Saving member data to new Trip';
        CloudFunction().logEvent(action);
         addTripRef.collection('Members').doc(userService.currentUserID).set(<String, dynamic>{
           'displayName' : currentUserProfile.displayName,
           'firstName': currentUserProfile.firstName,
           'lastname' : currentUserProfile.lastName,
           'uid' : userService.currentUserID,
           'urlToImage' : '',
         });
      } catch(e){
        CloudFunction()
            .logError('Error saving member data to new trip:  ${e.toString()}');
      }

    } else {
      final DocumentReference<Object?> addTripRef = privateTripsCollectionUnordered.doc(key);
      try {
        const String action = 'Saving new private Trip';
        CloudFunction().logEvent(action);
         addTripRef.set(<String, dynamic>{
          'favorite': <String>[],
          'accessUsers': trip.accessUsers,
          'comment': trip.comment,
           'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
          'displayName': currentUserProfile.displayName,
          'documentId': key,
          'endDate': trip.endDate,
          'endDateTimeStamp': trip.endDateTimeStamp,
          'ispublic': trip.ispublic,
          'location': trip.location,
          'ownerID': userService.currentUserID,
          'startDate': trip.startDate,
           'startDateTimeStamp': trip.startDateTimeStamp,
           'tripName': trip.tripName,
           'tripGeoPoint': trip.tripGeoPoint,
          'travelType': trip.travelType,
          'urlToImage': '',
        });
         _analyticsService.createPrivateTrip(true);
      }
      catch (e) {
        _analyticsService
            .writeError('Error saving new private trip:  ${e.toString()}');
        CloudFunction()
            .logError('Error saving new private trip:  ${e.toString()}');
      }
      try {
        const String action = 'Saving member data to new private Trip';
        CloudFunction().logEvent(action);
        addTripRef.collection('Members').doc(userService.currentUserID).set(<String, dynamic>{
          'displayName' : currentUserProfile.displayName,
          'firstName': currentUserProfile.firstName,
          'lastName' : currentUserProfile.lastName,
          'uid' : userService.currentUserID,
          'urlToImage' : '',
        });
      } catch(e){
        CloudFunction()
            .logError('Error saving member data to new private trip:  '
            '${e.toString()}');
      }
    }

    try {
      const String action = 'adding user uid to trip access members field';
      CloudFunction().logEvent(action);
      await userCollection
          .doc(userService.currentUserID)
          .update(<String, dynamic>{
            'trips': FieldValue.arrayUnion(<String>[key])
          });
    }catch (e) {
      CloudFunction()
          .logError('Error adding user to access users (Public Trip):  '
          '${e.toString()}');
    }
///     await addTripRef.update(<String, dynamic>{"documentId": addTripRef.id});

    if (urlToImage != null) {
      if(trip.ispublic) {
        try {
          String urlForImage;
          final Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('trips/$key');
          final UploadTask uploadTask = storageReference.putFile(urlToImage);

          return await tripsCollectionUnordered.doc(key).update(<String, dynamic>{
            'urlToImage': await storageReference.getDownloadURL()
          });
        } catch (e) {
          CloudFunction()
              .logError('Error saving trip image (public):  ${e.toString()}');
        }
      } else {
        try {
          const String action = 'Saving private trip image';
          CloudFunction().logEvent(action);
          String urlForImage;
          final Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('trips/$key');
          final UploadTask uploadTask = storageReference.putFile(urlToImage);
          

          return await privateTripsCollectionUnordered.doc(key).update(<String, dynamic>{
            'urlToImage': await storageReference.getDownloadURL()
          });
        } catch (e) {
          CloudFunction()
              .logError('Error saving trip image (private):  ${e.toString()}');
        }
      }
    }
  }
  /// Convert trip (private or public)
  Future<void> convertTrip(Trip trip)
  async {
    if (!trip.ispublic) {
      try {
        const String action = 'Converting trip from private to public';
        CloudFunction().logEvent(action);
        await tripsCollectionUnordered.doc(trip.documentId).set(
            <String, dynamic>{
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
          const String action = 'Deleting private trip after converting '
              'to public';
          CloudFunction().logEvent(action);
           privateTripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          CloudFunction().logError('Error deleting private trip after '
              'converting to public trip:  ${e.toString()}');
        }
        for (final String member in trip.accessUsers) {
          CloudFunction().addMember(trip.documentId, member);
        }
      } catch (e) {
        CloudFunction()
            .logError('Error converting to public trip: ''${e.toString()}');
        _analyticsService
            .writeError('Error converting to public trip:  ''${e.toString()}');
      }
    } else {
      try {
        const String action = 'Converting trip from public to private';
        CloudFunction().logEvent(action);
        await privateTripsCollectionUnordered.doc(trip.documentId)
            .set(<String, dynamic>{
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
          const String action = 'Deleting public trip after converting it to private';
          CloudFunction().logEvent(action);
           tripsCollectionUnordered.doc(trip.documentId).delete();
        } catch (e){
          CloudFunction().logError('Deleting public trip after converting it to private: ${e.toString()}');
        }
        for (final String member in trip.accessUsers) {
          CloudFunction().addPrivateMember(trip.documentId, member);
        }
      }
      catch (e) {
        _analyticsService.writeError('Error converting to private trip:  ${e.toString()}');
        CloudFunction().logError('Error converting to private trip:  ${e.toString()}');
      }
    }
  }


/// Edit Trip
  Future<void> editTripData(
      String comment,
      String documentID,
      String endDate,
      Timestamp endDateTimeStamp,
      bool ispublic,
      String location,
      String startDate,
      Timestamp startDateTimeStamp,
      String travelType,
      File? urlToImage,
      String tripName,
      GeoPoint? tripGeoPoint)
  async {
    print('Image file: ${urlToImage?.path}');
    final DocumentReference<Object?> addTripRef = ispublic ? tripsCollectionUnordered.doc(documentID) : privateTripsCollectionUnordered.doc(documentID);
    final UserPublicProfile userPublicProfile = await getUserProfile(userService.currentUserID);

    try {
      const String action = 'Editing Trip';
      CloudFunction().logEvent(action);
      await addTripRef.update(<String, dynamic>{
        'comment': comment,
        'displayName': userPublicProfile.displayName,
        'endDate': endDate,
        'endDateTimeStamp': endDateTimeStamp,
        'ispublic': ispublic,
        'location': location,
        'startDate': startDate,
        'startDateTimeStamp': startDateTimeStamp,
        'tripName': tripName,
        'tripGeoPoint': tripGeoPoint,
        'travelType': travelType,
      });
    } catch (e) {
      CloudFunction().logError('Error editing public trip:  ${e.toString()}');
    }
    try {
      const String action = 'Updating image after editing trip';
      CloudFunction().logEvent(action);
      if (urlToImage != null) {
        final Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('trips/${addTripRef.id}');
        storageReference.putFile(urlToImage);

        return await addTripRef.update(<String, dynamic>{
          'urlToImage': await storageReference.getDownloadURL()
        });
      }
    } catch (e) {
      CloudFunction().logError('Error updating image after editing trip:  ${e.toString()}');
    }
  }

  ////Retrieve current user's following list
  Future<UserPublicProfile?> followingList() async{
    final DocumentSnapshot<Object?> ref = await userPublicProfileCollection.doc(userService.currentUserID).get();
    if(ref.exists){
      return UserPublicProfile.fromDocument(ref);
    }
    // else {
    //   return UserPublicProfile();
    // }
    return null;
  }
  /// Get following list
  Stream<List<UserPublicProfile>> retrieveFollowingList() async*{
      final List<UserPublicProfile> user = await usersList();
      final UserPublicProfile? followingRef = await followingList();
      if(followingRef != null){
        final List<UserPublicProfile> ref =
        user.where((UserPublicProfile user) => followingRef
            .following
        .contains(user.uid))
            .toList();

        yield ref;
      }

  }

  ////Stream following list
  Stream<List<UserPublicProfile>> retrieveFollowList(
      UserPublicProfile currentUser) async*{
    try {
      final List<UserPublicProfile> user = await usersList();
      final List<dynamic> followList =
      List<dynamic>.from(currentUser.following)
        ..addAll(currentUser.followers);
      final List<UserPublicProfile> newList =
      user.where((UserPublicProfile user) => followList.contains(user.uid)).toList();
      yield newList;
    } catch(e){
      CloudFunction().logError('Error retrieving follow list:  ${e.toString()}');
    }
  }

  
  ////Retrieve bringing list
  List<Bringing> _retrieveBringingItems(QuerySnapshot<Object?> snapshot) {
    
          return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
            final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
              return Bringing.fromData(data);
                }).toList();
  }
  ////Stream Bringing list
  Stream<List<Bringing>> getBringingList(String docID){
    return bringListCollection.doc(docID).collection('Items')
        .snapshots().map(_retrieveBringingItems);
  }

  Stream<List<Bringing>> get bringingList{
    return bringListCollection.doc(tripDocID).collection('Items')
        .snapshots().map(_retrieveBringingItems);
  }

  List<Need> _retrieveNeedItems(QuerySnapshot<Object?> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        return Need.fromData(data);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving need list:  ${e.toString()}');
      return <Need>[];
    }
  }
  Stream<List<Need>> getNeedList(String docID){
    return needListCollection.doc(docID).collection('Items')
        .snapshots().map(_retrieveNeedItems);
  }

  ////Get all members from Trip
  Future<List<Members>> retrieveMembers(String docID, bool ispubic) async {
    if(ispubic) {
      try {
        const String action = 'Get all members from Trip';
        CloudFunction().logEvent(action);
        final QuerySnapshot<Object?> ref = await tripsCollectionUnordered.doc(docID).collection(
            'Members').get();
        final List<Members> memberList = ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return Members.fromDocument(doc);
        }).toList();
        memberList.sort((Members a, Members b) => a.lastName.compareTo(b.lastName));
        return memberList;
      } catch (e) {
        CloudFunction()
            .logError('Error retrieving all members from trip:  '
            '${e.toString()}');
        return <Members>[];
      }
    } else {
      try {
        const String action = 'Get all members from private trip';
        CloudFunction().logEvent(action);
        final QuerySnapshot<Object?> ref = await privateTripsCollectionUnordered.doc(docID).collection(
            'Members').get();

          final List<Members> memberList = ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
            return Members.fromDocument(doc);
          }).toList();
          memberList.sort((Members a, Members b) => a.lastName.compareTo(b.lastName));
          return memberList;
        } catch (e) {
        CloudFunction()
            .logError('Error retrieving members from private trip:  '
            '${e.toString()}');
        return <Members>[];
      }
    }


  }
  //// Get Trip Stream
  Trip? _tripFromSnapshot(DocumentSnapshot<Object?> snapshot) {
    try {
      if(snapshot.exists){
        return Trip.fromDocument(snapshot);
      }

    } catch (e) {
      CloudFunction()
          .logError('Error retrieving current trip list:  ${e.toString()}');
      return defaultTrip;
    }
    return null;
  }

  Stream<Trip?> get singleTripData {
    return tripsCollectionUnordered.doc(tripDocID)
      .snapshots().map(_tripFromSnapshot);}

  Future<List<Bringing>> getItems() async {

    final QuerySnapshot<Object?> ref = await bringListCollection
        .doc(tripDocID)
        .collection('Items')
        .get();
    try {
      const String action = 'Get bringing items by document ID';
      CloudFunction().logEvent(action);
        final List<Bringing> items = ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
          final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
          return Bringing.fromData(data);
        }).toList();
      return items;
    } catch (e) {
      CloudFunction()
          .logError('Error retrieving bringing items docID:  ${e.toString()}');
      return <Bringing>[];
    }


  }

  /// Get Trip
  Future<Trip> getTrip(String documentID) async {
    final DocumentSnapshot<Object?> ref = await tripsCollectionUnordered.doc(documentID).get();
    try {
      const String action = 'Get single trip by document ID';
      CloudFunction().logEvent(action);
      if (ref.exists){
        return Trip.fromDocument(ref);
      } else {
        return defaultTrip;
      }
    } catch (e) {
      CloudFunction()
          .logError('Error retrieving single trip by docID:  ${e.toString()}');
      return defaultTrip;
    }
  }
  /// Get Private Trip
  Future<Trip> getPrivateTrip(String documentID) async {

    final DocumentSnapshot<Object?> ref = await privateTripsCollectionUnordered.doc(documentID).get();
    try {
      const String action = 'Get single private trip by document ID';
      CloudFunction().logEvent(action);
      if (ref.exists){
        return Trip.fromDocument(ref);
      } else {
        return defaultTrip;
      }
    } catch (e) {
      CloudFunction()
          .logError('Error retrieving single private trip:  ${e.toString()}');
      return defaultTrip;
    }
  }

  

  //// Add new lodging
  Future<void> addNewLodgingData(String documentID, LodgingData lodging) async {

    final String key = lodgingCollection.doc().id;

    try {
      final String action = 'Add new lodging for $documentID';
      CloudFunction().logEvent(action);
      final DocumentReference<Map<String, dynamic>> addNewLodgingRef = lodgingCollection
          .doc(documentID)
          .collection('lodging')
          .doc(key);
      addNewLodgingRef.set(lodging.toJson());
      addNewLodgingRef.update(<String, dynamic>{
        'fieldID': key,
      });
    } catch (e) {
      CloudFunction().logError('Error adding new lodging data:  ${e.toString()}');
    }
  }

  //// Edit Lodging
  Future<void> editLodgingData(
      {String? comment,
      required String documentID,
      String? link,
      String? lodgingType,
      required String fieldID,
      String? location,
      Timestamp? endDateTimestamp,
      Timestamp? startDateTimestamp,
      String? startTime,
      String? endTime}) async {

    final DocumentReference<Map<String, dynamic>> editLodgingRef = lodgingCollection
        .doc(documentID)
        .collection('lodging')
        .doc(fieldID);

    try {
      final String action = 'Editing lodging for $documentID';
      CloudFunction().logEvent(action);
      editLodgingRef.update(
          <String,dynamic>{'comment': comment,
            'link': link,
            'lodgingType' : lodgingType,
            'startTime': startTime,
            'endTime': endTime,
            'startDateTimestamp': startDateTimestamp,
            'endDateTimestamp': endDateTimestamp,
            'location': location

          });
    } catch (e) {
      CloudFunction().logError('Error editing lodging:  ${e.toString()}');
      _analyticsService.writeError('Error editing lodging:  ${e.toString()}');
    }
  }


  //// Add new activity
  Future<void> addNewActivityData(
      ActivityData activityData, String documentID) async {
    final String key = activitiesCollection.doc().id;

    final DocumentReference<Map<String, dynamic>> addNewActivityRef = activitiesCollection
        .doc(documentID)
        .collection('activity')
        .doc(key);


    try {
      final String action = 'Add new activity for $documentID';
      CloudFunction().logEvent(action);
      addNewActivityRef.set(activityData.toJson());
      addNewActivityRef.update(<String, dynamic>{
        'fieldID': key,
        'dateTimestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      CloudFunction().logError('Error adding new activity:  ${e.toString()}');
      _analyticsService
          .writeError('Error adding new activity:  ${e.toString()}');
    }
    

  }

  //// Edit activity
  Future<void> editActivityData(
      {String? comment,
      required String displayName,
      required String documentID,
      String? link,
      String? activityType,
      required String fieldID,
      String? location,
      Timestamp? dateTimestamp,
      Timestamp? endDateTimestamp,
      Timestamp? startDateTimestamp,
      String? startTime,
      String? endTime}) async {

    final DocumentReference<Map<String, dynamic>> addNewActivityRef = activitiesCollection
        .doc(documentID)
        .collection('activity')
        .doc(fieldID);

    try {
      final String action = 'Editing activity for $documentID';
      CloudFunction().logEvent(action);
      addNewActivityRef.update(
          <String,dynamic>{'comment': comment,
        'displayName': displayName,
        'link': link,
        'activityType' : activityType,
        'urlToImage': '',
        'startTime': startTime,
        'endTime': endTime,
        'location': location,
        'endDateTimestamp': endDateTimestamp,
        'startDateTimestamp': startDateTimestamp,

      });
    } catch (e) {
      CloudFunction().logError('Error editing activity:  ${e.toString()}');
      _analyticsService.writeError('Error editing activity:  ${e.toString()}');
    }
  }

  ////Get Lodging item
  LodgingData _lodgingFromSnapshot(DocumentSnapshot<Object?> snapshot){
    if(snapshot.exists){
      try {
          return LodgingData.fromDocument(snapshot);
      } catch (e) {
        CloudFunction().logError('Error retrieving lodging list:  ${e.toString()}');
        return defaultLodgingData;
      }
    } else{
      return defaultLodgingData;
    }

  }
  ////Get specific Lodging
  Stream<LodgingData> get lodging {
    return lodgingCollection.doc(tripDocID).collection('lodging').doc(fieldID).snapshots().map(_lodgingFromSnapshot);
  }

  ///Get Activity item
  ActivityData _activityFromSnapshot(DocumentSnapshot<Object?> snapshot){
    if(snapshot.exists){
      try {
        return ActivityData.fromDocument(snapshot);
      } catch (e) {
        CloudFunction().logError('Error retrieving single activity:  ${e.toString()}');
        return defaultActivityData;
      }
    } else{
      return defaultActivityData;
    }

  }
  Stream<ActivityData> get activity {
    return activitiesCollection.doc(tripDocID).collection('activity').doc(fieldID).snapshots().map(_activityFromSnapshot);
  }

  ///Get all users Future Builder
  Future<List<UserPublicProfile>> usersList() async {
    try {
      final QuerySnapshot<Object?> ref = await userPublicProfileCollection.get();
      final List<UserPublicProfile> userList = ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
        // final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        return UserPublicProfile.fromDocument(doc);
      }).toList();
      userList.sort((UserPublicProfile a,UserPublicProfile b) => a.displayName.compareTo(b.displayName));
      return userList;
    } catch (e) {
      CloudFunction().logError('Error retrieving all users: ${e.toString()}');
      return <UserPublicProfile>[];
    }
    }


  /// Get current user public profile
  UserPublicProfile _userPublicProfileSnapshot(DocumentSnapshot<Object?> snapshot){
    try {
      // final Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
        return UserPublicProfile.fromDocument(snapshot);
    } catch (e) {
      CloudFunction().logError('Error retrieving specific user public profile:  ${e.toString()}');
      // return UserPublicProfile();
    }
    return defaultProfile;
  }

  /// get current use public profile
  Stream<UserPublicProfile> get currentUserPublicProfile {
    return userPublicProfileCollection.doc(userService.currentUserID).snapshots()
        .map(_userPublicProfileSnapshot);
  }

  Stream<UserPublicProfile> get specificUserPublicProfile {
    return userPublicProfileCollection.doc(userID).snapshots()
        .map(_userPublicProfileSnapshot);
  }

  ///Query for past My Crew Trips
  List<Trip> _pastCrewTripListFromSnapshot(QuerySnapshot<Object?> snapshot){

    try {
      final DateTime now = DateTime.now().toUtc();
      final DateTime past = DateTime(now.year, now.month, now.day - 1);
      final List<Trip> trips = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return Trip.fromDocument(doc);
      }).toList();
      final List<Trip> crewTrips = trips.where((Trip trip) =>
          trip.endDateTimeStamp.toDate().compareTo(past) == -1)
          .toList().reversed.toList();
      return crewTrips;
    } catch (e) {
      CloudFunction().logError('Error retrieving past trip list:  ${e.toString()}');
      return <Trip>[];
    }
  }

  Stream<List<Trip>> pastCrewTripsCustom(String uid) {
    return tripCollection.where('accessUsers', arrayContainsAny: <String>[uid]).snapshots()
        .map(_pastCrewTripListFromSnapshot);
  }


/// check uniqueness to avoid duplicate function calls or writes
   void addToUniqueDocs(String key2){
    try {
      const String action = 'creating unique key';
      CloudFunction().logEvent(action);
      uniqueCollection.doc(key2).set(<String, dynamic>{
      });
    } catch(e){
      CloudFunction().logError('Error creating unique ID: ${e.toString()}');
    }
  }

  /// Add new chat message
  Future<void> addNewChatMessage(String displayName, String message, String uid, Map<String,bool> status) async {
    final String key = chatCollection.doc().id;

    try {
      return await chatCollection.doc(tripDocID).collection('messages').doc(key).set(
          <String,dynamic>{
            'displayName': displayName,
            'fieldID': key,
            'message': message,
            'status': status,
            'timestamp': FieldValue.serverTimestamp(),
            'tripDocID':tripDocID,
            'uid': uid,
          });
    } catch (e) {
      _analyticsService.writeError('Error writing new chat:  ${e.toString()}');
      CloudFunction().logError('Error writing new chat:  ${e.toString()}');
    }

    /// try {
    ///   if (urlToImage != null) {
    ///     String urlForImage;
    ///     StorageReference storageReference = FirebaseStorage.instance
    ///         .ref()
    ///         .child('activity/$key');
    ///     StorageUploadTask uploadTask = storageReference.putFile(urlToImage);
    ///     await uploadTask.onComplete;
    ///     print('File Uploaded');
    ///
    ///     return await addNewActivityRef.update(<String, dynamic>{
    ///       "urlToImage": await storageReference.getDownloadURL().then((fileURL) {
    ///         urlForImage = fileURL;
    ///         return urlForImage;
    ///       })
    ///     });
    ///   }
    /// } catch (e) {
    ///   print('Error updating activity image: ${e.toString()}');
    /// }
  }

/// Clear chat notifications.
  Future<void> clearChatNotifications() async {
    try {
      final Query<Map<String, dynamic>> db = chatCollection.doc(tripDocID).collection('messages').where('status.$uid' ,isEqualTo: false);
      final QuerySnapshot<Object?> snapshot = await db.get();
      for(int i =0; i< snapshot.docs.length;i++) {
        chatCollection.doc(tripDocID).collection('messages').doc(snapshot.docs[i].id).update(<String, dynamic>{'status.$uid': true});
      }
    } catch (e) {
      CloudFunction().logError('Error clearing chat notifications:  ${e.toString()}');
    }
  }

  /// Get all chat messages
  List<ChatData> _chatListFromSnapshot(QuerySnapshot<Object?> snapshot){
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
        return ChatData.fromDocument(doc);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  ${e.toString()}');
      return <ChatData>[defaultChatData];
    }
  }
  Stream<List<ChatData>>? get chatListNotification {
    try {
      return chatCollection.doc(tripDocID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false).snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      CloudFunction().logError('Error retrieving chat list notifications:  ${e.toString()}');
      return null;
    }
  }

/// Feedback Data stream snapshot
  List<TCFeedback> _feedbackSnapshot (QuerySnapshot<Object?> snapshot) {

    final List<TCFeedback> feedback = snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return TCFeedback.fromDocument(doc);}).toList();
      feedback.sort((TCFeedback a,TCFeedback b) => b.timestamp.compareTo(a.timestamp));

      return feedback;

  }

  ///Stream Feedback data
  Stream<List<TCFeedback>> get feedback {
     return feedbackCollection.snapshots().map(_feedbackSnapshot);
  }



  /// Future<List<TCReports>> reports() async {
  ///   try {
  ///     var ref = await reportsCollection.get();
  ///     List<TCFeedback> feedback = ref.docs.map((doc) {
  ///       Map<String, dynamic> data = doc.data()!;
  ///       return TCFeedback(
  ///         message: data['message'] ?? '',
  ///         uid: data['uid'] ?? '',
  ///         timestamp: data['timestamp'] ?? null,
  ///       );
  ///     }).toList();
  ///     feedback.sort((a,b) => a.timestamp.compareTo(b.timestamp));
  ///
  ///     return feedback;
  ///   } catch (e) {
  ///     print(e.toString());
  ///   }
  /// }


  Future<void> createAd() async {
    final String key = adsCollection.doc().id;
    return adsCollection.doc(key).set(<String, dynamic>{
      'tripName': 'Cathedral Rock',
      'documentID' : key,
      'location': 'Sedona, Arizona',
      'dateCreated': FieldValue.serverTimestamp(),
      'clicks' : 0,
      'favorites': <String>[],
      'clickers': <String>[],
      'urlToImage': 'https:///www.tripstodiscover.com/wp-content/uploads/2016/10/bigstock-Cathedral-Rock-in-Sedona-Ariz-92403158-3-1.jpg',
    });
  }

  /// Add new direct message
  Future<void> addNewDMChatMessage(String displayName, String message, String uid, Map<String,dynamic> status) async {
    final String key = chatCollection.doc().id;

    final String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID!);

    final DocumentSnapshot<Object?> ref = await dmChatCollection.doc(chatID).get();
    if(!ref.exists) {
      await dmChatCollection.doc(chatID).set(<String, dynamic>{
        'ids': <String?>[userID, userService.currentUserID],
        'lastUpdatedTimestamp': FieldValue.serverTimestamp(),
      });
    } else{
      await dmChatCollection.doc(chatID).update(<String, dynamic>{
        'lastUpdatedTimestamp': FieldValue.serverTimestamp(),
      });
    }
    try {
      return await dmChatCollection.doc(chatID).collection('messages').doc(key).set(
          <String, dynamic>{
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
      CloudFunction().logError('Error writing new dm chat:  ${e.toString()}');
    }
  }
  /// Delete a chat message
  Future<void> deleteDMChatMessage({required ChatData message}) async {
    /// String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);
    try {
      return await dmChatCollection.doc(message.chatID).collection('messages').doc(message.fieldID).delete();
    } catch (e) {
      _analyticsService.writeError('Error deleting new chat:  ${e.toString()}');
      CloudFunction().logError('Error deleting dm chat message:  ${e.toString()}');
    }
  }

  /// Clear DM chat notifications.
  Future<void> clearDMChatNotifications() async {
    try {
      final String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID!);
      final Query<Map<String, dynamic>> db = dmChatCollection.doc(chatID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false);
      final QuerySnapshot<Object?> snapshot = await db.get();
      for (final QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        dmChatCollection.doc(chatID).collection('messages').doc(doc.id).update(<String, dynamic>{'status.${userService.currentUserID}': true});
      }
    } catch (e) {
      CloudFunction().logError('Error clearing dm chat notifications:  ${e.toString()}');
    }
  }

  /// Get all direct message chat messages
  Stream<List<ChatData>>? get dmChatList {
    try {
      final String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID!);
      return dmChatCollection.doc(chatID).collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      _analyticsService.writeError(e.toString());
      CloudFunction().logError('Error retrieving dm chat messages:  ${e.toString()}');
      return null;
    }
  }

  Stream<List<ChatData>>? get dmChatListNotification {
    final String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID!);
    try {
      return dmChatCollection.doc(chatID).collection('messages').where('status.${userService.currentUserID}' ,isEqualTo: false)
          .snapshots().map(_chatListFromSnapshot);
    }catch (e) {
      CloudFunction().logError('Error retrieving dm chat notifications:  ${e.toString()}');
      return null;
    }
  }

  /// Get user list of DM chats
  Stream<List<UserPublicProfile>> retrieveDMChats() async*{
    final List<String> uidsOfAllChats = <String>[];
    final List<UserPublicProfile> user = await usersList();
    final List<UserPublicProfile> sortedUserList = <UserPublicProfile>[];

      final QuerySnapshot<Object?> ref = await dmChatCollection.orderBy('lastUpdatedTimestamp',descending: true).where(
          'ids', arrayContains: userService.currentUserID).get();
      for (final QueryDocumentSnapshot<Object?> doc in ref.docs) {
        uidsOfAllChats.add(doc.id);
      }
      final List<String> idList = <String>[];
      for (final String id in uidsOfAllChats) {
        final List<String> y = id.split('_');
        y.remove(userService.currentUserID);
        idList.add(y[0]);
      }

      for (final String profile in idList) {
        sortedUserList.add(user.where((UserPublicProfile element) => profile == element.uid).first);
      }
    yield sortedUserList;
  }

  /// Get Access users for Crew list
  /// Get user list of DM chats
  Stream<List<UserPublicProfile>> getcrewList(List<String> accessUsers) async*{
    try {
      final List<UserPublicProfile> users = await usersList();
      yield users.where((UserPublicProfile user) => accessUsers.contains(user.uid)).toList();
    } catch (e) {
      CloudFunction().logError('Error in getcrewList for members layout: ${e.toString()}');
    }


  }


  Future<void>writeSuggestions() async{
    final CollectionReference<Object?> ref = suggestionsCollection;
    for (final String url in urls) {
      final String key = suggestionsCollection.doc().id;
      ref.doc(key).set(<String, dynamic>{
        'fieldID': key,
        'url': url,
        'timestamp': FieldValue.serverTimestamp(),
        'tags': <String>[],
      });
    }
  }

  /// Get all Suggestions
  List<Suggestions> _suggestionListFromSnapshot(QuerySnapshot<Object?> snapshot){

    return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
      final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
      return Suggestions(
        url: data['url'] as String,
        timestamp: data['timestamp'] as Timestamp,
        fieldID: data['fieldID'] as String,
      );
    }).toList();

  }

  Stream<List<Suggestions>> get suggestionList {
    return suggestionsCollection.snapshots().map(_suggestionListFromSnapshot);
  }

  /// Delete a suggestion
  Future<void> deleteSuggestion({required String fieldID}) async {
      return suggestionsCollection.doc(fieldID).delete();
  }

  ///Check if user already submitted or view app Review this month
  Future<bool> appReviewExists(String docID) async {
    final QuerySnapshot<Object?> ref = await addReviewCollection.doc(userService.currentUserID).collection('review').get();
    final bool reviewExists = ref.docs.contains(docID);
    return reviewExists;
  }

}
