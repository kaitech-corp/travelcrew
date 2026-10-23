import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/activities_tab.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

TripModel savedTrip() => TripModel.fromMap({
  'id': 'trip',
  'createdBy': 'owner',
  'destination': 'Tokyo',
  'country': 'Japan',
  'startDate': '2027-04-10T00:00:00',
  'activities': [
    {'id': 'museum', 'tripId': 'trip', 'title': 'Museum', 'description': ''},
    {'id': 'park', 'tripId': 'trip', 'title': 'Park', 'description': ''},
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    GlobalVariables.loggedInUser.value = UserModel(
      uid: 'owner',
      email: 'owner@example.com',
    );
  });
  tearDown(() {
    GlobalVariables.loggedInUser.value = null;
  });

  testWidgets(
    'saved activity delete can be cancelled, then confirmed without stale list indices',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final calls = <String>[];
      final controller = SpecificTripViewController(
        deleteActivity: ({required id, tripId}) async {
          calls.add('$tripId/$id');
          return true;
        },
      );
      addTearDown(controller.onClose);
      controller.tripModel.value = savedTrip();
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder:
              (context, child) => GetMaterialApp(
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: ActivitiesTab(controller: controller),
                  ),
                ),
              ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip('Delete activity'), findsNWidgets(2));
      await tester.tap(find.byTooltip('Delete activity').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(find.text('Museum'), findsOneWidget);
      await tester.tap(find.byTooltip('Delete activity').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(calls, ['trip/museum']);
      expect(find.text('Museum'), findsNothing);
      expect(find.text('Park'), findsOneWidget);
      expect(find.byTooltip('Delete activity'), findsOneWidget);
      expect(tester.takeException(), isNull);
      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'member',
        email: 'member@example.com',
      );
      controller.tripModel.refresh();
      await tester.pumpAndSettle();
      expect(find.byTooltip('Delete activity'), findsNothing);
    },
  );

  test('failed deletion retains the activity and allows retry', () async {
    var success = false;
    final controller = SpecificTripViewController(
      deleteActivity: ({required id, tripId}) async => success,
    );
    addTearDown(controller.onClose);
    controller.tripModel.value = savedTrip();
    final activity = controller.tripModel.value!.activities!.first;
    expect(await controller.removeActivity(activity), isFalse);
    expect(controller.tripModel.value!.activities!.length, 2);
    success = true;
    expect(await controller.removeActivity(activity), isTrue);
    expect(controller.tripModel.value!.activities!.map((item) => item.id), [
      'park',
    ]);
  });

  test(
    'non-owner cannot delete and concurrent duplicate deletes are ignored',
    () async {
      final pending = Completer<bool>();
      var calls = 0;
      final controller = SpecificTripViewController(
        deleteActivity: ({required id, tripId}) {
          calls++;
          return pending.future;
        },
      );
      addTearDown(controller.onClose);
      controller.tripModel.value = savedTrip();
      final ActivityModel activity =
          controller.tripModel.value!.activities!.first;
      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'member',
        email: 'member@example.com',
      );
      expect(await controller.removeActivity(activity), isFalse);
      expect(calls, 0);
      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'owner',
        email: 'owner@example.com',
      );
      final first = controller.removeActivity(activity);
      expect(await controller.removeActivity(activity), isFalse);
      expect(calls, 1);
      pending.complete(true);
      expect(await first, isTrue);
    },
  );
}
