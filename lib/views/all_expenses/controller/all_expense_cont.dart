import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/utils/debugging.dart';

class AllExpensesController extends GetxController {
  var trips = <TripModel>[].obs;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    // fetchExpenses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchExpenses();
    });
  }

  Future<void> fetchExpenses() async {
    isLoading.value = true;
    try {
      await FirebaseTripService.getMyTrips(isAll: false).then((tripList) {
        if (tripList.isNotEmpty) {
          trips.addAll(tripList);
        }
      });
      kLogging('Fetched trips: ${trips.length}');
    } catch (e) {
      kLogging('Error fetching expenses: $e');
    }
    isLoading.value = false;
  }
}
