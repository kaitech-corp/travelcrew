import 'package:travel_crew/models/transportation_model.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_crew/models/recommendation_context.dart';
import 'package:get/get.dart';
import 'package:travel_crew/services/safety_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
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
import 'finance_service.dart';
import 'lodging_service.dart';
import 'nearby_radius.dart';
import 'activity_vote.dart';
import '../models/trip_model.dart';
import 'session_services.dart';

final functions = FirebaseFunctions.instance;
typedef FavoriteUpdate = ({bool favorite, bool changed, int count});

/// Compare only fields this edit will write. Normalize both sides through the
/// trip model so older documents with omitted optional fields compare fairly.
List<String> changedTripUpdateFields({
  required Map<String, dynamic> current,
  required Map<String, dynamic> expected,
  required Iterable<String> fields,
  required String tripId,
}) {
  final normalizedCurrent =
      TripModel.fromMap({...current, 'id': tripId}).toMap();
  final normalizedExpected =
      TripModel.fromMap({...expected, 'id': tripId}).toMap();
  const equality = DeepCollectionEquality();
  return [
    for (final field in fields)
      if (!equality.equals(
        normalizedCurrent.containsKey(field)
            ? normalizedCurrent[field]
            : current[field],
        normalizedExpected.containsKey(field)
            ? normalizedExpected[field]
            : expected[field],
      ))
        field,
  ];
}

/// Result of a bounded My Trips load.
class MyTripsLoad {
  const MyTripsLoad(this.trips, {required this.hasMore});

  final List<TripModel> trips;

  /// True when a larger bound would return more trips.
  final bool hasMore;
}

class FirebaseTripService {
  static final Map<String, String> _joinAttempts = {};
  static final Map<String, String> _leaveAttempts = {};
  static final discoveryHasMore = <String, bool>{}.obs;
  static final Map<String, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _discoveryDocs = {};
  static String? _discoveryUid;

  /// Reads up to [maxDocs] documents in pages of 50. [truncated] is true when
  /// the query may hold more documents than were read.
  static Future<
    ({List<QueryDocumentSnapshot<Map<String, dynamic>>> docs, bool truncated})
  >
  _readTripListPagesBounded(
    Query<Map<String, dynamic>> query, {
    int? maxDocs,
  }) async {
    final docs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    QueryDocumentSnapshot<Map<String, dynamic>>? cursor;
    while (true) {
      final remaining = maxDocs == null ? 50 : maxDocs - docs.length;
      if (remaining <= 0) return (docs: docs, truncated: true);
      final pageSize = remaining < 50 ? remaining : 50;
      final page =
          await (cursor == null ? query : query.startAfterDocument(cursor))
              .limit(pageSize)
              .get();
      docs.addAll(page.docs);
      if (page.docs.length < pageSize) return (docs: docs, truncated: false);
      if (maxDocs != null && docs.length >= maxDocs) {
        // A full final page cannot prove the end of the collection.
        return (docs: docs, truncated: true);
      }
      cursor = page.docs.last;
    }
  }

  static Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
  _discoveryPage(
    Query<Map<String, dynamic>> query,
    String key,
    bool append, {
    bool Function(Map<String, dynamic>)? qualifies,
  }) async {
    final uid = GlobalVariables.currentUid;
    if (_discoveryUid != uid) {
      _discoveryUid = uid;
      _discoveryDocs.clear();
      discoveryHasMore.clear();
    }
    final docs =
        append
            ? List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
              _discoveryDocs[key] ?? [],
            )
            : <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    var visible = 0;
    var hasMore = false;
    for (var page = 0; page < 5; page++) {
      final snapshot =
          await (docs.isEmpty ? query : query.startAfterDocument(docs.last))
              .limit(50)
              .get();
      if (uid != GlobalVariables.currentUid) return [];
      docs.addAll(snapshot.docs);
      visible +=
          snapshot.docs
              .where(
                (doc) =>
                    !SafetyService.hides(
                      doc.data()['createdBy'] as String? ?? '',
                    ) &&
                    (qualifies?.call(doc.data()) ?? true),
              )
              .length;
      hasMore = snapshot.docs.length == 50;
      if (snapshot.docs.length < 50 || visible >= 50) break;
    }
    _discoveryDocs[key] = docs;
    discoveryHasMore[key] = hasMore;
    return docs;
  }

  static void _handleTripError(Object error, {String? operation}) {
    final prefix =
        operation == null
            ? 'FirebaseTripService'
            : 'FirebaseTripService.$operation';
    if (error is FirebaseException && error.plugin == 'cloud_firestore') {
      kLogging(
        '$prefix Firestore error: ${error.code} ${error.message ?? error}',
      );
      return;
    }
    kLogging('$prefix error: $error');
    showCustomSnackBar(content: error.toString());
  }

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

  static bool _isCurrentOrFutureDiscoveryTrip(Map<String, dynamic> data) {
    final status = data['tripStatus'] as String?;
    if (status == TripStatus.deleted.name ||
        status == TripStatus.cancelled.name ||
        status == TripStatus.completed.name) {
      return false;
    }

    final comparisonDate =
        _dateFromDiscoveryValue(data['tripEndDate']) ??
        _dateFromDiscoveryValue(data['tripStartDate']) ??
        _dateFromDiscoveryValue(data['startDate']);
    if (comparisonDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(
      comparisonDate.year,
      comparisonDate.month,
      comparisonDate.day,
    );
    return !tripDate.isBefore(today);
  }

  static DateTime? _dateFromDiscoveryValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }

  static Future<void> _hydrateMemberOnlyTrip(TripModel trip) async {
    if (trip.financeSchemaVersion != 2) {
      final legacy = await getTripExpenses(tripId: trip.id);
      trip.expenses = legacy.expenses;
      trip.hasLegacyExpenseRecords =
          trip.hasLegacyExpenseRecords || legacy.hasSources;
    }
    if (trip.financeSchemaVersion == 2) {
      trip.financeExpenses = await FinanceService.getExpenses(trip.id);
    }
    trip.activities = await getTripActivities(tripId: trip.id);
    final roster = await getTripMemberRoster(tripId: trip.id);
    final memberIds = roster.activeIds;
    if (memberIds.isNotEmpty) {
      trip.joinedUsers =
          memberIds.where((uid) => uid != trip.createdBy).toList();
      trip.joindUsersList = await AuthService.getTripUsers(userIds: memberIds);
    } else if (!roster.hasRecords &&
        trip.joinedUsers != null &&
        trip.joinedUsers!.isNotEmpty) {
      final legacyIds = <String>{trip.createdBy, ...trip.joinedUsers!}.toList();
      trip.joindUsersList = await AuthService.getTripUsers(userIds: legacyIds);
    } else {
      trip.joindUsersList = [];
    }
    trip.createdByUser = await AuthService.getUserPublicProfile(
      userId: trip.createdBy,
    );
  }

  static Future<({List<String> activeIds, bool hasRecords})>
  getTripMemberRoster({required String tripId}) async {
    final reference = _tripMembersRef(tripId);
    final active = await reference.where('status', isEqualTo: 'active').get();
    final ids =
        active.docs
            .map((doc) => doc.data()['userId'] as String? ?? doc.id)
            .where((uid) => uid.isNotEmpty)
            .toList();
    if (active.docs.isNotEmpty) return (activeIds: ids, hasRecords: true);
    final any = await reference.limit(1).get();
    return (activeIds: ids, hasRecords: any.docs.isNotEmpty);
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
    if (userId.isEmpty || userId != GlobalVariables.currentUid) {
      throw StateError(
        'Membership may only be checked for the signed-in user.',
      );
    }
    try {
      final memberDoc = await _tripMembersRef(tripId).doc(userId).get();
      if (memberDoc.exists && memberDoc.data()?['status'] != 'active') {
        return false;
      }
      final DocumentSnapshot<Map<String, dynamic>> tripDoc;
      try {
        tripDoc = await firestore.collection(kTripTable).doc(tripId).get();
      } on FirebaseException catch (e) {
        // Rules let every member read the trip, so a definitive denial means
        // this account is not a member (or the trip is unavailable). Network
        // and other failures still propagate so the caller can offer Retry.
        if (e.code == 'permission-denied') return false;
        rethrow;
      }
      final data = tripDoc.data();
      if (data == null ||
          data['tripStatus'] == TripStatus.deleted.name ||
          data['moderationRemoved'] == true) {
        return false;
      }
      if (data['createdBy'] == userId) return true;
      if (memberDoc.exists) return true;
      return ((data['joinedUsers'] as List<dynamic>?)?.contains(userId) ??
          false);
    } catch (e) {
      _handleTripError(e, operation: 'isTripMember');
      rethrow;
    }
  }

  static Future<List<TripModel>> getMyTrips({
    String? tripStatus,
    bool isAll = false,
    bool summaryOnly = false,
  }) async =>
      (await getMyTripsBounded(
        tripStatus: tripStatus,
        isAll: isAll,
        summaryOnly: summaryOnly,
      )).trips;

  /// Loads the signed-in traveler's trips. With [maxTrips], owned trips and
  /// membership trips are read only up to that many documents and [hasMore]
  /// reports whether a larger bound would return additional trips, so large
  /// accounts load incrementally instead of reading every page at once.
  static Future<MyTripsLoad> getMyTripsBounded({
    String? tripStatus,
    bool isAll = false,
    bool summaryOnly = false,
    int? maxTrips,
  }) async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return const MyTripsLoad([], hasMore: false);
      if (maxTrips != null && maxTrips < 1) {
        throw ArgumentError.value(maxTrips, 'maxTrips', 'must be positive');
      }
      var hasMore = false;
      final docsById = <String, DocumentSnapshot<Map<String, dynamic>>>{};
      late Query<Map<String, dynamic>> ownedQuery;
      if (tripStatus == null) {
        ownedQuery = firestore
            .collection(kTripTable)
            .where('createdBy', isEqualTo: uid)
            .where(
              'tripStatus',
              whereIn:
                  isAll
                      ? [
                        TripStatus.upcoming.name,
                        TripStatus.completed.name,
                        TripStatus.cancelled.name,
                      ]
                      : [TripStatus.upcoming.name, TripStatus.completed.name],
            );
      } else {
        ownedQuery = firestore
            .collection(kTripTable)
            .where('tripStatus', isEqualTo: tripStatus)
            .where('createdBy', isEqualTo: uid);
      }
      const none = MyTripsLoad([], hasMore: false);
      final owned = await _readTripListPagesBounded(
        ownedQuery,
        maxDocs: maxTrips,
      );
      if (uid != GlobalVariables.currentUid) return none;
      hasMore = owned.truncated;
      for (final doc in owned.docs) {
        docsById[doc.id] = doc;
      }

      final membership = await _readTripListPagesBounded(
        firestore
            .collection(kUsersCollection)
            .doc(uid)
            .collection(kUserTripMembershipsSubCollection)
            .where('status', isEqualTo: 'active')
            .orderBy('joinedAt', descending: true),
        maxDocs: maxTrips,
      );
      if (uid != GlobalVariables.currentUid) return none;
      if (membership.truncated) hasMore = true;
      var membershipTripIds =
          membership.docs
              .map((doc) => doc.data()['tripId'] as String? ?? doc.id)
              .where((id) => id.isNotEmpty && !docsById.containsKey(id))
              .toList();
      if (maxTrips != null) {
        final budget = maxTrips - docsById.length;
        if (membershipTripIds.length > budget) {
          hasMore = true;
          membershipTripIds = membershipTripIds.take(budget).toList();
        }
      }
      // A stale membership index can outlive revocation. Read each trip
      // independently so one denied document cannot hide the owner's trips.
      for (var i = 0; i < membershipTripIds.length; i += 10) {
        final chunk = membershipTripIds.skip(i).take(10);
        final membershipTrips = await Future.wait(
          chunk.map((id) async {
            try {
              return await firestore.collection(kTripTable).doc(id).get();
            } on FirebaseException catch (error) {
              if (error.code == 'permission-denied') {
                kLogging('Skipped revoked trip membership: $id');
                return null;
              }
              rethrow;
            }
          }),
        );
        if (uid != GlobalVariables.currentUid) return none;
        for (final doc in membershipTrips) {
          if (doc == null || !doc.exists) continue;
          final data = doc.data()!;
          final status = data['tripStatus'] as String?;
          final include =
              status != TripStatus.deleted.name &&
              data['moderationRemoved'] != true &&
              (tripStatus == null
                  ? isAll ||
                      status == TripStatus.upcoming.name ||
                      status == TripStatus.completed.name
                  : status == tripStatus);
          if (include) docsById[doc.id] = doc;
        }
      }

      final list = <TripModel>[];
      final documents = docsById.values.toList();
      if (summaryOnly) {
        list.addAll(
          documents.map(
            (doc) => TripModel.fromMap({
              ...doc.data()!,
              // The list uses only trip metadata. Descendant arrays are loaded
              // when the traveler opens the trip.
              'activities': null,
              'expenses': null,
            }),
          ),
        );
      } else {
        for (var i = 0; i < documents.length; i += 10) {
          final chunk = documents.skip(i).take(10);
          final hydrated = await Future.wait(
            chunk.map((e) async {
              final TripModel tripModel = TripModel.fromMap(e.data()!);
              await _hydrateMemberOnlyTrip(tripModel);
              return tripModel;
            }),
          );
          if (uid != GlobalVariables.currentUid) return none;
          list.addAll(hydrated);
        }
      }
      if (uid != GlobalVariables.currentUid) return none;
      kLogging('future Fetched trips: ${list.length}');
      list.sort((a, b) {
        return a.startDate.compareTo(b.startDate);
      });
      return MyTripsLoad(list, hasMore: hasMore);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
    }
  }

  static Future<TripModel?> getTripById({required String tripId}) async {
    try {
      final snapshot = await firestore.collection(kTripTable).doc(tripId).get();
      if (snapshot.exists) {
        final TripModel trip = TripModel.fromMap(snapshot.data()!);
        if (trip.tripStatus == TripStatus.deleted.name) return null;
        await _hydrateMemberOnlyTrip(trip);
        return trip;
      }
    } catch (e) {
      _handleTripError(e, operation: 'getTripById');
      rethrow;
    }
    return null;
  }

  static Future<List<TripDiscoveryModel>> getOtherTrips({
    bool loadMore = false,
  }) async {
    try {
      final snapshot = await _discoveryPage(
        firestore
            .collection(kTripDiscoveryTable)
            .where('isDiscoverable', isEqualTo: true),
        'all',
        loadMore,
      );

      final filteredDocs =
          snapshot.where((doc) {
            final data = doc.data();
            return data['tripStatus'] != TripStatus.deleted.name &&
                data['createdBy'] != GlobalVariables.loggedInUser.value?.uid;
          }).toList();

      return filteredDocs
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      _handleTripError(e, operation: 'getOtherTrips');
      rethrow;
    }
  }

  static Future<bool> addTrip({
    required TripModel tripModel,
    List<TransportationModel> transportation = const [],
  }) async {
    try {
      if (transportation.length > 50) {
        throw const FormatException('Use up to 50 transportation entries.');
      }
      final tripRef = firestore.collection(kTripTable).doc(tripModel.id);
      final batch = firestore.batch();
      batch.set(tripRef, tripModel.toMap());
      for (final entry in transportation) {
        if (entry.issue != null) throw FormatException(entry.issue!);
        final data = entry.toMap();
        data['tripId'] = tripModel.id;
        data['userId'] = tripModel.createdBy;
        data['displayName'] =
            GlobalVariables.loggedInUser.value?.displayName ?? '';
        batch.set(tripRef.collection('transportation').doc(entry.id), data);
      }
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
      _handleTripError(e);
    }
    return false;
  }

  /// The callable checks the named database with Admin SDK, so an absent trip
  /// is distinguishable from a denied client read. Errors propagate; offline
  /// must never be interpreted as "trip absent".
  static Future<bool> createdTripExists({
    required String tripId,
    required String ownerId,
  }) async {
    if (ownerId != GlobalVariables.currentUid) {
      throw StateError('Trip owner must be the signed-in account.');
    }
    final response = await FirebaseFunctions.instance
        .httpsCallable('checkTripCreateV3')
        .call(<String, dynamic>{'tripId': tripId});
    final data = Map<String, dynamic>.from(response.data as Map);
    return data['exists'] == true;
  }

  static Future<bool> addExpenses({required ExpenseModel expense}) async {
    try {
      await _tripExpensesRef(
        expense.tripId,
      ).doc(expense.id).set(expense.toMap());
      return true;
    } catch (e) {
      _handleTripError(e);
      return false;
    }
  }

  static Future<bool> addActivity({required ActivityModel activity}) async {
    try {
      if (activity.id == null ||
          activity.id!.isEmpty ||
          activity.tripId.isEmpty) {
        throw const FormatException('Activity ID and trip are required.');
      }
      if (activity.createdBy.isEmpty) {
        activity.createdBy = GlobalVariables.currentUid;
      }
      if (activity.createdBy != GlobalVariables.currentUid) {
        throw const FormatException(
          'Activity author must be the signed-in account.',
        );
      }
      await _tripActivitiesRef(
        activity.tripId,
      ).doc(activity.id).set(activity.toMap());
      return true;
    } catch (e) {
      _handleTripError(e);
      return false;
    }
  }

  static Future<({List<ExpenseModel> expenses, bool hasSources})>
  getTripExpenses({required String tripId}) async {
    try {
      final results = await Future.wait([
        _tripExpensesRef(tripId).get(),
        firestore
            .collection(kExpenseTable)
            .where('tripId', isEqualTo: tripId)
            .get(),
      ]);
      // The historical screen keeps its original nested-first presentation.
      // The owner review reads both physical sources independently.
      final docs =
          results[0].docs.isNotEmpty ? results[0].docs : results[1].docs;
      final parsed = <ExpenseModel>[];
      for (final doc in docs) {
        try {
          parsed.add(ExpenseModel.fromMap(doc.data()));
        } on FormatException {
          // The migration review reads the original document directly.
        } on TypeError {
          // Do not let one malformed historical record hide the trip.
        }
      }
      return (
        expenses: parsed,
        hasSources: results[0].docs.isNotEmpty || results[1].docs.isNotEmpty,
      );
    } catch (e) {
      _handleTripError(e, operation: 'getTripExpenses');
      rethrow;
    }
  }

  static Future<List<ActivityModel>> getTripActivities({
    required String tripId,
  }) async {
    try {
      final uid = GlobalVariables.currentUid;
      final activities = <ActivityModel>[];
      String? source;
      String? cursor;
      for (var page = 0; page < 200; page++) {
        final result = await functions
            .httpsCallable('listTripActivitiesV3')
            .call({
              'tripId': tripId,
              if (source != null) 'source': source,
              if (cursor != null) 'cursor': cursor,
            });
        if (uid != GlobalVariables.currentUid) return [];
        final data = Map<String, dynamic>.from(result.data as Map);
        source = data['source'] as String;
        for (final item in data['activities'] as List<dynamic>) {
          final map = Map<String, dynamic>.from(item as Map);
          final activity = ActivityModel.fromMap(map);
          activity.id = map['id'] as String;
          activity.isLegacy = map['isLegacy'] == true;
          activities.add(activity);
        }
        cursor = data['nextCursor'] as String?;
        if (cursor == null) {
          final nextSource = data['nextSource'];
          if (nextSource is String) {
            source = nextSource;
            continue;
          }
          return activities;
        }
      }
      throw StateError('Activity list is too large to load.');
    } catch (e) {
      _handleTripError(e, operation: 'getTripActivities');
      rethrow;
    }
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
      _handleTripError(e);
    }
    return false;
  }

  static Future<bool> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    try {
      if (userId != GlobalVariables.currentUid) return false;
      final key = '$userId:$groupId';
      if (!_leaveAttempts.containsKey(key)) {
        final member = await _tripMembersRef(groupId).doc(userId).get();
        _leaveAttempts[key] =
            member.data()?['attemptId'] as String? ?? 'legacy';
      }
      await FirebaseFunctions.instance.httpsCallable('leaveTripV3').call({
        'tripId': groupId,
        'membershipAttemptId': _leaveAttempts[key],
      });
      _leaveAttempts.remove(key);
      return true;
    } catch (e) {
      if (e is FirebaseFunctionsException && e.code == 'failed-precondition') {
        _leaveAttempts.remove('$userId:$groupId');
      }
      kLogging('error $e');
      _handleTripError(e);
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
    RecommendationContext? recommendation,
  }) async {
    if (userId != GlobalVariables.currentUid) return false;
    final key = '$userId:$tripId';
    final attemptId = _joinAttempts.putIfAbsent(key, () => const Uuid().v4());
    try {
      final response = await FirebaseFunctions.instance
          .httpsCallable('requestToJoinTripV3')
          .call({
            'tripId': tripId,
            'attemptId': attemptId,
            'message': message,
            if (recommendation?.viewerUid == userId)
              'recommendation': recommendation!.toMap(),
          });
      _joinAttempts.remove(key);
      return (response.data as Map)['status'] == 'pending';
    } catch (e) {
      kLogging('Join request failed: $e');
      return false;
    }
  }

  static Future<bool> cancelJoinRequest(
    String tripId,
    String userId, {
    required String attemptId,
  }) async {
    if (userId != GlobalVariables.currentUid) return false;
    return _transitionJoinRequest(
      'cancelJoinRequestV3',
      tripId,
      userId,
      attemptId,
    );
  }

  static Future<bool> acceptJoinRequest(
    String tripId,
    String userId, {
    required String attemptId,
  }) =>
      _transitionJoinRequest('acceptJoinRequestV3', tripId, userId, attemptId);

  static Future<bool> _transitionJoinRequest(
    String callable,
    String tripId,
    String userId,
    String attemptId,
  ) async {
    try {
      await FirebaseFunctions.instance.httpsCallable(callable).call({
        'tripId': tripId,
        'userId': userId,
        'attemptId': attemptId,
      });
      return true;
    } catch (e) {
      kLogging('Join request transition failed: $e');
      return false;
    }
  }

  static Future<bool> rejectJoinRequest(
    String tripId,
    String userId, {
    required String attemptId,
  }) =>
      _transitionJoinRequest('rejectJoinRequestV3', tripId, userId, attemptId);

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

  static Stream<JoinRequestModel?> watchJoinRequest({
    required String tripId,
    required String userId,
  }) => _tripJoinRequestsRef(tripId)
      .doc(userId)
      .snapshots()
      .map((doc) => doc.exists ? JoinRequestModel.fromMap(doc.data()!) : null);

  static Future<JoinRequestModel?> getJoinRequest({
    required String tripId,
    required String userId,
  }) async {
    try {
      final doc = await _tripJoinRequestsRef(tripId).doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return JoinRequestModel.fromMap(doc.data()!);
    } catch (e) {
      _handleTripError(e, operation: 'getJoinRequest');
      rethrow;
    }
  }

  static Future<FavoriteUpdate?> setTripFavorite({
    required String tripId,
    required String userId,
    required bool shouldFavorite,
  }) async {
    try {
      if (userId.isEmpty || userId != GlobalVariables.currentUid) {
        throw const FormatException('Sign in to favorite trips.');
      }
      final response = await functions.httpsCallable('setTripFavoriteV3').call({
        'tripId': tripId,
        'favorite': shouldFavorite,
      });
      if (userId != GlobalVariables.currentUid) return null;
      final data = Map<String, dynamic>.from(response.data as Map);
      final favorite = data['favorite'] as bool;
      final changed = data['changed'] as bool;
      final count = (data['favouriteCount'] as num).toInt();
      final user = GlobalVariables.loggedInUser.value;
      if (user == null) return null;
      final favorites = user.favouriteTrips.toSet();
      if (favorite) {
        favorites.add(tripId);
      } else {
        favorites.remove(tripId);
      }
      user.favouriteTrips = favorites.toList();
      GlobalVariables.loggedInUser.refresh();
      return (favorite: favorite, changed: changed, count: count);
    } catch (e) {
      _handleTripError(e, operation: 'setTripFavorite');
    }
    return null;
  }

  static Future<ActivityVoteState?> likeActivity({
    required String activityId,
    required String userId,
    bool isLiked = false,
    String? tripId,
  }) async {
    try {
      if (userId.isEmpty || userId != GlobalVariables.currentUid) {
        throw const FormatException('Sign in to vote on activities.');
      }
      final activityRef =
          tripId != null && tripId.isNotEmpty
              ? _tripActivitiesRef(tripId).doc(activityId)
              : firestore.collection(kActivityTable).doc(activityId);
      return await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(activityRef);
        final data = snapshot.data();
        if (data == null) throw StateError('Activity no longer exists.');
        final current = List<String>.from(data['likedBy'] as List? ?? []);
        final vote = ActivityVoteState.apply(
          current,
          (data['likesCount'] as num?)?.toInt() ?? 0,
          userId: userId,
          shouldLike: !isLiked,
        );
        if (vote.changed) {
          transaction.update(activityRef, {
            'likedBy': vote.likedBy,
            'likesCount': vote.likesCount,
          });
        }
        return vote;
      });
    } catch (e) {
      kLogging('error $e');
    }
    return null;
  }

  static Future<bool> updateActivity({required ActivityModel activity}) async {
    try {
      final content = activity.toMap();
      final ref =
          activity.isLegacy
              ? firestore.collection(kActivityTable).doc(activity.id)
              : _tripActivitiesRef(activity.tripId).doc(activity.id);
      final nextRevision = await firestore.runTransaction((transaction) async {
        final current = (await transaction.get(ref)).data();
        if (current == null || current['isDeleted'] == true) {
          throw StateError('Activity no longer exists. Reopen the trip.');
        }
        final revision = (current['contentRevision'] as num?)?.toInt() ?? 0;
        if (revision != activity.contentRevision) {
          throw StateError(
            'Activity changed on another device. Reopen the trip before editing.',
          );
        }
        transaction.update(ref, {
          'title': content['title'],
          'description': content['description'],
          'location': content['location'],
          'startDateTime': content['startDateTime'],
          'endDateTime': content['endDateTime'],
          'contentRevision': revision + 1,
        });
        return revision + 1;
      });
      activity.contentRevision = nextRevision;
      return true;
    } catch (e) {
      kLogging('error $e');
      _handleTripError(e);
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
      _handleTripError(e);
    }
    return false;
  }

  static Future<bool> updateTrip({
    required String tripId,
    required Map<String, dynamic> data,
    List<String>? expectedImages,
    TripModel? expectedLodging,
    Map<String, dynamic>? expectedEditedFields,
  }) async {
    try {
      final tripRef = firestore.collection(kTripTable).doc(tripId);
      await firestore.runTransaction((transaction) async {
        final current = (await transaction.get(tripRef)).data();
        if (current == null) throw StateError('Trip unavailable');
        if (current['tripStatus'] == TripStatus.deleted.name ||
            current['moderationRemoved'] == true) {
          throw StateError('Trip unavailable');
        }
        if (expectedEditedFields != null) {
          final changed = changedTripUpdateFields(
            current: current,
            expected: expectedEditedFields,
            fields: data.keys,
            tripId: tripId,
          );
          if (changed.isNotEmpty) {
            throw StateError(
              'Trip details changed on another device. Reopen the trip before saving.',
            );
          }
        }
        if (expectedLodging != null &&
            !LodgingService.legacyMatches(current, tripId, expectedLodging)) {
          throw StateError(
            'Lodging changed on another device. Reopen the trip before saving.',
          );
        }
        if (expectedImages != null &&
            !listEquals(
              List<String>.from(current['images'] as List? ?? []),
              expectedImages,
            )) {
          throw StateError(
            'The cover changed on another device. Reopen the trip before replacing it.',
          );
        }
        final updateData = {
          ...data,
          if (expectedLodging != null)
            'lodgingRevision': (current['lodgingRevision'] as int? ?? 0) + 1,
        };
        final merged = TripModel.fromMap({
          ...current,
          ...updateData,
          'id': tripId,
        });
        if (updateData.isNotEmpty) transaction.update(tripRef, updateData);
        final discovery = firestore.collection(kTripDiscoveryTable).doc(tripId);
        if (merged.isPrivate == true ||
            merged.tripStatus == TripStatus.deleted.name) {
          transaction.delete(discovery);
        } else {
          final memberIds = await getTripMemberIds(tripId: tripId);
          if (memberIds.isNotEmpty) {
            merged.joinedUsers =
                memberIds.where((uid) => uid != merged.createdBy).toList();
          }
          final creator = await AuthService.getUserPublicProfile(
            userId: merged.createdBy,
          );
          transaction.set(
            discovery,
            TripDiscoveryModel.fromTrip(
              merged,
              creatorDisplayName: creator?.displayName,
              creatorProfileImage: creator?.profileImage,
            ).toMap(),
            SetOptions(merge: true),
          );
        }
      });
      return true;
    } catch (e) {
      _handleTripError(e);
    }
    return false;
  }

  static Future<bool> deleteActivity({
    required String id,
    String? tripId,
    required int expectedRevision,
  }) async {
    try {
      final ref =
          tripId != null && tripId.isNotEmpty
              ? _tripActivitiesRef(tripId).doc(id)
              : firestore.collection(kActivityTable).doc(id);
      await firestore.runTransaction((transaction) async {
        final current = await transaction.get(ref);
        if (!current.exists || current.data()?['isDeleted'] == true) return;
        final revision =
            (current.data()?['contentRevision'] as num?)?.toInt() ?? 0;
        if (revision != expectedRevision) {
          throw StateError(
            'Activity changed on another device. Reopen the trip before deleting.',
          );
        }
        transaction.update(ref, {
          'contentRevision': revision + 1,
          'isDeleted': true,
          'title': '',
          'description': '',
          'location': null,
          'startDateTime': null,
          'endDateTime': null,
          'likedBy': <String>[],
          'likesCount': 0,
          'deletedBy': GlobalVariables.currentUid,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      });
      return true;
    } catch (e) {
      kLogging('error $e');
      _handleTripError(e);
    }
    return false;
  }

  /// get nearby trips by latitude and longitude with radius
  /// radius is in kilometers
  /// [latitude] and [longitude] are required to get the nearby trips
  /// [radius] is the radius in kilometers to get the nearby trips
  /// [return] list of trips
  /// [logs] logs if there is an error
  static Future<List<TripDiscoveryModel>> getNearbyTrips({
    bool loadMore = false,
    required double latitude,
    required double longitude,
    required int radius,
  }) async {
    try {
      if (!latitude.isFinite ||
          !longitude.isFinite ||
          latitude < -90 ||
          latitude > 90 ||
          longitude < -180 ||
          longitude > 180) {
        throw const FormatException('Nearby center coordinates are invalid.');
      }
      final delta = NearbyRadius.latitudeDelta(radius);
      final minLat = (latitude - delta).clamp(-90.0, 90.0);
      final maxLat = (latitude + delta).clamp(-90.0, 90.0);

      bool qualifies(Map<String, dynamic> data) {
        final tripLatitude = data['latitude'];
        final tripLongitude = data['longitude'];
        return tripLatitude is num &&
            tripLongitude is num &&
            NearbyRadius.contains(
              centerLatitude: latitude,
              centerLongitude: longitude,
              latitude: tripLatitude.toDouble(),
              longitude: tripLongitude.toDouble(),
              radiusKm: radius,
            ) &&
            _isCurrentOrFutureDiscoveryTrip(data) &&
            data['createdBy'] != GlobalVariables.currentUid;
      }

      final snapshot = await _discoveryPage(
        firestore
            .collection(kTripDiscoveryTable)
            .where('isDiscoverable', isEqualTo: true)
            .where('latitude', isGreaterThanOrEqualTo: minLat)
            .where('latitude', isLessThanOrEqualTo: maxLat),
        'nearby',
        loadMore,
        qualifies: qualifies,
      );

      final filteredDocs =
          snapshot.where((doc) => qualifies(doc.data())).toList();

      return filteredDocs
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      _handleTripError(e, operation: 'getNearbyTrips');
      rethrow;
    }
  }

  static Future<List<TripDiscoveryModel>> getPopularTrips({
    bool loadMore = false,
  }) async {
    try {
      final res = await _discoveryPage(
        firestore
            .collection(kTripDiscoveryTable)
            .where('isDiscoverable', isEqualTo: true)
            .orderBy('favouriteCount', descending: true),
        'popular',
        loadMore,
      );
      kLogging(res.length.toString());
      return res
          .where((doc) => doc.data()['createdBy'] != GlobalVariables.currentUid)
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      _handleTripError(e, operation: 'getPopularTrips');
      rethrow;
    }
  }

  static Future<List<TripDiscoveryModel>> getRecommendedTrips({
    bool loadMore = false,
  }) async {
    try {
      final uid = GlobalVariables.loggedInUser.value?.uid;
      if (uid == null) return [];

      // Gather continents from trips the user has joined and favourited
      final Set<String> continents = {};

      Future<void> addHistoryContinent(
        DocumentReference<Map<String, dynamic>> reference,
      ) async {
        try {
          final snapshot = await reference.get();
          final continent = snapshot.data()?['continent'] as String?;
          if (continent != null && continent.isNotEmpty) {
            continents.add(continent);
          }
        } on FirebaseException catch (error) {
          // A favorite or membership can outlive a trip or its access grant.
          // Skip only unavailable entries; network and other failures still surface.
          if (error.code != 'permission-denied' && error.code != 'not-found') {
            rethrow;
          }
        }
      }

      final joinedSnap =
          await firestore
              .collection(kUsersCollection)
              .doc(uid)
              .collection(kUserTripMembershipsSubCollection)
              .where('status', isEqualTo: 'active')
              .limit(50)
              .get();
      for (final doc in joinedSnap.docs) {
        final tripId = doc.data()['tripId'] as String? ?? doc.id;
        await addHistoryContinent(firestore.collection(kTripTable).doc(tripId));
      }

      final favouriteIds =
          GlobalVariables.loggedInUser.value?.favouriteTrips ?? [];
      // Read individually: a document-ID batch is denied in full when any
      // favorite has been hidden or deleted, even with a discovery filter.
      await Future.wait(
        favouriteIds
            .take(10)
            .map(
              (tripId) => addHistoryContinent(
                firestore.collection(kTripDiscoveryTable).doc(tripId),
              ),
            ),
      );

      // No history — fall back to popular trips
      if (continents.isEmpty) {
        final popularTrips = await getPopularTrips(loadMore: loadMore);
        discoveryHasMore['recommended'] = discoveryHasMore['popular'] ?? false;
        return popularTrips
            .where((trip) => _isCurrentOrFutureDiscoveryTrip(trip.toMap()))
            .toList();
      }

      final snap = await _discoveryPage(
        firestore
            .collection(kTripDiscoveryTable)
            .where('isDiscoverable', isEqualTo: true)
            .where('continent', whereIn: continents.toList()),
        'recommended',
        loadMore,
      );

      final filteredDocs =
          snap.where((doc) {
            final data = doc.data();
            return data['createdBy'] != uid &&
                _isCurrentOrFutureDiscoveryTrip(data);
          }).toList();

      return filteredDocs
          .map((e) => TripDiscoveryModel.fromMap(e.data()))
          .toList();
    } catch (e) {
      _handleTripError(e, operation: 'getRecommendedTrips');
      rethrow;
    }
  }

  /// get trips by selected continents
  /// [return] list of trips
  /// [logs] logs if there is an error
  static Future<List<TripDiscoveryModel>> getFilteredTrips({
    List<String>? continents,
    bool loadMore = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = firestore
          .collection(kTripDiscoveryTable)
          .where('isDiscoverable', isEqualTo: true);
      if (continents != null && continents.isNotEmpty) {
        query = query.where('continent', whereIn: continents.take(10).toList());
      }
      final snapshot = await _discoveryPage(query, 'filtered', loadMore);
      return snapshot
          .where((doc) => doc.data()['createdBy'] != GlobalVariables.currentUid)
          .map((doc) => TripDiscoveryModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      _handleTripError(e, operation: 'getFilteredTrips');
      rethrow;
    }
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
      _handleTripError(e);
    }
    return [];
  }

  static Future<bool> sendTripInvites({
    required String tripId,
    required String tripTitle,
    required List<String> emails,
    required String requestId,
  }) async {
    try {
      if (emails.isEmpty) return true;
      await functions.httpsCallable('sendTripInvitesV3').call({
        'tripId': tripId,
        'tripTitle': tripTitle,
        'emails': emails,
        'requestId': requestId,
      });
      return true;
    } catch (e) {
      _handleTripError(e);
    }
    return false;
  }
}
