import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

TripModel trip(String id, String start, [String? end]) => TripModel.fromMap({
  'id': id,
  'createdBy': 'owner',
  'title': id,
  'destination': 'Tokyo',
  'country': 'Japan',
  'startDate': start,
  'tripStartDate': start,
  if (end != null) 'tripEndDate': end,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'past trips show most recently ended first, with start-date fallback and search preserving order',
    () {
      final controller = MyTripsController();
      addTearDown(controller.onClose);
      controller.trips.value = [
        trip('old', '2020-01-01', '2020-01-03'),
        trip('recent', '2022-01-01', '2022-01-10'),
        trip('no end', '2021-05-01'),
        trip('same end later start', '2022-01-07', '2022-01-10'),
      ];
      controller.changeTab(2);
      expect(controller.filteredTrips.map((item) => item.id), [
        'same end later start',
        'recent',
        'no end',
        'old',
      ]);
      controller.searchController.text = 'Tokyo';
      controller.applyFilter();
      expect(controller.filteredTrips.first.id, 'same end later start');
      expect(controller.filteredTrips.last.id, 'old');
    },
  );
}
