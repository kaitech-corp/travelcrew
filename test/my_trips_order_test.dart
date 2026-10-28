import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/session_services.dart';
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
      controller.searchController.text = 'recent';
      controller.applyFilter();
      expect(controller.filteredTrips.map((item) => item.id), ['recent']);
      controller.searchController.clear();
      controller.applyFilter();
      expect(controller.filteredTrips.map((item) => item.id), [
        'same end later start',
        'recent',
        'no end',
        'old',
      ]);
      controller.searchController.text = '  NO END  ';
      controller.applyFilter();
      expect(controller.filteredTrips.map((item) => item.id), ['no end']);
    },
  );

  test(
    'card members are cached per account and stale responses are hidden',
    () async {
      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'owner',
        email: 'owner@example.com',
      );
      addTearDown(() => GlobalVariables.loggedInUser.value = null);
      final first = Completer<List<PublicUserModel>>();
      var calls = 0;
      final controller = MyTripsController(
        loadCardMembers: (_) {
          calls++;
          if (calls == 1) return first.future;
          return Future.value([
            PublicUserModel(uid: 'other', displayName: 'Other'),
          ]);
        },
      );
      addTearDown(controller.onClose);
      final card = trip('trip', '2027-01-01');
      final pending = controller.cardMembers(card);
      expect(identical(pending, controller.cardMembers(card)), isTrue);
      expect(calls, 1);

      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'other',
        email: 'other@example.com',
      );
      first.complete([PublicUserModel(uid: 'owner', displayName: 'Owner')]);
      expect(await pending, isEmpty);
      expect((await controller.cardMembers(card)).single.uid, 'other');
      expect(calls, 2);
    },
  );

  test('failed member lookups can retry for a visible card', () async {
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'owner',
      email: 'owner@example.com',
    );
    addTearDown(() => GlobalVariables.loggedInUser.value = null);
    var calls = 0;
    final controller = MyTripsController(
      loadCardMembers: (_) async {
        calls++;
        if (calls == 1) throw StateError('offline');
        return [PublicUserModel(uid: 'owner', displayName: 'Owner')];
      },
    );
    addTearDown(controller.onClose);
    final card = trip('trip', '2027-01-01');
    await expectLater(controller.cardMembers(card), throwsStateError);
    expect((await controller.cardMembers(card)).single.uid, 'owner');
    expect(calls, 2);
  });

  test('card member cache stays bounded as more trips are viewed', () async {
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'owner',
      email: 'owner@example.com',
    );
    addTearDown(() => GlobalVariables.loggedInUser.value = null);
    var calls = 0;
    final controller = MyTripsController(
      loadCardMembers: (_) async {
        calls++;
        return [];
      },
    );
    addTearDown(controller.onClose);
    for (var index = 0; index < 81; index++) {
      await controller.cardMembers(trip('trip-$index', '2027-01-01'));
    }
    await controller.cardMembers(trip('trip-0', '2027-01-01'));
    expect(calls, 82);
  });
}
