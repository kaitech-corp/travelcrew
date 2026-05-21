import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/join_request_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_member_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/debugging.dart';

import '../models/activity_model.dart';
import '../models/expense_model.dart';
import '../models/trip_model.dart';
import '../models/user_flight_model.dart';
import 'session_services.dart';

final functions = FirebaseFunctions.instance;

class FirebaseTripService {
  static CollectionReference<Map<String, dynamic>> _tripActivitiesRef(
    String tripId,
  ) {
    return firestore
        .collection(kTripTable)
        .doc(tripId)
        .collection(kTripActivitiesSubCollection);
  }

  static CollectionReference<Map<String, dynamic>> _tripExpensesRef(
    String tripId,
  ) {
    return firestore
        .collection(kTripTable)
        .doc(tripId)
        .collection(kTripExpensesSubCollection);
  }

  static CollectionReference<Map<String, dynamic>> _tripFlightsRef(
    String tripId,
  ) {
    return firestore
        .collection(kTripTable)
        .doc(tripId)
        .collection(kTripFlightsSubCollection);
  }

  static CollectionReference<Map<String, dynamic>> _tripMembersRef(
    String tripId,
  ) {
    return firestore
        .collection(kTripTable)
        .doc(tripId)
        .collection(kTripMembersSubCollection);
  }

  static CollectionReference<Map<String, dynamic>> _tripJoinRequestsRef(
    String tripId,
  ) {
    return firestore
        .collection(kTripTable)
        .doc(tripId)
        .collection(kTripJoinRequestsSubCollection);
  }

  static DocumentReference<Map<String, dynamic>> _userTripMembershipRef({
    required String userId,
    required String tripId,
  }) {
    return firestore
        .collection(kUsersCollection)
        .doc(userId)
        .collection(kUserTripMembershipsSubCollection)
        .doc(tripId);
  }

  static Future<void> _hydrateMemberOnlyTrip(TripModel trip) async {
    trip.expenses = await getTripExpenses(tripId: trip.id);
    trip.activities = await getTripActivities(tripId: trip.id);
    trip.flights = await getTripFlights(tripId: trip.id);
    final memberIds = await getTripMemberIds(tripId: trip.id);
    if (memberIds.isNotEmpty) {
      trip.joinedUsers =
          memberIds.where((uid) => uid != trip.createdBy).toList();
      trip.joindUsersList = await AuthService.getTripUsers(userIds: memberIds);
    } else if (trip.joinedUsers != null && trip.joinedUsers!.isNotEmpty) {
      final legacyIds = <String>{trip.createdBy, ...trip.joinedUsers!}.toList();
      trip.joindUsersList = await AuthService.getTripUsers(userIds: legacyIds);
    } else {
      trip.joindUsersList = [];
    }
    trip.createdByUser = await AuthService.getUserPublicProfile(
      userId: trip.createdBy,
    );
  }

  static Future<List<String>> getTripMemberIds({required String tripId}) async {
    try {
      final snapshot =
          await _tripMembersRef(
            tripId,
          ).where('status', isEqualTo: 'active').get();
      return snapshot.docs
          .map((doc) => doc.data()['userId'] as String? ?? doc.id)
          .where((uid) => uid.isNotEmpty)
          .toList();
    } catch (e) {
      kLogging('error $e');
      return [];
    }
  }

  static Future<bool> isTripMember({
    required String tripId,
    required String userId,
  }) async {
    try {
      final memberDoc = await _tripMembersRef(tripId).doc(userId).get();
      if (memberDoc.exists && memberDoc.data()?['status'] == 'active') {
        return true;
      }
      final tripDoc = await firestore.collection(kTripTable).doc(tripId).get();
      final data = tripDoc.data();
      if (data == null) return false;
      return data['createdBy'] == userId ||
          ((data['joinedUsers'] as List<dynamic>?)?.contains(userId) ?? false);
    } catch (e) {
      kLogging('error $e');
      return false;
    }
  }

  static Future<List<TripModel>> getMyTrips({
    String? tripStatus,
    bool isAll = false,
  }) async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return [];
      final docsById = <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};
      late QuerySnapshot<Map<String, dynamic>> snapShot;
      if (tripStatus == null) {
        snapShot =
            await firestore
                .collection(kTripTable)
                .where('createdBy', isEqualTo: uid)
                .where(
                  'tripStatus',
                  whereIn:
                      isAll
                          ? [
                            TripStatus.upcoming.name,
                            TripStatus.completed.name,
                            TripStatus.deleted.name,
                            TripStatus.cancelled.name,
                          ]
                          : [
                            TripStatus.upcoming.name,
                            TripStatus.completed.name,
                          ],
                )
                .limit(50)
                .get();
      } else {
        snapShot =
            await firestore
                .collection(kTripTable)
                .where('tripStatus', isEqualTo: tripStatus)
                .where('createdBy', isEqualTo: uid)
                .limit(50)
                .get();
      }
      for (final doc in snapShot.docs) {
        docsById[doc.id] = doc;
      }

      final membershipSnap =
          await firestore
              .collection(kUsersCollection)
              .doc(uid)
              .collection(kUserTripMembershipsSubCollection)
              .where('status', isEqualTo: 'active')
              .limit(50)
              .get();
      final membershipTripIds =
          membershipSnap.docs
              .map((doc) => doc.data()['tripId'] as String? ?? doc.id)
              .where((id) => id.isNotEmpty && !docsById.containsKey(id))
              .toList();
      for (var i = 0; i < membershipTripIds.length; i += 10) {
        final chunk = membershipTripIds.skip(i).take(10).toList();
        final membershipTrips =
            await firestore
                .collection(kTripTable)
                .where(FieldPath.documentId, whereIn: chunk)
                .get();
        for (final doc in membershipTrips.docs) {
          final status = doc.data()['tripStatus'] as String?;
          final include =
              tripStatus == null
                  ? isAll ||
                      status == TripStatus.upcoming.name ||
                      status == TripStatus.completed.name
                  : status == tripStatus;
          if (include) docsById[doc.id] = doc;
        }
      }

      final futures =
          docsById.values.map((e) async {
            final TripModel tripModel = TripModel.fromMap(e.data());
            await _hydrateMemberOnlyTrip(tripModel);
            return tripModel;
          }).toList();
      final list = await Future.wait(futures);
      kLogging('future Fetched trips: ${list.length}');
      list.sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });
      return list;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return [];
  }

  static Future<TripModel?> getTripById({required String tripId}) async {
    try {
      final snapshot = await firestore.collection(kTripTable).doc(tripId).get();
      if (snapshot.exists) {
        final TripModel trip = TripModel.fromMap(snapshot.data()!);
        await _hydrateMemberOnlyTrip(trip);
        return trip;
      }
    } catch (e) {
      kLogging('error $e');
    }
    return null;
  }

  static Future<List<TripDiscoveryModel>> getOtherTrips() async {
    try {
      final snapshot =
          await firestore
              .collection(kTripDiscoveryTable)
              .where('isDiscoverable', isEqualTo: true)
              .limit(50)
              .get();

      final filteredDocs =
          snapshot.docs.where((doc) {
            final data = doc.data();
            return data['tripStatus'] != TripStatus.deleted.name &&
                data['createdBy'] != GlobalVariables.loggedInUser.value?.uid;
          }).toList();

      return filteredDocs
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  static Future<bool> addTrip({required TripModel tripModel}) async {
    try {
      final tripRef = firestore.collection(kTripTable).doc(tripModel.id);
      final batch = firestore.batch();
      batch.set(tripRef, tripModel.toMap());
      batch.set(
        _tripMembersRef(tripModel.id).doc(tripModel.createdBy),
        TripMemberModel(userId: tripModel.createdBy, role: 'creator').toMap(),
      );
      batch.set(
        _userTripMembershipRef(
          userId: tripModel.createdBy,
          tripId: tripModel.id,
        ),
        {
          'tripId': tripModel.id,
          'role': 'creator',
          'status': 'active',
          'joinedAt': FieldValue.serverTimestamp(),
        },
      );
      if (tripModel.isPrivate != true &&
          tripModel.tripStatus != TripStatus.deleted.name) {
        final creator = await AuthService.getUserPublicProfile(
          userId: tripModel.createdBy,
        );
        batch.set(
          firestore.collection(kTripDiscoveryTable).doc(tripModel.id),
          TripDiscoveryModel.fromTrip(
            tripModel,
            creatorDisplayName: creator?.displayName,
            creatorProfileImage: creator?.profileImage,
          ).toMap(),
        );
      }
      await batch.commit();
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> addExpenses({required ExpenseModel expense}) async {
    try {
      await _tripExpensesRef(
        expense.tripId,
      ).doc(expense.id).set(expense.toMap());
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
      return false;
    }
  }

  static Future<bool> addActivity({required ActivityModel activity}) async {
    try {
      await _tripActivitiesRef(
        activity.tripId,
      ).doc(activity.id).set(activity.toMap());
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
      return false;
    }
  }

  static Future<List<ExpenseModel>> getTripExpenses({
    required String tripId,
  }) async {
    try {
      final snapshot = await _tripExpensesRef(tripId).get();
      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((e) => ExpenseModel.fromMap(e.data()))
            .toList();
      }
      final legacySnapshot =
          await firestore
              .collection(kExpenseTable)
              .where('tripId', isEqualTo: tripId)
              .get();
      return legacySnapshot.docs
          .map((e) => ExpenseModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      kLogging('error $e');
    }
    return [];
  }

  static Future<List<ActivityModel>> getTripActivities({
    required String tripId,
  }) async {
    try {
      var snapshot = await _tripActivitiesRef(tripId).get();
      if (snapshot.docs.isEmpty) {
        snapshot =
            await firestore
                .collection(kActivityTable)
                .where('tripId', isEqualTo: tripId)
                .get();
      }
      return snapshot.docs.map((e) {
        final ActivityModel activityModel = ActivityModel.fromMap(e.data());
        activityModel.id = e.id;
        return activityModel;
      }).toList();
    } catch (e) {
      kLogging('error $e');
    }
    return [];
  }

  static Future<bool> deleteTrip(String id) async {
    try {
      final batch = firestore.batch();
      batch.update(firestore.collection(kTripTable).doc(id), {
        'tripStatus': TripStatus.deleted.name,
      });
      batch.delete(firestore.collection(kTripDiscoveryTable).doc(id));
      await batch.commit();
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      final batch = firestore.batch();
      batch.update(firestore.collection(kTripTable).doc(groupId), {
        'joinedUsers': FieldValue.arrayRemove([userId]),
      });
      batch.update(_tripMembersRef(groupId).doc(userId), {
        'status': 'left',
        'removedAt': FieldValue.serverTimestamp(),
      });
      batch.delete(_userTripMembershipRef(userId: userId, tripId: groupId));
      batch.update(firestore.collection(kTripDiscoveryTable).doc(groupId), {
        'memberCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> joinTrip({
    required String tripId,
    required String userId,
  }) async {
    return requestToJoinTrip(tripId, userId: userId);
  }

  static Future<bool> requestToJoinTrip(
    String tripId, {
    required String userId,
    String? message,
  }) async {
    try {
      await _tripJoinRequestsRef(tripId)
          .doc(userId)
          .set(
            JoinRequestModel(
              userId: userId,
              tripId: tripId,
              message: message,
            ).toMap(),
            SetOptions(merge: true),
          );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting to join trip: $e');
      }
    }
    return false;
  }

  static Future<bool> cancelJoinRequest(String tripId, String userId) async {
    try {
      await _tripJoinRequestsRef(tripId).doc(userId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      kLogging('error $e');
    }
    return false;
  }

  static Future<bool> acceptJoinRequest(String tripId, String userId) async {
    try {
      await firestore.runTransaction((transaction) async {
        final tripRef = firestore.collection(kTripTable).doc(tripId);
        final requestRef = _tripJoinRequestsRef(tripId).doc(userId);
        final memberRef = _tripMembersRef(tripId).doc(userId);
        final membershipRef = _userTripMembershipRef(
          userId: userId,
          tripId: tripId,
        );
        final discoveryRef = firestore
            .collection(kTripDiscoveryTable)
            .doc(tripId);
        transaction.update(tripRef, {
          'joinedUsers': FieldValue.arrayUnion([userId]),
        });
        transaction.set(
          memberRef,
          TripMemberModel(userId: userId, role: 'member').toMap(),
        );
        transaction.set(membershipRef, {
          'tripId': tripId,
          'role': 'member',
          'status': 'active',
          'joinedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(requestRef, {
          'status': 'accepted',
          'reviewedBy': GlobalVariables.currentUid,
          'reviewedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        transaction.update(discoveryRef, {
          'memberCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      kLogging('error $e');
    }
    return false;
  }

  static Future<bool> rejectJoinRequest(String tripId, String userId) async {
    try {
      await _tripJoinRequestsRef(tripId).doc(userId).update({
        'status': 'rejected',
        'reviewedBy': GlobalVariables.currentUid,
        'reviewedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      kLogging('error $e');
    }
    return false;
  }

  static Stream<List<JoinRequestModel>> watchJoinRequests(String tripId) {
    return _tripJoinRequestsRef(tripId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => JoinRequestModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  static Future<JoinRequestModel?> getJoinRequest({
    required String tripId,
    required String userId,
  }) async {
    try {
      final doc = await _tripJoinRequestsRef(tripId).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return JoinRequestModel.fromMap(doc.data()!);
    } catch (e) {
      kLogging('error $e');
    }
    return null;
  }

  static Future<bool> toggleTripFavorite({
    required String tripId,
    required String userId,
    required bool isFavorite,
  }) async {
    try {
      final userRef = firestore.collection(kUsersCollection).doc(userId);
      final tripRef = firestore.collection(kTripTable).doc(tripId);
      final discoveryRef = firestore
          .collection(kTripDiscoveryTable)
          .doc(tripId);

      await firestore.runTransaction((transaction) async {
        final tripSnapshot = await transaction.get(tripRef);
        final discoverySnapshot = await transaction.get(discoveryRef);
        final currentCount =
            (tripSnapshot.data()?['favouriteCount'] as num?)?.toInt() ?? 0;
        if (isFavorite) {
          transaction.update(userRef, {
            'favouriteTrips': FieldValue.arrayRemove([tripId]),
          });
          transaction.update(tripRef, {
            'favouriteCount': currentCount > 0 ? currentCount - 1 : 0,
          });
          if (discoverySnapshot.exists) {
            transaction.update(discoveryRef, {
              'favouriteCount': currentCount > 0 ? currentCount - 1 : 0,
            });
          }
          GlobalVariables.loggedInUser.value?.favouriteTrips.remove(tripId);
        } else {
          transaction.update(userRef, {
            'favouriteTrips': FieldValue.arrayUnion([tripId]),
          });
          transaction.update(tripRef, {'favouriteCount': currentCount + 1});
          if (discoverySnapshot.exists) {
            transaction.update(discoveryRef, {
              'favouriteCount': currentCount + 1,
            });
          }
          if (GlobalVariables.loggedInUser.value?.favouriteTrips.contains(
                tripId,
              ) !=
              true) {
            GlobalVariables.loggedInUser.value?.favouriteTrips.add(tripId);
          }
        }
      });
      GlobalVariables.loggedInUser.refresh();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling favorite: $e');
      }
    }
    return false;
  }

  static Future<bool> likeActivity({
    required String activityId,
    required String userId,
    bool isLiked = false,
    String? tripId,
  }) async {
    try {
      final activityRef =
          tripId != null && tripId.isNotEmpty
              ? _tripActivitiesRef(tripId).doc(activityId)
              : firestore.collection(kActivityTable).doc(activityId);
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(activityRef);
        final currentCount =
            (snapshot.data()?['likesCount'] as num?)?.toInt() ?? 0;
        if (isLiked) {
          transaction.update(activityRef, {
            'likedBy': FieldValue.arrayRemove([userId]),
            'likesCount': currentCount > 0 ? currentCount - 1 : 0,
          });
        } else {
          transaction.update(activityRef, {
            'likedBy': FieldValue.arrayUnion([userId]),
            'likesCount': currentCount + 1,
          });
        }
      });
      return true;
    } catch (e) {
      kLogging('error $e');
    }
    return false;
  }

  static Future<bool> updateActivity({required ActivityModel activity}) async {
    try {
      await _tripActivitiesRef(
        activity.tripId,
      ).doc(activity.id).set(activity.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> updateExpense(ExpenseModel expenseToSettle) async {
    try {
      await _tripExpensesRef(expenseToSettle.tripId)
          .doc(expenseToSettle.id)
          .set(expenseToSettle.toMap(), SetOptions(merge: true));
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> updateTrip({
    required String tripId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final currentSnapshot =
          await firestore.collection(kTripTable).doc(tripId).get();
      final currentData = currentSnapshot.data();
      if (currentData == null) return false;
      final mergedData = <String, dynamic>{
        ...currentData,
        ...data,
        'id': tripId,
      };
      final mergedTrip = TripModel.fromMap(mergedData);
      final batch = firestore.batch();
      final tripRef = firestore.collection(kTripTable).doc(tripId);
      batch.update(tripRef, data);
      final bool isPrivate = mergedTrip.isPrivate == true;
      final String? status = mergedTrip.tripStatus;
      if (isPrivate || status == TripStatus.deleted.name) {
        batch.delete(firestore.collection(kTripDiscoveryTable).doc(tripId));
      } else {
        final memberIds = await getTripMemberIds(tripId: tripId);
        if (memberIds.isNotEmpty) {
          mergedTrip.joinedUsers =
              memberIds.where((uid) => uid != mergedTrip.createdBy).toList();
        }
        final creator = await AuthService.getUserPublicProfile(
          userId: mergedTrip.createdBy,
        );
        batch.set(
          firestore.collection(kTripDiscoveryTable).doc(tripId),
          TripDiscoveryModel.fromTrip(
            mergedTrip,
            creatorDisplayName: creator?.displayName,
            creatorProfileImage: creator?.profileImage,
          ).toMap(),
          SetOptions(merge: true),
        );
      }
      await batch.commit();
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> deleteActivity({
    required String id,
    String? tripId,
  }) async {
    try {
      if (tripId != null && tripId.isNotEmpty) {
        await _tripActivitiesRef(tripId).doc(id).delete();
      } else {
        await firestore.collection(kActivityTable).doc(id).delete();
      }
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> addFlight({required UserFlightModel flight}) async {
    try {
      await _tripFlightsRef(flight.tripId).doc(flight.id).set(flight.toMap());
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
      return false;
    }
  }

  static Future<bool> deleteFlight({required String id, String? tripId}) async {
    try {
      if (tripId != null && tripId.isNotEmpty) {
        await _tripFlightsRef(tripId).doc(id).delete();
      } else {
        await firestore.collection(kFlightTable).doc(id).delete();
      }
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<List<UserFlightModel>> getTripFlights({
    required String tripId,
  }) async {
    try {
      var snapshot = await _tripFlightsRef(tripId).get();
      if (snapshot.docs.isEmpty) {
        snapshot =
            await firestore
                .collection(kFlightTable)
                .where('tripId', isEqualTo: tripId)
                .get();
      }
      return snapshot.docs
          .map((e) => UserFlightModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      kLogging('error $e');
    }
    return [];
  }

  /// get nearby trips by latitude and longitude with radius
  /// radius is in kilometers
  /// [latitude] and [longitude] are required to get the nearby trips
  /// [radius] is the radius in kilometers to get the nearby trips
  /// [return] list of trips
  /// [logs] logs if there is an error
  static Future<List<TripDiscoveryModel>> getNearbyTrips({
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    try {
      // Bounding box: 1 degree ≈ 111km
      final double delta = radius / 111.0;
      final double minLat = latitude - delta;
      final double maxLat = latitude + delta;
      final double minLng = longitude - delta;
      final double maxLng = longitude + delta;

      final snapshot =
          await firestore
              .collection(kTripDiscoveryTable)
              .where('isDiscoverable', isEqualTo: true)
              .where('latitude', isGreaterThan: minLat)
              .where('latitude', isLessThan: maxLat)
              .limit(50)
              .get();

      final filteredDocs =
          snapshot.docs.where((doc) {
            final data = doc.data();
            final lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
            final status = data['tripStatus'] as String?;
            final createdBy = data['createdBy'] as String?;
            return lng >= minLng &&
                lng <= maxLng &&
                status != TripStatus.deleted.name &&
                createdBy != GlobalVariables.loggedInUser.value?.uid;
          }).toList();

      return filteredDocs
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  static Future<List<TripDiscoveryModel>> getPopularTrips() async {
    try {
      final res =
          await firestore
              .collection(kTripDiscoveryTable)
              .where('isDiscoverable', isEqualTo: true)
              .orderBy('favouriteCount', descending: true)
              .limit(50)
              .get();
      kLogging(res.docs.length.toString());
      return res.docs
          .where((doc) => doc.data()['createdBy'] != GlobalVariables.currentUid)
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      kLogging('error $e');
    }
    return [];
  }

  static Future<List<TripDiscoveryModel>> getRecommendedTrips() async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return [];

      // Gather continents from trips the user has joined and favourited
      final Set<String> continents = {};

      final joinedSnap =
          await firestore
              .collection(kUsersCollection)
              .doc(uid)
              .collection(kUserTripMembershipsSubCollection)
              .limit(50)
              .get();
      for (final doc in joinedSnap.docs) {
        final tripId = doc.data()['tripId'] as String? ?? doc.id;
        final tripDoc =
            await firestore.collection(kTripTable).doc(tripId).get();
        final c = tripDoc.data()?['continent'] as String?;
        if (c != null && c.isNotEmpty) continents.add(c);
      }

      final favouriteIds =
          GlobalVariables.loggedInUser.value?.favouriteTrips ?? [];
      if (favouriteIds.isNotEmpty) {
        final favSnap =
            await firestore
                .collection(kTripDiscoveryTable)
                .where(
                  FieldPath.documentId,
                  whereIn: favouriteIds.take(10).toList(),
                )
                .get();
        for (final doc in favSnap.docs) {
          final c = doc.data()['continent'] as String?;
          if (c != null && c.isNotEmpty) continents.add(c);
        }
      }

      // No history — fall back to popular trips
      if (continents.isEmpty) return getPopularTrips();

      final snap =
          await firestore
              .collection(kTripDiscoveryTable)
              .where('isDiscoverable', isEqualTo: true)
              .where('continent', whereIn: continents.toList())
              .limit(50)
              .get();

      final filteredDocs =
          snap.docs.where((doc) {
            final data = doc.data();
            return data['createdBy'] != uid &&
                data['tripStatus'] != TripStatus.deleted.name;
          }).toList();

      return filteredDocs
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  /// get trips by selected continents
  /// [return] list of trips
  /// [logs] logs if there is an error
  static Future<List<TripDiscoveryModel>> getFilteredTrips({
    List<String>? continents,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection(kTripDiscoveryTable)
          .where('isDiscoverable', isEqualTo: true);
      if (continents != null && continents.isNotEmpty) {
        query = query.where('continent', whereIn: continents.take(10).toList());
      }
      final snapshot = await query.limit(50).get();
      return snapshot.docs
          .where((doc) => doc.data()['createdBy'] != GlobalVariables.currentUid)
          .map((doc) => TripDiscoveryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  /// Search users in the publicProfile collection by displayName prefix
  /// or exact email match, directly via Firestore.
  static Future<List<PublicUserModel>> searchUser({
    required String query,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];
    try {
      // Build the upper bound for a prefix range query
      final String end =
          trimmed.substring(0, trimmed.length - 1) +
          String.fromCharCode(trimmed.codeUnitAt(trimmed.length - 1) + 1);

      final results = <String, PublicUserModel>{};

      // Prefix search on displayName
      final nameSnap =
          await firestore
              .collection(kUsersPublicProfileCollection)
              .where('displayName', isGreaterThanOrEqualTo: trimmed)
              .where('displayName', isLessThan: end)
              .limit(20)
              .get();
      for (final doc in nameSnap.docs) {
        results[doc.id] = PublicUserModel.fromMap(doc.data());
      }

      // Exact email match
      final emailSnap =
          await firestore
              .collection(kUsersPublicProfileCollection)
              .where('email', isEqualTo: trimmed)
              .limit(10)
              .get();
      for (final doc in emailSnap.docs) {
        results[doc.id] = PublicUserModel.fromMap(doc.data());
      }

      kLogging('searchUser: found ${results.length} results for "$trimmed"');
      return results.values.toList();
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  static Future<bool> sendTripInvites({
    required String tripId,
    required String tripTitle,
    required List<String> emails,
  }) async {
    try {
      if (emails.isEmpty) return true;
      await functions.httpsCallable('sendTripInvites').call({
        'tripId': tripId,
        'tripTitle': tripTitle,
        'emails': emails,
      });
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }
}
