import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/views/home_page/controller/home_page_controller.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

void removeTripOverAll(TripModel trip) {
  if (Get.isRegistered<HomePageController>()) {
    final HomePageController controller = Get.find<HomePageController>();
    controller.myTrips.removeWhere((element) => element.id == trip.id);
    controller.filteredMyTrips.removeWhere((element) => element.id == trip.id);
  }
  if (Get.isRegistered<MyTripsController>()) {
    final MyTripsController controller = Get.find<MyTripsController>();
    controller.trips.removeWhere((element) => element.id == trip.id);
    controller.filteredTrips.removeWhere((element) => element.id == trip.id);
  }
}

void addTripOverAll(TripModel trip) {
  if (Get.isRegistered<HomePageController>()) {
    final HomePageController controller = Get.find<HomePageController>();
    controller.myTrips.insert(0, trip);
    controller.filteredMyTrips.insert(0, trip);
  }
  if (Get.isRegistered<MyTripsController>()) {
    final MyTripsController controller = Get.find<MyTripsController>();
    controller.trips.insert(0, trip);
    controller.filteredTrips.insert(0, trip);
  }
}

void updateTripOverAll(TripModel trip) {
  if (Get.isRegistered<HomePageController>()) {
    final HomePageController controller = Get.find<HomePageController>();
    final int index = controller.myTrips.indexWhere(
      (element) => element.id == trip.id,
    );
    if (index != -1) {
      controller.myTrips[index] = trip;
      controller.filteredMyTrips[index] = trip;
    }
  }
  if (Get.isRegistered<MyTripsController>()) {
    final MyTripsController controller = Get.find<MyTripsController>();
    final int index = controller.trips.indexWhere((element) => element.id == trip.id);
    if (index != -1) {
      controller.trips[index] = trip;
      controller.filteredTrips[index] = trip;
    }
  }
}
