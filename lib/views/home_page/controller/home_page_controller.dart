import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/error_handler.dart';
import 'package:travel_crew/utils/logger.dart';

import '../../../services/geo_services.dart';

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  // Initialize with a default value to avoid late initialization error
  TabController? _tabController;
  VoidCallback? _tabListener;
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
      };
      _tabController?.addListener(_tabListener!);
      isTabsReady.value = true;
      AppLogger.debug('TabController initialized with ${tabs.length} tabs');
    });
    getTrips();
  }

  @override
  void onClose() {
    AppLogger.debug('HomePageController disposing resources');
    final listener = _tabListener;
    if (listener != null) {
      _tabController?.removeListener(listener);
    }
    _tabController?.dispose();
    super.onClose();
  }

  List<String>? _filterContinents;
  String get discoveryKey =>
      selectedTabIndex.value == 0
          ? (_filterContinents == null ? 'all' : 'filtered')
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
  RxList<TripDiscoveryModel> otherTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> otherFilteredTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> nearbyTrips = <TripDiscoveryModel>[].obs;
  RxList<TripDiscoveryModel> recommendedTrips = <TripDiscoveryModel>[].obs;
  Future<void> getTrips() async {
    try {
      AppLogger.debug('Starting to fetch trips');
      isLoadingOtherTrips.value = true;

      await getOtherTrips();
    } catch (error, stackTrace) {
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'getTrips',
      );
      isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getFilterdTrips({
    List<String> continents = const ['Europe', 'Asia'],
    bool loadMore = false,
  }) async {
    try {
      isLoadingOtherTrips.value = true;
      _filterContinents = continents;
      final value = await FirebaseTripService.getFilteredTrips(
        loadMore: loadMore,
        continents: continents,
      );
      otherTrips.value = value;
      otherTrips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      otherFilteredTrips.value = value.toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting filtered trips: $e');
      }
    } finally {
      isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getOtherTrips({bool loadMore = false}) async {
    _filterContinents = null;
    try {
      isLoadingOtherTrips.value = true;
      final value = await FirebaseTripService.getOtherTrips(loadMore: loadMore);
      otherTrips.value = value;
      otherTrips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      otherFilteredTrips.value = value;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting other trips: $e');
      }
    } finally {
      isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getByLocation({bool loadMore = false}) async {
    try {
      nearbyTrips.clear();
      isLoadingOtherTrips.value = true;
      final position = await GeoServices.determinePosition();
      final trips = await FirebaseTripService.getNearbyTrips(
        loadMore: loadMore,
        latitude: position.latitude,
        longitude: position.longitude,
        radius: 100,
      );
      trips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      nearbyTrips.value = trips;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting trips by location: $e');
      }
      if (e is FirebaseException && e.plugin == 'cloud_firestore') {
        ErrorHandler.handleFirebaseError(e, operation: 'getByLocation');
      } else {
        showCustomSnackBar(content: e.toString());
      }
    } finally {
      isLoadingOtherTrips.value = false;
    }
  }

  void applyOtherTripsFilter(String filter) {
    otherFilteredTrips.value =
        otherTrips
            .where(
              (trip) => (trip.title ?? '').toLowerCase().contains(
                filter.toLowerCase(),
              ),
            )
            .toList();
  }

  Future<void> getPopularTrips({bool loadMore = false}) async {
    try {
      isLoadingOtherTrips.value = true;
      final value = await FirebaseTripService.getPopularTrips(
        loadMore: loadMore,
      );
      otherTrips.value = value;
      otherFilteredTrips.value = value.toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting popular trips: $e');
      }
    } finally {
      isLoadingOtherTrips.value = false;
    }
  }

  Future<void> getRecommendedTrips({bool loadMore = false}) async {
    try {
      recommendedTrips.clear();
      isLoadingOtherTrips.value = true;
      final trips = await FirebaseTripService.getRecommendedTrips(
        loadMore: loadMore,
      );
      trips.sort(
        (a, b) => a.effectiveStartDate.compareTo(b.effectiveStartDate),
      );
      recommendedTrips.value = trips;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting recommended trips: $e');
      }
    } finally {
      isLoadingOtherTrips.value = false;
    }
  }
}
