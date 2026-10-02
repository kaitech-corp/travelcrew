import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

void main() {
  test('deleted trips never appear in Upcoming, Active, or Past', () {
    final controller = MyTripsController();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final offset in [-10, 0, 10]) {
      for (final deleted in [false, true]) {
        final date = today.add(Duration(days: offset));
        controller.trips.add(
          TripModel(
            id: '$offset-$deleted',
            destination: 'Tokyo',
            createdBy: 'owner',
            country: 'Japan',
            startDate: date,
            tripEndDate: date,
            endDate: '',
            daysToGo: offset,
            images: [],
            tripStatus: deleted ? 'deleted' : 'upcoming',
          ),
        );
      }
    }
    for (final tab in [0, 1, 2]) {
      controller.changeTab(tab);
      expect(controller.filteredTrips, hasLength(1));
      expect(controller.filteredTrips.single.tripStatus, 'upcoming');
    }
    controller.onClose();
  });
}
