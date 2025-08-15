import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/debugging.dart';

import '../models/activity_model.dart';
import '../models/expense_model.dart';
import '../models/trip_model.dart';
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
      var futures =
          snapShot.docs.map((e) async {
            TripModel tripModel = TripModel.fromMap(e.data());
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
      var list = await Future.wait(futures);
      kLogging('future Fetched trips: ${list.length}');
      list.sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });
      return list;
    } catch (e) {
      print(e);
    }
    return [];
  }

  static Future<TripModel?> getTripById({required String tripId}) async {
    try {
      final snapshot = await firestore.collection(kTripTable).doc(tripId).get();
      if (snapshot.exists) {
        TripModel trip = TripModel.fromMap(snapshot.data()!);
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
    } catch (e) {}
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

      var filteredDocs =
          snapshot.docs.where((doc) {
            return doc['tripStatus'] != TripStatus.deleted.name;
          }).toList();

      var futures =
          filteredDocs.map((e) async {
            TripModel tripModel = TripModel.fromMap(e.data());
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
    } catch (e) {}
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
        ActivityModel activityModel = ActivityModel.fromMap(e.data());
        activityModel.id = e.id;
        return activityModel;
      }).toList();
    } catch (e) {}
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
    } catch (e) {}
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
    } catch (e) {}
    return false;
  }

  static Future<bool> updateActivity({required ActivityModel activity}) async {
    try {
      await firestore
          .collection(kActivityTable)
          .doc(activity.id)
          .update(activity.toMap());
      return true;
    } catch (e) {}
    return false;
  }

  static Future<bool> updateExpense(ExpenseModel expenseToSettle) async {
    try {
      await firestore
          .collection(kExpenseTable)
          .doc(expenseToSettle.id)
          .update(expenseToSettle.toMap());
      return true;
    } catch (e) {}
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
    } catch (e) {}
    return false;
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
      final result = await functions.httpsCallable(kNearByTripsFunction).call({
        'lat': latitude,
        'lng': longitude,
        'radius': radius, // in Kilometers
      });
      List<TripModel> trips = [];
      if (result.data != null && result.data['success'] == true) {
        List<Map<String, dynamic>> filteredTrips =
            (result.data['nearbyTrips'] as List<dynamic>)
                .map((trip) => Map<String, dynamic>.from(trip))
                .toList();
        trips = filteredTrips.map((trip) => TripModel.fromMap(trip)).toList();
        var futures =
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
      kLogging('error $e');
      showCustomSnackBar(content: e.toString());
    }
    return [];
  }

  static Future<List<TripModel>> getPopularTrips() async {
    try {
      var res =
          await firestore
              .collection(kTripTable)
              .orderBy('likesCount', descending: true)
              .get();
      var future =
          res.docs.map((e) async {
            TripModel tripModel = TripModel.fromMap(e.data());
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
    } catch (e) {}
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
        List<Map<String, dynamic>> filteredTrips =
            (result.data['filteredTrips'] as List<dynamic>)
                .map((trip) => Map<String, dynamic>.from(trip))
                .toList();
        trips = filteredTrips.map((trip) => TripModel.fromMap(trip)).toList();
        var futures =
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
  static Future<List<PublicUserModel>> searchUser({required query}) async {
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
        List<Map<String, dynamic>> filteredUsers =
            (result.data['users'] as List<dynamic>)
                .map((trip) => Map<String, dynamic>.from(trip))
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
