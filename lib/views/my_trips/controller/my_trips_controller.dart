import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';

class MyTripsController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Track which tab is selected: 0 = Upcoming, 1 = Complete
  final RxInt selectedTabIndex = 0.obs;
  RxList<TripModel> trips = <TripModel>[].obs;
  TextEditingController searchController = TextEditingController();
  RxList<TripModel> filteredTrips = <TripModel>[].obs;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  RxBool isLoading = true.obs;

  getTrips() async {
    try {
      isLoading.value = true;
      trips.value = await FirebaseTripService.getMyTrips(
        tripStatus:
            selectedTabIndex.value == 0
                ? TripStatus.upcoming.name
                : TripStatus.completed.name,
      );
      filteredTrips.value = trips.toList();
    } catch (e) {}
    isLoading.value = false;
  }

  applyFilter() {
    if (selectedTabIndex.value == 1) {
      filteredTrips.value =
          trips.where((trip) {
            return (trip.title?.toLowerCase() ?? '') ==
                searchController.text.toLowerCase();
          }).toList();
    }
  }

  void changeTab(int index) {
    trips.shuffle();
    selectedTabIndex.value = index;
    getTrips();
  }
}
