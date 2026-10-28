import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';

class MyTripsController extends GetxController {
  MyTripsController({
    Future<MyTripsLoad> Function(int maxTrips)? loadTrips,
    Future<List<PublicUserModel>> Function(TripModel trip)? loadCardMembers,
  }) : _loadTrips =
           loadTrips ??
           ((maxTrips) => FirebaseTripService.getMyTripsBounded(
             isAll: true,
             summaryOnly: true,
             maxTrips: maxTrips,
           )),
       _loadCardMembers = loadCardMembers ?? _fetchCardMembers;

  final Future<MyTripsLoad> Function(int maxTrips) _loadTrips;

  /// Trips are read in bounded batches; Show more raises the bound so large
  /// accounts do not read every trip document on first open.
  static const int pageSize = 100;
  int _maxTrips = pageSize;
  String? _boundUid;
  final RxBool hasMore = false.obs;
  final RxBool isLoadingMore = false.obs;
  final Future<List<PublicUserModel>> Function(TripModel) _loadCardMembers;
  final Map<String, Future<List<PublicUserModel>>> _cardMembers = {};
  static const int _maxCardMemberCache = 80;

  static Future<List<PublicUserModel>> _fetchCardMembers(TripModel trip) async {
    final roster = await FirebaseTripService.getTripMemberRoster(
      tripId: trip.id,
    );
    final ids =
        roster.activeIds.isNotEmpty
            ? roster.activeIds
            : (!roster.hasRecords && trip.joinedUsers?.isNotEmpty == true
                ? <String>{trip.createdBy, ...trip.joinedUsers!}.toList()
                : <String>[]);
    if (ids.isEmpty) return [];
    return AuthService.getTripUsers(userIds: ids);
  }

  Future<List<PublicUserModel>> cardMembers(TripModel trip) {
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty) return Future.value([]);
    final key = '$uid:${trip.id}';
    final existing = _cardMembers.remove(key);
    if (existing != null) {
      _cardMembers[key] = existing;
      return existing;
    }
    if (_cardMembers.length >= _maxCardMemberCache) {
      _cardMembers.remove(_cardMembers.keys.first);
    }
    final future = Future.sync(() => _loadCardMembers(trip)).then(
      (members) =>
          uid == GlobalVariables.currentUid ? members : <PublicUserModel>[],
    );
    _cardMembers[key] = future;
    future.then<void>(
      (_) {},
      onError: (Object _, StackTrace stackTrace) {
        if (identical(_cardMembers[key], future)) _cardMembers.remove(key);
      },
    );
    return future;
  }

  StreamSubscription<dynamic>? _membershipSubscription;
  Worker? _sessionWorker;
  Timer? _refreshTimer;
  int _loadVersion = 0;
  // Track which tab is selected: 0 = Upcoming, 1 = Active, 2 = Past
  final RxInt selectedTabIndex = 0.obs;
  RxList<TripModel> trips = <TripModel>[].obs;
  TextEditingController searchController = TextEditingController();
  RxList<TripModel> filteredTrips = <TripModel>[].obs;
  @override
  void onInit() {
    super.onInit();
    getTrips();
    _watchMemberships();
    _sessionWorker = ever(GlobalVariables.loggedInUser, (_) {
      _loadVersion++;
      _cardMembers.clear();
      trips.clear();
      filteredTrips.clear();
      loadError.value = null;
      _watchMemberships();
    });
  }

  void _watchMemberships() {
    _membershipSubscription?.cancel();
    _refreshTimer?.cancel();
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty) return;
    _membershipSubscription = firestore
        .collection('users')
        .doc(uid)
        .collection('tripMemberships')
        .orderBy('joinedAt', descending: true)
        .snapshots()
        .listen(
          (_) {
            _refreshTimer?.cancel();
            _refreshTimer = Timer(const Duration(milliseconds: 200), getTrips);
          },
          onError: (Object error) {
            debugPrint(
              'Unable to refresh trip memberships: ${error.runtimeType}',
            );
          },
        );
  }

  RxBool isLoading = true.obs;
  RxnString loadError = RxnString();

  Future<void> getTrips({bool showLoader = true}) async {
    final version = ++_loadVersion;
    final uid = GlobalVariables.currentUid;
    if (_boundUid != uid) {
      _boundUid = uid;
      _maxTrips = pageSize;
    }
    try {
      if (showLoader) isLoading.value = true;
      final loaded = await _loadTrips(_maxTrips);
      if (version != _loadVersion || uid != GlobalVariables.currentUid) return;
      trips.value = loaded.trips;
      hasMore.value = loaded.hasMore;
      _cardMembers.clear();
      _filterTripsByTab();
      loadError.value = null;
    } catch (e) {
      debugPrint('Failed to load trips: $e');
      if (version == _loadVersion && uid == GlobalVariables.currentUid) {
        loadError.value =
            'Unable to load trips. Check your connection and retry.';
      }
    } finally {
      if (version == _loadVersion && showLoader) isLoading.value = false;
    }
  }

  /// Raises the load bound by one page and reloads without hiding the list.
  /// A failure keeps the loaded cards and shows the retry banner.
  Future<void> loadMoreTrips() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    _maxTrips += pageSize;
    try {
      await getTrips(showLoader: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _filterTripsByTab() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final visible =
        trips.where((trip) {
          if (trip.tripStatus == TripStatus.deleted.name) return false;
          final start = trip.tripStartDate ?? trip.startDate;
          final end = trip.tripEndDate ?? start;

          if (selectedTabIndex.value == 0) {
            // Upcoming: trip start date is in the future
            return start.isAfter(now);
          } else if (selectedTabIndex.value == 1) {
            // Active: trip is currently in progress (today is between start and end date)
            return (start.isBefore(now) || isSameDay(start, now)) &&
                (end.isAfter(now) || isSameDay(end, now));
          } else if (selectedTabIndex.value == 2) {
            // Past: trip end date has passed
            return end.isBefore(today);
          }
          return false;
        }).toList();

    if (selectedTabIndex.value == 2) {
      visible.sort((a, b) {
        final aEnd = a.tripEndDate ?? a.tripStartDate ?? a.startDate;
        final bEnd = b.tripEndDate ?? b.tripStartDate ?? b.startDate;
        final byEnd = bEnd.compareTo(aEnd);
        if (byEnd != 0) return byEnd;
        return (b.tripStartDate ?? b.startDate).compareTo(
          a.tripStartDate ?? a.startDate,
        );
      });
    }
    final query = searchController.text.trim().toLowerCase();
    filteredTrips.value =
        query.isEmpty
            ? visible
            : visible
                .where(
                  (trip) =>
                      (trip.title?.toLowerCase().contains(query) ?? false) ||
                      trip.destination.toLowerCase().contains(query),
                )
                .toList();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void applyFilter() {
    _filterTripsByTab();
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    _filterTripsByTab();
  }

  @override
  void onClose() {
    _loadVersion++;
    _cardMembers.clear();
    _membershipSubscription?.cancel();
    _sessionWorker?.dispose();
    _refreshTimer?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
