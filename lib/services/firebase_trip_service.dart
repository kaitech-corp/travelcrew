import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/public_user_model.dart';
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
  static Future<List<TripModel>> getMyTrips({
    String? tripStatus,
    bool isAll = false,
  }) async {
    try {
      late QuerySnapshot<Map<String, dynamic>> snapShot;
      if (tripStatus == null) {
        snapShot =
            await firestore
                .collection(kTripTable)
                .where(
                  'createdBy',
                  isEqualTo: GlobalVariables.loggedInUser.value?.uid,
                )
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
                .get();
      } else {
        snapShot =
            await firestore
                .collection(kTripTable)
                .where('tripStatus', isEqualTo: tripStatus)
                .where(
                  'createdBy',
                  isEqualTo: GlobalVariables.loggedInUser.value?.uid,
                )
                .get();
      }
      // showCustomSnackBar(content: snapShot.docs.length.toString());
      final futures =
          snapShot.docs.map((e) async {
            final TripModel tripModel = TripModel.fromMap(e.data());
            tripModel.expenses = await getTripExpenses(tripId: tripModel.id);
            tripModel.activities = await getTripActivities(
              tripId: tripModel.id,
            );
            if (tripModel.joinedUsers != null &&
                tripModel.joinedUsers!.isNotEmpty) {
              tripModel.joindUsersList = await AuthService.getTripUsers(
                userIds: tripModel.joinedUsers ?? [],
              );
            } else {
              tripModel.joindUsersList = [];
            }
            tripModel.createdByUser = await AuthService.getUserPublicProfile(
              userId: tripModel.createdBy,
            );
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
        trip.expenses = await getTripExpenses(tripId: trip.id);
        trip.activities = await getTripActivities(tripId: trip.id);
        if (trip.joinedUsers != null && trip.joinedUsers!.isNotEmpty) {
          trip.joindUsersList = await AuthService.getTripUsers(
            userIds: trip.joinedUsers ?? [],
          );
        } else {
          trip.joindUsersList = [];
        }
        trip.createdByUser = await AuthService.getUserPublicProfile(userId: trip.createdBy);
        return trip;
      }
    } catch (e) {
      kLogging('error $e');
    }
    return null;
  }

  static Future<List<TripModel>> getOtherTrips() async {
    try {
      final snapshot =
          await firestore
              .collection(kTripTable)
              .where(
                'createdBy',
                isNotEqualTo: GlobalVariables.loggedInUser.value?.uid,
              )
              .get();

      final filteredDocs =
          snapshot.docs.where((doc) {
            return doc['tripStatus'] != TripStatus.deleted.name;
          }).toList();

      final futures =
          filteredDocs.map((e) async {
            final TripModel tripModel = TripModel.fromMap(e.data());
            tripModel.expenses = await getTripExpenses(tripId: tripModel.id);
            tripModel.activities = await getTripActivities(
              tripId: tripModel.id,
            );
            if (tripModel.joinedUsers != null &&
                tripModel.joinedUsers!.isNotEmpty) {
              tripModel.joindUsersList = await AuthService.getTripUsers(
                userIds: tripModel.joinedUsers ?? [],
              );
            } else {
              tripModel.joindUsersList = [];
            }
            tripModel.createdByUser = await AuthService.getUserPublicProfile(
              userId: tripModel.createdBy,
            );
            return tripModel;
          }).toList();

      return await Future.wait(futures);
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  static Future<bool> addTrip({required TripModel tripModel}) async {
    try {
      await firestore
          .collection(kTripTable)
          .doc(tripModel.id)
          .set(tripModel.toMap());
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> addExpenses({required ExpenseModel expense}) async {
    try {
      await firestore
          .collection(kExpenseTable)
          .doc(expense.id)
          .set(expense.toMap());
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
      return false;
    }
  }

  static Future<bool> addActivity({required ActivityModel activity}) async {
    try {
      await firestore
          .collection(kActivityTable)
          .doc(activity.id)
          .set(activity.toMap());
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
      final snapshot =
          await firestore
              .collection(kExpenseTable)
              .where('tripId', isEqualTo: tripId)
              .get();
      return snapshot.docs.map((e) => ExpenseModel.fromMap(e.data())).toList();
    } catch (e) {
      kLogging('error $e');
    }
    return [];
  }

  static Future<List<ActivityModel>> getTripActivities({
    required String tripId,
  }) async {
    try {
      final snapshot =
          await firestore
              .collection(kActivityTable)
              .where('tripId', isEqualTo: tripId)
              .get();
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
      await firestore.collection(kTripTable).doc(id).update({
        'tripStatus': TripStatus.deleted.name,
      });
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
      await firestore.collection(kTripTable).doc(groupId).update({
        'joinedUsers': FieldValue.arrayRemove([userId]),
      });
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
    try {
      await firestore.collection(kTripTable).doc(tripId).update({
        'joinedUsers': FieldValue.arrayUnion([userId]),
      });
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining trip: $e');
      }
    }
    return false;
  }

  static Future<bool> toggleTripFavorite({
    required String tripId,
    required String userId,
    required bool isFavorite,
  }) async {
    try {
      final userRef = firestore.collection(kUsersCollection).doc(userId);
      final tripRef = firestore.collection(kTripTable).doc(tripId);

      if (isFavorite) {
        // Unfavorite
        await userRef.update({
          'favouriteTrips': FieldValue.arrayRemove([tripId]),
        });
        await tripRef.update({
          'favouriteCount': FieldValue.increment(-1),
        });
        GlobalVariables.loggedInUser.value?.favouriteTrips.remove(tripId);
      } else {
        // Favorite
        await userRef.update({
          'favouriteTrips': FieldValue.arrayUnion([tripId]),
        });
        await tripRef.update({
          'favouriteCount': FieldValue.increment(1),
        });
        GlobalVariables.loggedInUser.value?.favouriteTrips.add(tripId);
      }
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
  }) async {
    try {
      if (isLiked) {
        await firestore.collection(kActivityTable).doc(activityId).update({
          'likedBy': FieldValue.arrayRemove([userId]),
          'likesCount': FieldValue.increment(-1),
        });
      } else {
        await firestore.collection(kActivityTable).doc(activityId).update({
          'likedBy': FieldValue.arrayUnion([userId]),
          'likesCount': FieldValue.increment(1),
        });
      }
      return true;
    } catch (e) {
      kLogging('error $e');
    }
    return false;
  }

  static Future<bool> updateActivity({required ActivityModel activity}) async {
    try {
      await firestore
          .collection(kActivityTable)
          .doc(activity.id)
          .update(activity.toMap());
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> updateExpense(ExpenseModel expenseToSettle) async {
    try {
      await firestore
          .collection(kExpenseTable)
          .doc(expenseToSettle.id)
          .update(expenseToSettle.toMap());
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
      await firestore.collection(kTripTable).doc(tripId).update(data);
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> deleteActivity({required String id}) async {
    try {
      await firestore.collection(kActivityTable).doc(id).delete();
      return true;
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return false;
  }

  static Future<bool> addFlight({required UserFlightModel flight}) async {
    try {
      await firestore.collection(kFlightTable).doc(flight.id).set(flight.toMap());
      return true;
    } catch (e) {
      showCustomSnackBar(content: e.toString());
      return false;
    }
  }

  static Future<bool> deleteFlight({required String id}) async {
    try {
      await firestore.collection(kFlightTable).doc(id).delete();
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
      final snapshot = await firestore
          .collection(kFlightTable)
          .where('tripId', isEqualTo: tripId)
          .get();
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
  static Future<List<TripModel>> getNearbyTrips({
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

      final snapshot = await firestore
          .collection(kTripTable)
          .where('latitude', isGreaterThan: minLat)
          .where('latitude', isLessThan: maxLat)
          .get();

      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data();
        final lng = (data['longitude'] as num?)?.toDouble() ?? 0.0;
        final status = data['tripStatus'] as String?;
        final createdBy = data['createdBy'] as String?;
        return lng >= minLng &&
            lng <= maxLng &&
            status != TripStatus.deleted.name &&
            createdBy != GlobalVariables.loggedInUser.value?.uid;
      }).toList();

      final futures = filteredDocs.map((e) async {
        final TripModel tripModel = TripModel.fromMap(e.data());
        tripModel.expenses = await getTripExpenses(tripId: tripModel.id);
        tripModel.activities = await getTripActivities(tripId: tripModel.id);
        if (tripModel.joinedUsers != null && tripModel.joinedUsers!.isNotEmpty) {
          tripModel.joindUsersList = await AuthService.getTripUsers(
            userIds: tripModel.joinedUsers ?? [],
          );
        } else {
          tripModel.joindUsersList = [];
        }
        tripModel.createdByUser = await AuthService.getUserPublicProfile(
          userId: tripModel.createdBy,
        );
        return tripModel;
      }).toList();

      return await Future.wait(futures);
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  static Future<List<TripModel>> getPopularTrips() async {
    try {
      final res =
          await firestore
              .collection(kTripTable)
              .orderBy('likesCount', descending: true)
              .get();
      final future =
          res.docs.map((e) async {
            final TripModel tripModel = TripModel.fromMap(e.data());
            tripModel.expenses = await getTripExpenses(tripId: tripModel.id);
            tripModel.activities = await getTripActivities(
              tripId: tripModel.id,
            );
            if (tripModel.joinedUsers != null &&
                tripModel.joinedUsers!.isNotEmpty) {
              tripModel.joindUsersList = await AuthService.getTripUsers(
                userIds: tripModel.joinedUsers ?? [],
              );
            } else {
              tripModel.joindUsersList = [];
            }
            tripModel.createdByUser = await AuthService.getUserPublicProfile(
              userId: tripModel.createdBy,
            );
            return tripModel;
          }).toList();
      return await Future.wait(future);
    } catch (e) {
      kLogging('error $e');
    }
    return [];
  }

  static Future<List<TripModel>> getRecommendedTrips() async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return [];

      // Gather continents from trips the user has joined and favourited
      final Set<String> continents = {};

      final joinedSnap = await firestore
          .collection(kTripTable)
          .where('joinedUsers', arrayContains: uid)
          .get();
      for (final doc in joinedSnap.docs) {
        final c = doc.data()['continent'] as String?;
        if (c != null && c.isNotEmpty) continents.add(c);
      }

      final favouriteIds =
          GlobalVariables.loggedInUser.value?.favouriteTrips ?? [];
      if (favouriteIds.isNotEmpty) {
        final favSnap = await firestore
            .collection(kTripTable)
            .where(FieldPath.documentId,
                whereIn: favouriteIds.take(10).toList())
            .get();
        for (final doc in favSnap.docs) {
          final c = doc.data()['continent'] as String?;
          if (c != null && c.isNotEmpty) continents.add(c);
        }
      }

      // No history — fall back to popular trips
      if (continents.isEmpty) return getPopularTrips();

      final snap = await firestore
          .collection(kTripTable)
          .where('continent', whereIn: continents.toList())
          .get();

      final filteredDocs = snap.docs.where((doc) {
        final data = doc.data();
        return data['createdBy'] != uid &&
            data['tripStatus'] != TripStatus.deleted.name;
      }).toList();

      final futures = filteredDocs.map((e) async {
        final TripModel tripModel = TripModel.fromMap(e.data());
        tripModel.expenses = await getTripExpenses(tripId: tripModel.id);
        tripModel.activities = await getTripActivities(tripId: tripModel.id);
        if (tripModel.joinedUsers != null &&
            tripModel.joinedUsers!.isNotEmpty) {
          tripModel.joindUsersList = await AuthService.getTripUsers(
            userIds: tripModel.joinedUsers ?? [],
          );
        } else {
          tripModel.joindUsersList = [];
        }
        tripModel.createdByUser = await AuthService.getUserPublicProfile(
          userId: tripModel.createdBy,
        );
        return tripModel;
      }).toList();

      return await Future.wait(futures);
    } catch (e) {
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  /// get trips by filterTrips
  /// [filterTrips] is the minBudget, maxBudget, continents
  /// [return] list of trips
  /// [logs] logs if there is an error
  static Future<List<TripModel>> getFilteredTrips({
    String? minBudget,
    String? maxBudget,
    List<String>? continents,
  }) async {
    try {
      final result = await functions.httpsCallable(kFilterTripsFunction).call({
        'minBudget': minBudget,
        'maxBudget': maxBudget,
        'continents': continents,
      });
      List<TripModel> trips = [];
      if (result.data != null && result.data['success'] == true) {
        if (result.data['filteredTrips'] == null) {
          return [];
        }
        final List<Map<String, dynamic>> filteredTrips =
            (result.data['filteredTrips'] as List<dynamic>)
                .map((trip) => Map<String, dynamic>.from(trip as Map<String, dynamic>))
                .toList();
        trips = filteredTrips.map((trip) => TripModel.fromMap(trip)).toList();
        final futures =
            trips.map((e) async {
              e.expenses = await getTripExpenses(tripId: e.id);
              e.activities = await getTripActivities(tripId: e.id);
              if (e.joinedUsers != null && e.joinedUsers!.isNotEmpty) {
                e.joindUsersList = await AuthService.getTripUsers(
                  userIds: e.joinedUsers ?? [],
                );
              } else {
                e.joindUsersList = [];
              }
              e.createdByUser = await AuthService.getUserPublicProfile(userId: e.createdBy);
            }).toList();
        await Future.wait(futures);
        return trips;
      }
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  /// search user by name and email
  /// [name] is the name of the user
  /// [email] is the email of the user
  /// [return] list of users
  /// [logs] logs if there is an error
  static Future<List<PublicUserModel>> searchUser({required String query}) async {
    try {
      final result = await functions.httpsCallable(kSearchUsersFunction).call({
        'query': query,
      });
      kLogging('result: ${result.data}');
      List<PublicUserModel> users = [];
      if (result.data != null && result.data['success'] == true) {
        if (result.data['users'] == null) {
          return [];
        }
        final List<Map<String, dynamic>> filteredUsers =
            (result.data['users'] as List<dynamic>)
                .map((trip) => Map<String, dynamic>.from(trip as Map<String, dynamic>))
                .toList();
        kLogging('filteredUsers: $filteredUsers');
        users = filteredUsers.map((trip) => PublicUserModel.fromMap(trip)).toList();
        return users;
      }
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }
}
