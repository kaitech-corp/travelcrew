import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

final FirebaseMessaging _fcm = FirebaseMessaging.instance;
final CollectionReference<Object?> userCollection =
    FirebaseFirestore.instance.collection('users');
final CollectionReference<Object?> userPublicProfileCollection =
    FirebaseFirestore.instance.collection('userPublicProfile');
final Query<Object?> allUsersCollection = FirebaseFirestore.instance
    .collection('userPublicProfile')
    .orderBy('lastname')
    .orderBy('firstname');
final CollectionReference<Object?> tokensCollection =
    FirebaseFirestore.instance.collection('tokens');
final Query<Object?> tripCollection = FirebaseFirestore.instance
    .collection('trips')
    .orderBy('endDateTimeStamp')
    .where('ispublic', isEqualTo: true);



///Updates user info after signup
Future<void> updateUserData(String email, String uid) async {
  try {
    const String action = 'Updating User data.';
    CloudFunction().logEvent(action);
    return await userCollection
        .doc(uid)
        .set(<String, dynamic>{'email': email, 'uid': uid});
  } catch (e) {
    CloudFunction().logError('Error updating user data:  $e');
  }
}

////Save device token to use in cloud messaging.
Future<void> saveDeviceToken() async {
  try {
    /// Get the token for this device
    final String? fcmToken = await _fcm.getToken();
    final DocumentSnapshot<Map<String, dynamic>> ref = await tokensCollection
        .doc(userService.currentUserID)
        .collection('tokens')
        .doc(fcmToken)
        .get();

    /// Save it to Firestore
    if (!ref.exists || ref.id != fcmToken) {
      if (fcmToken != null) {
        final DocumentReference<Map<String, dynamic>> tokens =
            tokensCollection.doc(userService.currentUserID).collection('tokens').doc(fcmToken);

        await tokens.set(<String, dynamic>{
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(),

          /// optional
          'platform': Platform.operatingSystem

          /// optional
        });
      }
    }
  } catch (e) {
    CloudFunction().logError('Error saving token:  $e');
  }
}

////Checks whether user has a Public Profile on Firestore to know whether to
//// send user to complete profile page or not.
Future<bool> checkUserHasProfile() async {
  final DocumentReference<Object?> ref = userCollection.doc(userService.currentUserID);
  final DocumentSnapshot<Object?> refSnapshot = await ref.get();
  if (refSnapshot.exists) {
    saveDeviceToken();
  }

  return refSnapshot.exists;
}

////Retrieve profile image
Future<String?> currentUserImage() async {
  final DocumentSnapshot<Object?> ref =
      await userPublicProfileCollection.doc(userService.currentUserID).get();

  if (ref.exists) {
    return UserPublicProfile.fromJson(ref as Map<String, Object>).urlToImage;
  }
  return '';
}

////Updates public profile after sign up
Future<void> updateUserPublicProfileData(
    {String? displayName,
   required String email,
   required String uid,
}) async {
  final DocumentReference<Object?> ref = userPublicProfileCollection.doc(uid);
  if (displayName?.isEmpty ?? true) {
      displayName =
          'User${uid.substring(uid.length - 5)}';
    }
  try {
    const String action = 'Updating public profile after sign up';
    CloudFunction().logEvent(action);
    await ref.set(<String, dynamic>{
      'blockedList': <String>[],
      'displayName': displayName,
      'email': email,
      'followers': <String>[],
      'following': <String>[],
      'firstName': '',
      'lastName': '',
      'uid': uid,
      'urlToImage': '',
      'hometown': '',
      'topDestinations': <String>['', '', ''],
    });
  } catch (e) {
    CloudFunction().logError('Error creating public profile:  $e');
  }
}

//// Edit Public Profile page
Future<void> editPublicProfileData(
    UserPublicProfile userProfile, File urlToImage) async {
  final DocumentReference<Object?> ref =
      userPublicProfileCollection.doc(userProfile.uid);
  try {
    const String action = 'Editing Public Profile page';
    CloudFunction().logEvent(action);
    await ref.update(<String, dynamic>{
      'displayName': userProfile.displayName,
      'firstName': userProfile.firstName,
      'lastName': userProfile.lastName,
      'hometown': userProfile.hometown,
      'instagramLink': userProfile.instagramLink,
      'facebookLink': userProfile.facebookLink,
      'topDestinations': userProfile.topDestinations,
    });
  } catch (e) {
    CloudFunction().logError('Error editing public profile:  $e');
    if (kDebugMode) {
      print('Error Editing Profile: $e');
    }
  }
  if (urlToImage != null) {
    String urlForImage;

    try {
      const String action = 'Saving user profile picture after editing '
          'Public Profile page';
      CloudFunction().logEvent(action);
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('users/${userService.currentUserID}');
      final UploadTask uploadTask = storageReference.putFile(urlToImage);

      return await ref.update(<String, dynamic>{
        'urlToImage':
            await storageReference.getDownloadURL().then((String fileURL) {
          urlForImage = fileURL;
          return urlForImage;
        })
      });
    } catch (e) {
      CloudFunction().logError('Error editing Public Profile with image url:  '
          '$e');
    }
  }
}

////Retrieve current user's following list
Future<UserPublicProfile?> followingList() async {
  final DocumentSnapshot<Object?> ref =
      await userPublicProfileCollection.doc(userService.currentUserID).get();
  if (ref.exists) {
    return UserPublicProfile.fromJson(ref as Map<String, Object>);
  }
  // else {
  //   return UserPublicProfile();
  // }
  return null;
}

/// Get following list
Stream<List<UserPublicProfile>> retrieveFollowingList() async* {
  final List<UserPublicProfile> user = await usersList();
  final UserPublicProfile? followingRef = await followingList();
  if (followingRef != null) {
    final List<UserPublicProfile> ref = user
        .where((UserPublicProfile user) =>
            followingRef.following!.contains(user.uid))
        .toList();

    yield ref;
  }
}

////Stream following list
Stream<List<UserPublicProfile>> retrieveFollowList(
    UserPublicProfile currentUser) async* {
  try {
    final List<UserPublicProfile> user = await usersList();
    final List<dynamic> followList = List<dynamic>.from(currentUser.following!)
      ..addAll(currentUser.followers!);
    final List<UserPublicProfile> newList = user
        .where((UserPublicProfile user) => followList.contains(user.uid))
        .toList();
    yield newList;
  } catch (e) {
    CloudFunction().logError('Error retrieving follow list:  $e');
  }
}

/// Get current user public profile
UserPublicProfile _userPublicProfileSnapshot(
    DocumentSnapshot<Object?> snapshot) {
  try {
    return UserPublicProfile.fromJson(snapshot.data() as Map<String, dynamic>);
  } catch (e) {
    CloudFunction()
        .logError('Error retrieving specific user public profile:  $e');
    // return UserPublicProfile();
  }
  return UserPublicProfile.mock();
}

/// get current use public profile
Stream<UserPublicProfile> get currentUserPublicProfile {
  return userPublicProfileCollection
      .doc(userService.currentUserID)
      .snapshots()
      .map(_userPublicProfileSnapshot);
}

///Query for past My Crew Trips
List<Trip> _pastCrewTripListFromSnapshot(QuerySnapshot<Object?> snapshot) {
  try {
    final DateTime now = DateTime.now().toUtc();
    final DateTime past = DateTime(now.year, now.month, now.day - 1);
    final List<Trip> trips =
        snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
      return Trip.fromJson(doc.data() as Map<String, dynamic>);
    }).toList();
    final List<Trip> crewTrips = trips
        .where((Trip trip) => trip.endDateTimeStamp!.compareTo(past) == -1)
        .toList()
        .reversed
        .toList();
    return crewTrips;
  } catch (e) {
    CloudFunction().logError('Error retrieving past trip list:  $e');
    return <Trip>[];
  }
}

Stream<List<Trip>> pastCrewTripsCustom(String uid) {
  return tripCollection
      .where('accessUsers', arrayContainsAny: <String>[uid])
      .snapshots()
      .map(_pastCrewTripListFromSnapshot);
}

///Get all users Future Builder
Future<List<UserPublicProfile>> usersList() async {
  try {
    final QuerySnapshot<Object?> ref = await userPublicProfileCollection.get();
    final List<UserPublicProfile> userList = ref.docs
        .map((QueryDocumentSnapshot<Object?> doc) {
          final Object? data = doc.data();
          if (data != null) {
            return UserPublicProfile.fromJson(data as Map<String, dynamic>);
          } else {
            // Handle the case when data is null
            return null;
          }
        })
        .whereType<UserPublicProfile>()
        .toList();
    userList.sort((UserPublicProfile a, UserPublicProfile b) =>
        a.displayName.compareTo(b.displayName));
    return userList;
  } catch (e) {
    print('Error retrieving all users: $e');
    CloudFunction().logError('Error retrieving all users: $e');
    return <UserPublicProfile>[];
  }
}
