import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

TripModel _upcomingTrip(String id) {
  final date = DateTime.now().add(const Duration(days: 30));
  return TripModel(
    id: id,
    destination: 'Tokyo',
    createdBy: 'owner',
    country: 'Japan',
    startDate: date,
    tripStartDate: date,
    tripEndDate: date.add(const Duration(days: 5)),
    endDate: '',
    daysToGo: 30,
    images: [],
    tripStatus: 'upcoming',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('load failure is visible and a retry can recover', () async {
    var attempts = 0;
    final controller = MyTripsController(
      loadTrips: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('offline');
        return MyTripsLoad([_upcomingTrip('recovered')], hasMore: false);
      },
    );
    addTearDown(controller.onClose);

    await controller.getTrips();
    expect(controller.loadError.value, isNotNull);
    expect(controller.trips, isEmpty);
    expect(controller.isLoading.value, isFalse);

    await controller.getTrips();
    expect(controller.loadError.value, isNull);
    expect(controller.filteredTrips.single.id, 'recovered');
  });

  test('failed refresh preserves loaded trips until retry succeeds', () async {
    var attempts = 0;
    final controller = MyTripsController(
      loadTrips: (_) async {
        attempts++;
        if (attempts == 2) throw StateError('offline');
        return MyTripsLoad([
          _upcomingTrip(attempts == 1 ? 'original' : 'refreshed'),
        ], hasMore: false);
      },
    );
    addTearDown(controller.onClose);

    await controller.getTrips();
    await controller.getTrips();
    expect(controller.loadError.value, isNotNull);
    expect(controller.filteredTrips.single.id, 'original');

    await controller.getTrips();
    expect(controller.loadError.value, isNull);
    expect(controller.filteredTrips.single.id, 'refreshed');
  });

  test('show more raises the bound without hiding loaded trips', () async {
    final requested = <int>[];
    final controller = MyTripsController(
      loadTrips: (maxTrips) async {
        requested.add(maxTrips);
        final count = maxTrips < 150 ? maxTrips : 150;
        return MyTripsLoad([
          for (var i = 0; i < count; i++) _upcomingTrip('trip-$i'),
        ], hasMore: count < 150);
      },
    );
    addTearDown(controller.onClose);

    await controller.getTrips();
    expect(requested, [MyTripsController.pageSize]);
    expect(controller.trips.length, MyTripsController.pageSize);
    expect(controller.hasMore.value, isTrue);

    final more = controller.loadMoreTrips();
    expect(controller.isLoadingMore.value, isTrue);
    expect(controller.isLoading.value, isFalse);
    await more;
    expect(requested.last, MyTripsController.pageSize * 2);
    expect(controller.trips.length, 150);
    expect(controller.hasMore.value, isFalse);
    expect(controller.isLoadingMore.value, isFalse);

    await controller.loadMoreTrips();
    expect(requested.length, 2, reason: 'no request once everything loaded');
  });
}
