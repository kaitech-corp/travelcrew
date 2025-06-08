import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

import '../../../services/geo_services.dart';

class HomePageController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Initialize with a default value to avoid late initialization error
  TabController? _tabController;
  TabController get tabController => _tabController!;

  final List<String> tabs = ['All', 'Popular', 'Nearby', 'Recommended'];
  final selectedTabIndex = 0.obs;
  final isTabsReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize in the next frame to ensure vsync is properly set up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController = TabController(length: tabs.length, vsync: this);
      _tabController?.addListener(() {
        selectedTabIndex.value = _tabController?.index ?? 0;
      });
      isTabsReady.value = true;
    });
    getTrips();
  }

  RxBool isLoadingMyTrips = true.obs;
  RxBool isLoadingOtherTrips = true.obs;
  RxList<TripModel> myTrips = <TripModel>[].obs;
  RxList<TripModel> filteredMyTrips = <TripModel>[].obs;
  RxList<TripModel> otherTrips = <TripModel>[].obs;
  RxList<TripModel> otherFilteredTrips = <TripModel>[].obs;
  RxList<TripModel> nearbyTrips = <TripModel>[].obs;
  getTrips() async {
    try {
      isLoadingMyTrips.value = true;
      isLoadingOtherTrips.value = true;
      FirebaseTripService.getMyTrips().then((value) {
        isLoadingMyTrips.value = false;
        myTrips.value = value;
        filteredMyTrips.value = value;
        myTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
      });
      getOtherTrips();
    } catch (e) {
      isLoadingMyTrips.value = false;
      isLoadingOtherTrips.value = false;
    }
  }

  getFilterdTrips({
    double minimum = 0,
    double maximum = 10000000,
    List<String> continents = const ['Europe', 'Asia'],
  }) async {
    try {
      isLoadingOtherTrips.value = true;
      await FirebaseTripService.getFilteredTrips(
        minBudget: minimum.toString(),
        maxBudget: maximum.toString(),
        continents: continents,
      ).then((value) {
        isLoadingOtherTrips.value = false;
        otherTrips.value = value;
        otherTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
        otherFilteredTrips.value = value.toList();
      });
    } catch (e) {}
    isLoadingOtherTrips.value = false;
  }

  getOtherTrips() async {
    try {
      isLoadingOtherTrips.value = true;
      FirebaseTripService.getOtherTrips().then((value) {
        isLoadingOtherTrips.value = false;
        otherTrips.value = value;
        otherTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
        otherFilteredTrips.value = value;
      });
    } catch (e) {
      isLoadingOtherTrips.value = false;
    }
  }

  getByLocation() async {
    try {
      otherTrips.clear();
      otherFilteredTrips.clear();
      isLoadingOtherTrips.value = true;
      await GeoServices.determinePosition().then((value) async {
        await FirebaseTripService.getNearbyTrips(
          latitude: value.latitude,
          longitude: value.longitude,
          radius: 100,
        ).then((value) {
          isLoadingOtherTrips.value = false;
          otherTrips.value = value;
          otherTrips.sort((a, b) => a.startDate.compareTo(b.startDate));
          otherFilteredTrips.value = value.toList();
        });
      });
    } catch (e) {
      showCustomSnackBar(content: e.toString());
    }
    isLoadingOtherTrips.value = false;
  }

  applyMyTripsFilter(String filter) {
    filteredMyTrips.value =
        myTrips
            .where(
              (trip) =>
                  trip.title!.toLowerCase().contains(filter.toLowerCase()),
            )
            .toList();
  }

  applyOtherTripsFilter(String filter) {
    otherFilteredTrips.value =
        otherTrips
            .where(
              (trip) =>
                  trip.title!.toLowerCase().contains(filter.toLowerCase()),
            )
            .toList();
  }

  getPopulatTrips() async {
    try {
      isLoadingOtherTrips.value = true;
      FirebaseTripService.getPopularTrips().then((value) {
        isLoadingOtherTrips.value = false;
        otherTrips.value = value;
        otherFilteredTrips.value = value.toList();
      });
    } catch (e) {
      isLoadingOtherTrips.value = false;
    }
  }

  void getRecommendedTrips() {}
}
