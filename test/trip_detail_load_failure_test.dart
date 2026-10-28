import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

TripDiscoveryModel _preview({String createdBy = 'owner'}) => TripDiscoveryModel(
  id: 'trip',
  destination: 'Tokyo',
  country: 'Japan',
  startDate: DateTime(2027),
  endDate: '',
  images: const [],
  createdBy: createdBy,
);

TripModel _trip() => TripModel.fromMap({
  'id': 'trip',
  'createdBy': 'owner',
  'destination': 'Tokyo',
  'country': 'Japan',
  'startDate': '2027-01-01',
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'owner',
      email: 'owner@example.com',
    );
  });
  tearDown(() => GlobalVariables.loggedInUser.value = null);

  test('failed trip hydration shows error and retry recovers', () async {
    var attempts = 0;
    final controller = SpecificTripViewController(
      loadTrip: ({required tripId}) async {
        expect(tripId, 'trip');
        attempts++;
        if (attempts == 1) throw StateError('offline');
        return _trip();
      },
    );
    addTearDown(controller.onClose);

    await controller.initializeFromArgument(_preview());
    expect(controller.tripModel.value, isNull);
    expect(controller.tripLoadError.value, contains('retry'));
    expect(controller.isLoadingTrip.value, isFalse);

    await controller.initializeFromArgument(_preview());
    expect(controller.tripModel.value?.id, 'trip');
    expect(controller.tripLoadError.value, isNull);
  });

  test('absent trip remains distinct from read failure', () async {
    final controller = SpecificTripViewController(
      loadTrip: ({required tripId}) async => null,
    );
    addTearDown(controller.onClose);

    await controller.initializeFromArgument(_preview());
    expect(controller.tripModel.value, isNull);
    expect(controller.tripLoadError.value, 'Trip unavailable.');
  });

  test('trip loaded after account change is discarded', () async {
    final response = Completer<TripModel?>();
    final controller = SpecificTripViewController(
      loadTrip: ({required tripId}) => response.future,
    );
    addTearDown(controller.onClose);

    final load = controller.initializeFromArgument(_preview());
    await Future<void>.delayed(Duration.zero);
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'other',
      email: 'other@example.com',
    );
    response.complete(_trip());
    await load;

    expect(controller.tripModel.value, isNull);
  });

  test('membership read failure does not show a nonmember preview', () async {
    var attempts = 0;
    final controller = SpecificTripViewController(
      checkTripMember: ({required tripId, required userId}) async {
        expect(tripId, 'trip');
        expect(userId, 'owner');
        attempts++;
        if (attempts == 1) throw StateError('offline');
        return true;
      },
      loadTrip: ({required tripId}) async => _trip(),
    );
    addTearDown(controller.onClose);

    await controller.initializeFromArgument(
      _preview(createdBy: 'someone-else'),
    );
    expect(controller.tripModel.value, isNull);
    expect(controller.tripLoadError.value, contains('retry'));

    await controller.initializeFromArgument(
      _preview(createdBy: 'someone-else'),
    );
    expect(controller.tripModel.value?.id, 'trip');
    expect(controller.tripLoadError.value, isNull);
  });

  test('a trip card is refreshed before editable detail is shown', () async {
    var calls = 0;
    final controller = SpecificTripViewController(
      loadTrip: ({required tripId}) async {
        calls++;
        expect(tripId, 'trip');
        return _trip().copyWith(title: 'Current server title');
      },
    );
    addTearDown(controller.onClose);

    await controller.initializeFromArgument(
      _trip().copyWith(title: 'Stale card'),
    );
    expect(calls, 1);
    expect(controller.tripModel.value?.title, 'Current server title');
  });
}
