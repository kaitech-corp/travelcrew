import 'package:flutter/material.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/activities_tab.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/lodging_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/trip_calendar_service.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

TripModel trip(Map<String, dynamic> fields) => TripModel.fromMap({
  'id': 'trip',
  'createdBy': 'owner',
  'destination': 'Tokyo',
  'country': 'Japan',
  'startDate': '2027-03-13T00:00:00',
  ...fields,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'trip events include the final travel day across DST and year boundaries',
    () {
      for (final dates in [
        ['2027-03-13', '2027-03-15', '2027-03-16'],
        ['2027-12-31', '2027-12-31', '2028-01-01'],
        ['2028-02-28', '2028-02-29', '2028-03-01'],
      ]) {
        final event = TripCalendarService.eventFor(
          trip({'tripStartDate': dates[0], 'tripEndDate': dates[1]}),
        );
        expect(event['startDate'], dates[0]);
        expect(event['endDate'], dates[2]);
      }
      expect(TripCalendarService.eventFor(trip({}))['endDate'], '2027-03-14');
      expect(
        () => TripCalendarService.eventFor(trip({'tripEndDate': '2027-03-12'})),
        throwsFormatException,
      );
    },
  );
  test(
    'calendar opens the platform editor using only trip summary fields',
    () async {
      MethodCall? recorded;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(TripCalendarService.channel, (
        call,
      ) async {
        recorded = call;
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          TripCalendarService.channel,
          null,
        ),
      );
      await TripCalendarService.addTrip(
        trip({'title': 'Spring trip', 'isShared': false}),
      );
      expect(recorded!.method, 'addTrip');
      expect(recorded!.arguments['title'], 'Spring trip');
      expect(recorded!.arguments['location'], 'Tokyo, Japan');
      expect(recorded!.arguments.containsKey('expenses'), false);
    },
  );
  test(
    'activity events preserve instants and handle missing or invalid times',
    () {
      final activity = ActivityModel.fromMap({
        'id': 'museum',
        'title': 'Museum',
        'location': 'Tokyo',
        'description': 'Bring tickets',
        'startDateTime': '2027-04-10T10:00:00+09:00',
        'endDateTime': '2027-04-10T11:30:00+09:00',
      });
      final event = TripCalendarService.eventForActivity(activity);
      expect(
        event['startMilliseconds'],
        DateTime.utc(2027, 4, 10, 1).millisecondsSinceEpoch,
      );
      expect(
        event['endMilliseconds'],
        DateTime.utc(2027, 4, 10, 2, 30).millisecondsSinceEpoch,
      );
      expect(event['notes'], contains('Bring tickets'));
      activity.endDateTime = null;
      final defaultEvent = TripCalendarService.eventForActivity(activity);
      expect(
        (defaultEvent['endMilliseconds'] as int) -
            (defaultEvent['startMilliseconds'] as int),
        3600000,
      );
      activity.endDateTime = activity.startDateTime;
      expect(
        () => TripCalendarService.eventForActivity(activity),
        throwsFormatException,
      );
      activity.startDateTime = null;
      expect(
        () => TripCalendarService.eventForActivity(activity),
        throwsFormatException,
      );
    },
  );
  testWidgets(
    'activity button opens only the selected event and disables unscheduled activities',
    (tester) async {
      final calls = <MethodCall>[];
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(TripCalendarService.channel, (
        call,
      ) async {
        calls.add(call);
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(
          TripCalendarService.channel,
          null,
        ),
      );
      final scheduled = ActivityModel.fromMap({
        'title': 'Museum',
        'startDateTime': '2027-04-10T10:00:00Z',
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ActivityCalendarButton(activity: scheduled)),
        ),
      );
      expect(
        find.text('No end time set; calendar event defaults to 1 hour.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Add to Calendar'));
      await tester.pumpAndSettle();
      expect(calls.single.method, 'addActivity');
      expect(calls.single.arguments['title'], 'Museum');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActivityCalendarButton(
              activity: ActivityModel.fromMap({'title': 'Unscheduled'}),
            ),
          ),
        ),
      );
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
      expect(
        find.text('Set a start date and time to add this activity.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  test(
    'empty legacy lodging is absent, while actual details and costs survive',
    () {
      expect(
        LodgingModel.fromTrip(
          trip({'hotelName': '   ', 'expensePerNight': 0}),
        ).hasDetails,
        false,
      );
      final legacy = LodgingModel.fromTrip(
        trip({'hotelName': 'First hotel', 'expensePerNight': 125}),
      );
      expect(legacy.id, 'legacy');
      expect(legacy.createdBy, 'owner');
      expect(legacy.hasDetails, true);
      expect(
        LodgingModel.fromMap('second', legacy.toMap()).expensePerNight,
        125,
      );
    },
  );
  test(
    'adding lodging starts blank and editing targets the selected option',
    () {
      final controller = SpecificTripViewController();
      addTearDown(controller.onClose);
      controller.tripModel.value = trip({'hotelName': 'Original hotel'});
      final second = LodgingModel(
        id: 'second',
        createdBy: 'member',
        hotelName: 'Second hotel',
        checkInDate: DateTime(2027, 3, 14),
        expensePerNight: 80,
      );
      controller.initLodgingForm(second);
      expect(controller.editingLodging!.id, 'second');
      expect(controller.lodgingHotelNameController.text, 'Second hotel');
      expect(controller.lodgingCostController.text, '80.0');
      controller.initLodgingForm();
      expect(controller.editingLodging, isNull);
      expect(controller.lodgingHotelNameController.text, isEmpty);
      expect(controller.lodgingCheckIn.value, isNull);
      expect(controller.lodgingCostController.text, isEmpty);
      expect(controller.tripModel.value!.hotelName, 'Original hotel');
    },
  );
}
