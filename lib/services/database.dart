import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;



import '../../services/constants/constants.dart';
import '../../services/functions/cloud_functions.dart';
import '../../services/functions/tc_functions.dart';
import '../../services/locator.dart';
import '../../services/navigation/navigation_service.dart';
import '../../services/notifications/notifications.dart';
import '../features/Main_Page/logic/logic.dart';
import '../models/member_model/member_model.dart';
import '../models/public_profile_model/public_profile_model.dart';


UserService userService = locator<UserService>();
NavigationService navigationService = locator<NavigationService>();
ValueNotifier<String> urlToImage = ValueNotifier<String>('');
UserPublicProfile currentUserProfile =
    locator<UserProfileService>().currentUserProfileDirect();

////Database class for all firebase api functions
class DatabaseService {
  DatabaseService(
      {this.uid, this.fieldID, this.tripDocID, this.userID, this.itemDocID});
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
  // final AnalyticsService _analyticsService = AnalyticsService();

  ///  All collection references

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
  final CollectionReference<Object?> transportCollection =
      FirebaseFirestore.instance.collection('transport');

  final CollectionReference<Object?> activitiesCollection =
      FirebaseFirestore.instance.collection('activities');
  final CollectionReference<Object?> chatCollection =
      FirebaseFirestore.instance.collection('chat');
  final CollectionReference<Object?> notificationCollection =
      FirebaseFirestore.instance.collection('notifications');
  final CollectionReference<Object?> bringListCollection =
      FirebaseFirestore.instance.collection('bringList');
  final CollectionReference<Object?> needListCollection =
      FirebaseFirestore.instance.collection('needList');
  final CollectionReference<Object?> uniqueCollection =
      FirebaseFirestore.instance.collection('unique');

  final CollectionReference<Object?> reportsCollection =
      FirebaseFirestore.instance.collection('reports');
  final CollectionReference<Object?> adsCollection =
      FirebaseFirestore.instance.collection('tripAds');

  final CollectionReference<Object?> suggestionsCollection =
      FirebaseFirestore.instance.collection('suggestions');

  final CollectionReference<Object?> addReviewCollection =
      FirebaseFirestore.instance.collection('addReview');
  final CollectionReference<Object?> versionCollection =
      FirebaseFirestore.instance.collection('version');





  //// Shows latest app version to display in main menu.
  Future<String> getVersion() async {
    try {
      // TODO(Randy): change version doc for new releases
      final DocumentSnapshot<Object?> ref =
          await versionCollection.doc('version3_1_1').get();
      final Map<String, dynamic> data = ref.data()! as Map<String, dynamic>;
      final String version = data['version'] as String;
      if (version.isNotEmpty) {
        return version;
      } else {
        return '';
      }
    } catch (e) {
      CloudFunction().logError('Error retrieving version:  $e');
      return '';
    }
  }

  ////Get all members from Trip
  Future<List<MemberModel>> retrieveMembers(String docID, bool ispubic) async {
    if (ispubic) {
      try {
        const String action = 'Get all members from Trip';
        CloudFunction().logEvent(action);
        final QuerySnapshot<Object?> ref = await tripsCollectionUnordered
            .doc(docID)
            .collection('Members')
            .get();
        final List<MemberModel> memberList =
            ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return MemberModel.fromJson(doc as Map<String, Object>);
        }).toList();
        memberList
            .sort((MemberModel a, MemberModel b) => a.lastName.compareTo(b.lastName));
        return memberList;
      } catch (e) {
        CloudFunction().logError('Error retrieving all members from trip:  '
            '$e');
        return <MemberModel>[];
      }
    } else {
      try {
        const String action = 'Get all members from private trip';
        CloudFunction().logEvent(action);
        final QuerySnapshot<Object?> ref = await privateTripsCollectionUnordered
            .doc(docID)
            .collection('Members')
            .get();

        final List<MemberModel> memberList =
            ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return MemberModel.fromJson(doc as Map<String, Object>);
        }).toList();
        memberList
            .sort((MemberModel a, MemberModel b) => a.lastName.compareTo(b.lastName));
        return memberList;
      } catch (e) {
        CloudFunction().logError('Error retrieving members from private trip:  '
            '$e');
        return <MemberModel>[];
      }
    }
  }


  /// check uniqueness to avoid duplicate function calls or writes
  void addToUniqueDocs(String key2) {
    try {
      const String action = 'creating unique key';
      CloudFunction().logEvent(action);
      uniqueCollection.doc(key2).set(<String, dynamic>{});
    } catch (e) {
      CloudFunction().logError('Error creating unique ID: $e');
    }
  }





  ///Check if user already submitted or view app Review this month
  Future<bool> appReviewExists(String docID) async {
    final QuerySnapshot<Object?> ref = await addReviewCollection
        .doc(userService.currentUserID)
        .collection('review')
        .get();
    final bool reviewExists = ref.docs.contains(docID);
    return reviewExists;
  }

  Future<void> writeData(List<String> data) async {
    try {
      await Future.forEach(data, (String item) async {
        final DocumentReference<Object?> doc = recTripCollection.doc();
        doc.set(<String, dynamic>{
          'name': item,
          'clicks': 0,
          'dateCreated': FieldValue.serverTimestamp(),
          'docID': doc.id,
          'urlToImage': ''
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> updateUrlToImage() async {
    final collection = recActivityCollection;
    final documents = await collection.get();

    for (final document in documents.docs) {
      await collection.doc(document.id).update({
        'urlToImage': <String>['']
      });
    }
  }



}
