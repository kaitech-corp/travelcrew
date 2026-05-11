import 'package:get/get.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/home_page/controller/home_page_controller.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

void removeTripOverAll(TripModel trip) {
  if (Get.isRegistered<HomePageController>()) {
    final HomePageController controller = Get.find<HomePageController>();
    controller.otherTrips.removeWhere((element) => element.id == trip.id);
    controller.otherFilteredTrips.removeWhere(
      (element) => element.id == trip.id,
    );
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
    if (trip.createdBy != GlobalVariables.currentUid &&
        trip.isPrivate != true &&
        trip.tripStatus != TripStatus.deleted.name) {
      final discovery = TripDiscoveryModel.fromTrip(trip);
      controller.otherTrips.insert(0, discovery);
      controller.otherFilteredTrips.insert(0, discovery);
    }
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
    final int index = controller.otherTrips.indexWhere(
      (element) => element.id == trip.id,
    );
    if (index != -1) {
      if (trip.createdBy == GlobalVariables.currentUid ||
          trip.isPrivate == true ||
          trip.tripStatus == TripStatus.deleted.name) {
        controller.otherTrips.removeAt(index);
        controller.otherFilteredTrips.removeWhere(
          (element) => element.id == trip.id,
        );
      } else {
        final discovery = TripDiscoveryModel.fromTrip(trip);
        controller.otherTrips[index] = discovery;
        final filteredIndex = controller.otherFilteredTrips.indexWhere(
          (element) => element.id == trip.id,
        );
        if (filteredIndex != -1) {
          controller.otherFilteredTrips[filteredIndex] = discovery;
        }
      }
    }
  }
  if (Get.isRegistered<MyTripsController>()) {
    final MyTripsController controller = Get.find<MyTripsController>();
    final int index = controller.trips.indexWhere(
      (element) => element.id == trip.id,
    );
    if (index != -1) {
      controller.trips[index] = trip;
      controller.filteredTrips[index] = trip;
    }
  }
}
