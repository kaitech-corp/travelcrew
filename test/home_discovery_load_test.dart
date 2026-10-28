import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/views/home_page/controller/home_page_controller.dart';

TripDiscoveryModel _trip(String id) => TripDiscoveryModel(
  id: id,
  destination: 'Tokyo',
  country: 'Japan',
  startDate: DateTime(2027),
  endDate: '',
  images: const [],
  createdBy: 'owner',
  title: id,
);

TripModel _fullTrip(String id, {bool isPrivate = false}) => TripModel.fromMap({
  'id': id,
  'createdBy': 'owner',
  'destination': 'Tokyo',
  'country': 'Japan',
  'startDate': '2027-01-01',
  'tripStartDate': '2027-01-01',
  'tripEndDate': '2027-01-10',
  'title': 'Updated',
  'isPrivate': isPrivate,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('late All response cannot replace the Popular tab', () async {
    final allResponse = Completer<List<TripDiscoveryModel>>();
    final controller = HomePageController(
      loadAllTrips: ({loadMore = false}) => allResponse.future,
      loadPopularTrips: ({loadMore = false}) async => [_trip('popular')],
    );
    addTearDown(controller.onClose);

    final allLoad = controller.getOtherTrips();
    controller.selectedTabIndex.value = 1;
    await controller.getPopularTrips();
    allResponse.complete([_trip('all')]);
    await allLoad;

    expect(controller.currentDiscoveryTrips.single.id, 'popular');
    expect(controller.otherTrips, isEmpty);
    expect(controller.discoveryErrors, isEmpty);
    expect(controller.isLoadingOtherTrips.value, isFalse);
  });

  test('failed refresh preserves cards and retry clears the error', () async {
    var attempts = 0;
    final controller = HomePageController(
      loadAllTrips: ({loadMore = false}) async {
        attempts++;
        if (attempts == 2) throw StateError('offline');
        return [_trip(attempts == 1 ? 'original' : 'refreshed')];
      },
    );
    addTearDown(controller.onClose);

    await controller.getOtherTrips();
    expect(controller.otherFilteredTrips.single.id, 'original');
    await controller.getOtherTrips();
    expect(controller.currentDiscoveryError, isNotNull);
    expect(controller.otherFilteredTrips.single.id, 'original');

    await controller.retryDiscovery();
    expect(controller.currentDiscoveryError, isNull);
    expect(controller.otherFilteredTrips.single.id, 'refreshed');
  });

  test('failed first load is an error rather than an empty result', () async {
    final controller = HomePageController(
      loadAllTrips: ({loadMore = false}) async => throw StateError('offline'),
    );
    addTearDown(controller.onClose);

    await controller.getOtherTrips();
    expect(controller.currentDiscoveryTrips, isEmpty);
    expect(controller.currentDiscoveryError, contains('retry'));
    expect(controller.isLoadingOtherTrips.value, isFalse);
  });

  test('local trip changes reconcile every discovery cache', () {
    final controller = HomePageController();
    addTearDown(controller.onClose);
    final cached = TripDiscoveryModel(
      id: 'trip',
      destination: 'Tokyo',
      country: 'Japan',
      startDate: DateTime(2027),
      endDate: '',
      images: const [],
      createdBy: 'owner',
      title: 'Old title',
      creatorDisplayName: 'Owner name',
    );
    controller.otherTrips.add(cached);
    controller.popularTrips.add(cached);
    controller.nearbyTrips.add(cached);

    controller.updateCachedDiscoveryTrip(_fullTrip('trip'));
    expect(controller.otherTrips.single.title, 'Updated');
    expect(controller.popularTrips.single.title, 'Updated');
    expect(controller.otherTrips.single.creatorDisplayName, 'Owner name');
    expect(controller.nearbyTrips, isEmpty);

    controller.updateCachedDiscoveryTrip(_fullTrip('trip', isPrivate: true));
    expect(controller.otherTrips, isEmpty);
    expect(controller.popularTrips, isEmpty);
    expect(controller.otherFilteredTrips, isEmpty);

    controller.otherTrips.add(cached);
    controller.popularTrips.add(cached);
    controller.nearbyTrips.add(cached);
    controller.removeCachedDiscoveryTrip('trip');
    expect(controller.otherTrips, isEmpty);
    expect(controller.popularTrips, isEmpty);
    expect(controller.nearbyTrips, isEmpty);
  });
}
