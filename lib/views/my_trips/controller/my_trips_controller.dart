import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';

class MyTripsController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Track which tab is selected: 0 = Upcoming, 1 = Active, 2 = Past
  final RxInt selectedTabIndex = 0.obs;
  RxList<TripModel> trips = <TripModel>[].obs;
  TextEditingController searchController = TextEditingController();
  RxList<TripModel> filteredTrips = <TripModel>[].obs;
  @override
  void onInit() {
    super.onInit();
    getTrips();
  }

  RxBool isLoading = true.obs;

  Future<void> getTrips() async {
    try {
      isLoading.value = true;
      trips.value = await FirebaseTripService.getMyTrips(isAll: true);
      _filterTripsByTab();
    } catch (e) {
      debugPrint('Failed to load trips: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _filterTripsByTab() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    filteredTrips.value =
        trips.where((trip) {
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

    applyFilter();
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void applyFilter() {
    if (searchController.text.isNotEmpty) {
      filteredTrips.value =
          filteredTrips.where((trip) {
            return (trip.title?.toLowerCase() ?? '').contains(
                  searchController.text.toLowerCase(),
                ) ||
                (trip.destination.toLowerCase()).contains(
                  searchController.text.toLowerCase(),
                );
          }).toList();
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
    _filterTripsByTab();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
