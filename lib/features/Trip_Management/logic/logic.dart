import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../models/trip_model/trip_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

final Query<Object?> tripCollection = FirebaseFirestore.instance
    .collection('trips')
    .orderBy('endDateTimeStamp')
    .where('ispublic', isEqualTo: true);
final Query<Object?> privateTripCollection = FirebaseFirestore.instance
    .collection('privateTrips')
    .orderBy('endDateTimeStamp');
final CollectionReference<Object?> tripsCollectionUnordered =
    FirebaseFirestore.instance.collection('trips');
final CollectionReference<Object?> privateTripsCollectionUnordered =
    FirebaseFirestore.instance.collection('privateTrips');
final CollectionReference<Object?> userCollection =
    FirebaseFirestore.instance.collection('users');
final CollectionReference<Object?> userPublicProfileCollection =
    FirebaseFirestore.instance.collection('userPublicProfile');
//// Add new trip
Future<void> addNewTripData(Trip trip, File? urlToImage) async {
  final UserPublicProfile currentUserProfile =
      await getUserProfile(userService.currentUserID);
  final String key = tripsCollectionUnordered.doc().id;
  final DocumentReference<Object?> addTripRef = (trip.ispublic)
      ? tripsCollectionUnordered.doc(key)
      : privateTripsCollectionUnordered.doc(key);
  try {
    const String action = 'Adding new trip';
    CloudFunction().logEvent(action);
    addTripRef.set(<String, dynamic>{
      'favorite': <String>[],
      'accessUsers': <String>[userService.currentUserID],
      'comment': trip.comment,
      'dateCreatedTimeStamp': FieldValue.serverTimestamp(),
      'displayName': currentUserProfile.displayName,
      'documentId': key,
      'endDateTimeStamp': trip.endDateTimeStamp,
      'ispublic': trip.ispublic,
      'location': trip.location,
      'ownerID': userService.currentUserID,
      'startDateTimeStamp': trip.startDateTimeStamp,
      'tripName': trip.tripName,
      'tripGeoPoint': trip.tripGeoPoint,
      'travelType': trip.travelType,
      'urlToImage': '',
    });
  } catch (e) {
    if (trip.ispublic) {
      CloudFunction().logError('Error saving new public trip:  $e');
    } else {
      CloudFunction().logError('Error saving new private trip:  $e');
    }
  }
  try {
    const String action = 'Saving member data to new Trip';
    CloudFunction().logEvent(action);
    addTripRef
        .collection('Members')
        .doc(userService.currentUserID)
        .set(<String, dynamic>{
      'displayName': currentUserProfile.displayName,
      'firstName': currentUserProfile.firstName,
      'lastname': currentUserProfile.lastName,
      'uid': userService.currentUserID,
      'urlToImage': '',
    });
  } catch (e) {
    CloudFunction().logError('Error saving member data to new trip:  $e');
  }

  try {
    const String action = 'Saving member data to new private Trip';
    CloudFunction().logEvent(action);
    addTripRef
        .collection('Members')
        .doc(userService.currentUserID)
        .set(<String, dynamic>{
      'displayName': currentUserProfile.displayName,
      'firstName': currentUserProfile.firstName,
      'lastName': currentUserProfile.lastName,
      'uid': userService.currentUserID,
      'urlToImage': '',
    });
  } catch (e) {
    CloudFunction().logError('Error saving member data to new private trip:  '
        '$e');
  }
  try {
    const String action = 'adding user uid to trip access members field';
    CloudFunction().logEvent(action);
    await userCollection
        .doc(userService.currentUserID)
        .update(<String, dynamic>{
      'trips': FieldValue.arrayUnion(<String>[key])
    });
  } catch (e) {
    CloudFunction()
        .logError('Error adding user to access users (Public Trip):  '
            '$e');
  }

  ///     await addTripRef.update(<String, dynamic>{"documentId": addTripRef.id});

  if (urlToImage != null) {
    try {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('trips/${addTripRef.id}');
      await storageReference.putFile(urlToImage);

      Future<void>.delayed(const Duration(milliseconds: 250), () async {
        addTripRef.update(<String, dynamic>{
          'urlToImage': await storageReference.getDownloadURL()
        });
      });
      return;
    } catch (e) {
      CloudFunction().logError('Error saving trip image:  '
          '$e');
    }
  }
}

/// Convert trip (private or public)
Future<void> convertTrip(Trip trip) async {
  if (!trip.ispublic) {
    try {
      const String action = 'Converting trip from private to public';
      CloudFunction().logEvent(action);
      await tripsCollectionUnordered.doc(trip.documentId).set(<String, dynamic>{
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
      } catch (e) {
        CloudFunction().logError('Error deleting private trip after '
            'converting to public trip:  $e');
      }
      for (final String member in trip.accessUsers) {
        CloudFunction().addMember(trip.documentId, member);
      }
    } catch (e) {
      CloudFunction().logError('Error converting to public trip: ' '$e');
    }
  } else {
    try {
      const String action = 'Converting trip from public to private';
      CloudFunction().logEvent(action);
      await privateTripsCollectionUnordered
          .doc(trip.documentId)
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
        const String action =
            'Deleting public trip after converting it to private';
        CloudFunction().logEvent(action);
        tripsCollectionUnordered.doc(trip.documentId).delete();
      } catch (e) {
        CloudFunction().logError(
            'Deleting public trip after converting it to private: $e');
      }
      for (final String member in trip.accessUsers) {
        CloudFunction().addPrivateMember(trip.documentId, member);
      }
    } catch (e) {
      CloudFunction().logError('Error converting to private trip:  $e');
    }
  }
}

/// Edit Trip
Future<void> editTripData(
    String comment,
    String documentID,
    String endDate,
    DateTime endDateTimeStamp,
    bool ispublic,
    String location,
    String startDate,
    DateTime startDateTimeStamp,
    String travelType,
    File? urlToImage,
    String tripName,
    GeoPoint? tripGeoPoint) async {
  final DocumentReference<Object?> addTripRef = ispublic
      ? tripsCollectionUnordered.doc(documentID)
      : privateTripsCollectionUnordered.doc(documentID);
  final UserPublicProfile userPublicProfile =
      await getUserProfile(userService.currentUserID);

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
    CloudFunction().logError('Error editing public trip:  $e');
  }
  try {
    const String action = 'Updating image after editing trip';
    CloudFunction().logEvent(action);
    if (urlToImage != null) {
      final Reference storageReference =
          FirebaseStorage.instance.ref().child('trips/${addTripRef.id}');
      storageReference.putFile(urlToImage);

      return await addTripRef.update(<String, dynamic>{
        'urlToImage': await storageReference.getDownloadURL()
      });
    }
  } catch (e) {
    CloudFunction().logError('Error updating image after editing trip:  $e');
  }
}

Future<UserPublicProfile> getUserProfile(String uid) async {
  try {
    final DocumentSnapshot<Object?> userData =
        await userPublicProfileCollection.doc(uid).get();
    if (userData.exists) {
      return UserPublicProfile.fromJson(userData.data() as Map<String, dynamic>);
    }
  } catch (e) {
    CloudFunction().logError('Error retrieving single user profile:  $e');
    print('Error retrieving single user profile:  $e');
    // return ;
  }

  return UserPublicProfile.mock();
}

/// Get Trip
  Future<Trip> getTrip(String documentID) async {
    final DocumentSnapshot<Object?> ref =
        await tripsCollectionUnordered.doc(documentID).get();
    try {
      const String action = 'Get single trip by document ID';
      CloudFunction().logEvent(action);
      if (ref.exists) {
        return Trip.fromJson(ref as Map<String, Object>);
      } else {
        return Trip.mock();
      }
    } catch (e) {
      CloudFunction().logError('Error retrieving single trip by docID:  $e');
      return Trip.mock();
    }
  }

  /// Get Private Trip
  Future<Trip> getPrivateTrip(String documentID) async {
    final DocumentSnapshot<Object?> ref =
        await privateTripsCollectionUnordered.doc(documentID).get();
    try {
      const String action = 'Get single private trip by document ID';
      CloudFunction().logEvent(action);
      if (ref.exists) {
        return Trip.fromJson(ref as Map<String, Object>);
      } else {
        return Trip.mock();
      }
    } catch (e) {
      CloudFunction().logError('Error retrieving single private trip:  $e');
      return Trip.mock();
    }
  }