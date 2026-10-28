import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/nearby_radius.dart';
import 'package:travel_crew/services/recommendation_runtime.dart';
import 'package:travel_crew/services/recommendation_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/logger.dart';

import '../../../services/geo_services.dart';

typedef DiscoveryPageLoader =
    Future<List<TripDiscoveryModel>> Function({bool loadMore});

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  HomePageController({
    DiscoveryPageLoader? loadAllTrips,
    DiscoveryPageLoader? loadPopularTrips,
  }) : _loadAllTrips = loadAllTrips ?? FirebaseTripService.getOtherTrips,
       _loadPopularTrips =
           loadPopularTrips ?? FirebaseTripService.getPopularTrips;

  final DiscoveryPageLoader _loadAllTrips;
  final DiscoveryPageLoader _loadPopularTrips;
  RecommendationService get recommendations => RecommendationRuntime.service;
  // Initialize with a default value to avoid late initialization error
  TabController? _tabController;
  VoidCallback? _tabListener;
  Worker? _sessionWorker;
  int _requestVersion = 0;
  String _searchQuery = '';
  (double, double)? _nearbyCenter;
  TabController get tabController => _tabController!;

  final List<String> tabs = ['All', 'Popular', 'Nearby', 'Recommended'];
  final selectedTabIndex = 0.obs;
  final isTabsReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    AppLogger.debug('HomePageController initialized');
    // Initialize in the next frame to ensure vsync is properly set up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController = TabController(length: tabs.length, vsync: this);
      _tabListener = () {
        selectedTabIndex.value = _tabController?.index ?? 0;
        if (selectedTabIndex.value == 3 &&
            !recommendations.loaded &&
            !recommendations.loading) {
          getRecommendedTrips();
        }
      };
      _tabController?.addListener(_tabListener!);
      isTabsReady.value = true;
      AppLogger.debug('TabController initialized with ${tabs.length} tabs');
    });
    getTrips();
    _sessionWorker = ever(GlobalVariables.loggedInUser, (_) {
      _requestVersion++;
      otherTrips.clear();
      otherFilteredTrips.clear();
      popularTrips.clear();
      popularFilteredTrips.clear();
      nearbyTrips.clear();
      _nearbyCenter = null;
      discoveryErrors.clear();
      _filterContinents = null;
      selectedTabIndex.value = 0;
      _tabController?.animateTo(0);
      getTrips();
    });
  }

  @override
  void onClose() {
    AppLogger.debug('HomePageController disposing resources');
    final listener = _tabListener;
    if (listener != null) {
      _tabController?.removeListener(listener);
    }
    _tabController?.dispose();
    _sessionWorker?.dispose();
    super.onClose();
  }

  List<String>? _filterContinents;
  String get allDiscoveryKey => _filterContinents == null ? 'all' : 'filtered';
  String get discoveryKey =>
      selectedTabIndex.value == 0
          ? allDiscoveryKey
          : tabs[selectedTabIndex.value].toLowerCase();
  Future<void> loadMoreTrips() async {
    if (isLoadingOtherTrips.value) return;
    switch (selectedTabIndex.value) {
      case 0:
        if (_filterContinents != null) {
          await getFilterdTrips(continents: _filterContinents!, loadMore: true);
        } else {
          await getOtherTrips(loadMore: true);
        }
        break;
      case 1:
        await getPopularTrips(loadMore: true);
        break;
      case 2:
        await getByLocation(loadMore: true);
        break;
      case 3:
        await getRecommendedTrips(loadMore: true);
        break;
    }
  }

  RxBool isLoadingOtherTrips = true.obs;
  final RxMap<String, String> discoveryErrors = <String, String>{}.obs;
  RxList<TripDiscoveryModel> otherTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> otherFilteredTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> popularTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> popularFilteredTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> nearbyTrips = <TripDiscoveryModel>[].obs;
  String? get currentDiscoveryError => discoveryErrors[discoveryKey];
  List<TripDiscoveryModel> get currentDiscoveryTrips => switch (selectedTabIndex
      .value) {
    0 => otherFilteredTrips,
    1 => popularFilteredTrips,
    2 => nearbyTrips,
    _ => const [],
  };

  Future<void> getTrips() => getOtherTrips();

  bool _isCurrent(int version, String uid) =>
      version == _requestVersion && uid == GlobalVariables.currentUid;

  void _setDiscoveryError(String key, String message, Object error) {
    discoveryErrors[key] = message;
    AppLogger.warning('Unable to load $key trips: ${error.runtimeType}');
  }

  void _applySearch() {
    final query = _searchQuery.toLowerCase();
    bool matches(TripDiscoveryModel trip) =>
        (trip.title ?? '').toLowerCase().contains(query);
    otherFilteredTrips.value = otherTrips.where(matches).toList();
    popularFilteredTrips.value = popularTrips.where(matches).toList();
  }

  void removeCachedDiscoveryTrip(String tripId) {
    otherTrips.removeWhere((trip) => trip.id == tripId);
    popularTrips.removeWhere((trip) => trip.id == tripId);
    nearbyTrips.removeWhere((trip) => trip.id == tripId);
    _applySearch();
  }

  void updateCachedDiscoveryTrip(TripModel trip) {
    if (trip.createdBy == GlobalVariables.currentUid ||
        trip.isPrivate == true ||
        trip.tripStatus == TripStatus.deleted.name) {
      removeCachedDiscoveryTrip(trip.id);
      return;
    }

    void replace(RxList<TripDiscoveryModel> list, {bool eligible = true}) {
      final index = list.indexWhere((entry) => entry.id == trip.id);
      if (index < 0) return;
      if (!eligible) {
        list.removeAt(index);
        return;
      }
      final previous = list[index];
      list[index] = TripDiscoveryModel.fromTrip(
        trip,
        creatorDisplayName: previous.creatorDisplayName,
        creatorProfileImage: previous.creatorProfileImage,
      );
    }

    replace(
      otherTrips,
      eligible:
          _filterContinents == null ||
          _filterContinents!.contains(trip.continent),
    );
    replace(popularTrips);
    popularTrips.sort((a, b) => b.favouriteCount.compareTo(a.favouriteCount));
    final center = _nearbyCenter;
    final end = trip.tripEndDate ?? trip.tripStartDate ?? trip.startDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    replace(
      nearbyTrips,
      eligible:
          center != null &&
          trip.tripStatus != TripStatus.cancelled.name &&
          trip.tripStatus != TripStatus.completed.name &&
          !DateTime(end.year, end.month, end.day).isBefore(today) &&
          NearbyRadius.contains(
            centerLatitude: center.$1,
            centerLongitude: center.$2,
            latitude: trip.latitude,
            longitude: trip.longitude,
            radiusKm: 100,
          ),
    );
    _applySearch();
  }

  Future<void> retryDiscovery() async {
    switch (selectedTabIndex.value) {
      case 0:
        if (_filterContinents == null) {
          await getOtherTrips();
        } else {
          await getFilterdTrips(continents: _filterContinents!);
        }
        break;
      case 1:
        await getPopularTrips();
        break;
      case 2:
        await getByLocation();
        break;
    }
  }

  Future<void> getFilterdTrips({
    List<String> continents = const ['Europe', 'Asia'],
    bool loadMore = false,
  }) async {
    final changed = !listEquals(_filterContinents, continents);
    if (changed) {
      otherTrips.clear();
      otherFilteredTrips.clear();
    }
    _filterContinents = List.of(continents);
    final version = ++_requestVersion;
    final uid = GlobalVariables.currentUid;
    const key = 'filtered';
    try {
      isLoadingOtherTrips.value = true;
      discoveryErrors.remove(key);
      final value = await FirebaseTripService.getFilteredTrips(
        loadMore: loadMore,
        continents: continents,
      );
      if (!_isCurrent(version, uid)) return;
      otherTrips.value = value;
      otherTrips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      _applySearch();
    } catch (e) {
      if (_isCurrent(version, uid)) {
        _setDiscoveryError(key, 'Unable to load trips. Please retry.', e);
      }
    } finally {
      if (_isCurrent(version, uid)) isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getOtherTrips({bool loadMore = false}) async {
    if (_filterContinents != null) {
      otherTrips.clear();
      otherFilteredTrips.clear();
    }
    _filterContinents = null;
    final version = ++_requestVersion;
    final uid = GlobalVariables.currentUid;
    const key = 'all';
    try {
      isLoadingOtherTrips.value = true;
      discoveryErrors.remove(key);
      final value = await _loadAllTrips(loadMore: loadMore);
      if (!_isCurrent(version, uid)) return;
      otherTrips.value = value;
      otherTrips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      _applySearch();
    } catch (e) {
      if (_isCurrent(version, uid)) {
        _setDiscoveryError(key, 'Unable to load trips. Please retry.', e);
      }
    } finally {
      if (_isCurrent(version, uid)) isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getByLocation({bool loadMore = false}) async {
    final version = ++_requestVersion;
    final uid = GlobalVariables.currentUid;
    const key = 'nearby';
    try {
      isLoadingOtherTrips.value = true;
      discoveryErrors.remove(key);
      final center = _nearbyCenter;
      final double latitude;
      final double longitude;
      if (loadMore && center != null) {
        (latitude, longitude) = center;
      } else {
        final position = await GeoServices.determinePosition();
        latitude = position.latitude;
        longitude = position.longitude;
      }
      final trips = await FirebaseTripService.getNearbyTrips(
        loadMore: loadMore,
        latitude: latitude,
        longitude: longitude,
        radius: 100,
      );
      if (!_isCurrent(version, uid)) return;
      _nearbyCenter = (latitude, longitude);
      trips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      nearbyTrips.value = trips;
    } catch (e) {
      if (_isCurrent(version, uid)) {
        _setDiscoveryError(
          key,
          'Unable to load nearby trips. Check location access and retry.',
          e,
        );
      }
    } finally {
      if (_isCurrent(version, uid)) isLoadingOtherTrips.value = false;
    }
  }

  void applyOtherTripsFilter(String filter) {
    _searchQuery = filter;
    _applySearch();
  }

  Future<void> getPopularTrips({bool loadMore = false}) async {
    final version = ++_requestVersion;
    final uid = GlobalVariables.currentUid;
    const key = 'popular';
    try {
      isLoadingOtherTrips.value = true;
      discoveryErrors.remove(key);
      final value = await _loadPopularTrips(loadMore: loadMore);
      if (!_isCurrent(version, uid)) return;
      popularTrips.value = value;
      _applySearch();
    } catch (e) {
      if (_isCurrent(version, uid)) {
        _setDiscoveryError(
          key,
          'Unable to load popular trips. Please retry.',
          e,
        );
      }
    } finally {
      if (_isCurrent(version, uid)) isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getRecommendedTrips({bool loadMore = false}) async {
    await recommendations.load(refresh: !loadMore);
  }
}
