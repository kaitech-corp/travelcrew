import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/transportation_editor_controller.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/transportation_editor.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/transport_tab.dart';
import 'transportation_preview.dart' as preview;

TransportationModel entry(
  String id, {
  String mode = 'driving',
  String? departure,
  String? arrival,
}) => TransportationModel.fromMap(id, 'trip', {
  'userId': 'owner',
  'mode': mode,
  'departure': departure,
  'arrival': arrival,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'saving and closing the modal keeps text controllers alive through dismissal',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: preview.Preview()));
      await tester.tap(find.text('Add Transportation'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes (optional)'),
        'Hotel shuttle',
      );
      await tester.ensureVisible(find.text('Save Transportation'));
      await tester.tap(find.text('Save Transportation'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(TransportationEditor), findsNothing);
      await tester.scrollUntilVisible(find.text('Hotel shuttle'), 200);
      expect(find.text('Hotel shuttle'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Add Transportation'), -200);
      await tester.tap(find.text('Add Transportation'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes (optional)'),
        'Unsaved note',
      );
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Unsaved note'), findsNothing);
    },
  );
  test(
    'manual trip imports retain mixed modes, travelers, and venue offsets',
    () {
      final controller = CreateTripController();
      addTearDown(controller.onClose);
      controller.setFromImport({
        'title': 'Tokyo trip',
        'destination': 'Tokyo',
        'country': 'Japan',
        'start_date': '2027-04-10',
        'end_date': '2027-04-12',
        'transportation': [
          {
            'mode': 'flight',
            'service_number': 'TC123',
            'departure': '2027-04-10T10:00:00-07:00',
            'arrival': '2027-04-11T14:00:00+09:00',
            'travelers': ['Randy', 'Alex'],
          },
          {'mode': 'scooter', 'title': 'Scooter rental'},
          {'mode': 'train', 'departure': '2027-04-12'},
        ],
      });
      final imported = controller.importedTransportation;
      expect(imported.length, 3);
      expect(imported.first.serviceNumber, 'TC123');
      expect(imported.first.travelerNames, ['Randy', 'Alex']);
      expect(imported.first.departure, '2027-04-10T10:00:00-07:00');
      expect(imported.first.arrival, '2027-04-11T14:00:00+09:00');
      expect(imported[1].mode, TransportationMode.scooter);
      expect(imported[1].departure, isNull);
      expect(imported[2].departure, '2027-04-12');
    },
  );
  test('MCP flight records reopen with local clocks, notes and saver name', () {
    final record = TransportationModel.fromMap('transport_0', 'trip', {
      'id': 'transport_0',
      'tripId': 'trip',
      'userId': 'owner',
      'displayName': 'Randy',
      'mode': 'flight',
      'departure': '2027-03-14T02:30:00',
      'arrival': '2027-03-14T01:30:00',
      'notes': 'Example Air TC123, Tokyo to Los Angeles',
    });
    expect(record.mode, TransportationMode.flight);
    expect(record.heading, 'Flight');
    expect(record.issue, isNull);
    final editor = TransportationEditorController(
      tripId: 'trip',
      userId: 'owner',
      existing: record,
    );
    addTearDown(editor.onClose);
    final saved = editor.buildEntry();
    expect(saved.departure, record.departure);
    expect(saved.arrival, record.arrival);
    expect(saved.notes, record.notes);
    expect(saved.displayName, 'Randy');
    expect(saved.issue, isNull);
  });
  test('notes hold transportation details across mode changes and reloads', () {
    final editor = TransportationEditorController(
      tripId: 'trip',
      userId: 'owner',
      displayName: 'Randy',
    );
    addTearDown(editor.onClose);
    editor.notes.text = 'Airport to hotel. Uber with Randy.';
    editor.mode.value = TransportationMode.rideshare;
    final saved = editor.buildEntry();
    expect(saved.notes, editor.notes.text);
    expect(saved.displayName, 'Randy');
    expect(saved.title, isEmpty);
    expect(saved.origin, isEmpty);
    expect(saved.destination, isEmpty);
    expect(saved.provider, isEmpty);
    expect(saved.driver, isEmpty);
    expect(saved.serviceNumber, isEmpty);
    expect(saved.travelerNames, isEmpty);
    final reopened = TransportationEditorController(
      tripId: 'trip',
      userId: 'owner',
      existing: TransportationModel.fromMap(
        saved.id,
        saved.tripId,
        saved.toMap(),
      ),
    );
    addTearDown(reopened.onClose);
    reopened.mode.value = TransportationMode.taxi;
    expect(reopened.buildEntry().displayName, 'Randy');
    expect(reopened.buildEntry().notes, saved.notes);
  });
  test(
    'hidden flight records cannot reappear through the old trip summary',
    () {
      final fields = {
        'userId': 'owner',
        'createdBy': 'owner',
        'flightNumber': 'TC123',
      };
      final summary = TransportationModel.fromMap(
        'trip',
        'trip',
        fields,
        source: TransportationSource.trip,
      );
      final hidden = TransportationModel.fromMap(
        'flight',
        'trip',
        fields,
        source: TransportationSource.flight,
      );
      expect(
        TransportationModel.combine(
          summary,
          [],
          [],
          [],
          hiddenFlights: [hidden],
        ),
        isEmpty,
      );
    },
  );
  test(
    'all modes allow a simple unscheduled entry and preserve mode on reload',
    () {
      for (final mode in TransportationMode.values) {
        final item = entry(mode.name, mode: mode.name);
        expect(item.issue, isNull);
        expect(
          TransportationModel.fromMap(item.id, item.tripId, item.toMap()).mode,
          mode,
        );
      }
    },
  );
  test(
    'legacy flights merge with new modes without hiding distinct old flights',
    () {
      final fields = {
        'userId': 'owner',
        'flightNumber': 'AB123',
        'departureDate': '2027-04-10',
      };
      final nested = TransportationModel.fromMap(
        'one',
        'trip',
        fields,
        source: TransportationSource.flight,
      );
      final legacy = TransportationModel.fromMap(
        'one',
        'trip',
        fields,
        source: TransportationSource.legacyFlight,
      );
      final otherLegacy = TransportationModel.fromMap('two', 'trip', {
        ...fields,
        'flightNumber': 'AB124',
      }, source: TransportationSource.legacyFlight);
      final summary = TransportationModel.fromMap('summary', 'trip', {
        ...fields,
        'createdBy': 'owner',
      }, source: TransportationSource.trip);
      final result = TransportationModel.combine(
        summary,
        [nested],
        [legacy, otherLegacy],
        [entry('car')],
      );
      expect(result.length, 3);
      expect(result.first.source, TransportationSource.flight);
      expect(result.map((item) => item.id), containsAll(['one', 'two', 'car']));
    },
  );
  test(
    'venue offsets retain cross-zone chronology and reject invalid schedules',
    () {
      final flight = entry(
        'flight',
        mode: 'flight',
        departure: '2027-04-10T10:00:00+09:00',
        arrival: '2027-04-10T04:00:00-07:00',
      );
      expect(flight.issue, isNull);
      expect(
        flight.toFlightMap()['departureDate'],
        '2027-04-10T10:00:00+09:00',
      );
      expect(
        TransportationModel.formatDate(flight.arrival),
        equals('Apr 10, 2027 · 4:00 AM'),
      );
      for (final invalid in [
        '2027-02-30',
        '2027-04-10T25:00:00+09:00',
        '2027-04-10T10:00:00+25:00',
      ]) {
        expect(
          entry('bad', departure: invalid).issue,
          isNotNull,
          reason: invalid,
        );
      }
      expect(
        entry('bad', departure: '2027-04-12', arrival: '2027-04-11').issue,
        isNotNull,
      );
      expect(
        entry('day', departure: '2027-04-10').toMap()['departure'],
        '2027-04-10',
      );
    },
  );
  test(
    'local times save exactly as entered and survive editing without a timezone',
    () {
      final editor = TransportationEditorController(
        tripId: 'trip',
        userId: 'owner',
      );
      addTearDown(editor.onClose);
      editor.departure.date.text = '2027-03-14';
      editor.departure.time.text = '02:30';
      editor.arrival.date.text = '2027-03-14';
      editor.arrival.time.text = '01:30';
      final saved = editor.buildEntry();
      expect(saved.departure, '2027-03-14T02:30:00');
      expect(saved.arrival, '2027-03-14T01:30:00');
      expect(
        TransportationModel.formatDate(saved.departure),
        'Mar 14, 2027 · 2:30 AM',
      );
      final reopened = TransportationEditorController(
        existing: saved,
        tripId: 'trip',
        userId: 'owner',
      );
      addTearDown(reopened.onClose);
      reopened.notes.text = 'Airport transfer';
      expect(reopened.buildEntry().departure, saved.departure);
      expect(reopened.buildEntry().arrival, saved.arrival);
      reopened.departure.time.clear();
      expect(reopened.buildEntry().departure, '2027-03-14');
    },
  );
  testWidgets('all mode cards fit narrow screens with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final mode in TransportationMode.values) {
      final item = TransportationModel(
        id: 'entry',
        tripId: 'trip',
        userId: 'owner',
        mode: mode,
        displayName: 'Randy and a long display name',
        title: 'A long transportation title for the trip',
        origin: 'Tokyo Narita International Airport',
        destination: 'Los Angeles International Airport',
        departure: '2027-04-10T10:00:00+09:00',
        arrival: '2027-04-10T04:00:00-07:00',
        travelerNames: ['Randy', 'Travel companion'],
        notes: 'Bring tickets.',
      );
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
            child: Scaffold(
              body: SingleChildScrollView(
                child: TransportationCard(entry: item, canManage: true),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: mode.name);
      expect(find.text(mode.label), findsOneWidget);
      expect(
        find.textContaining('Randy and a long display name'),
        findsOneWidget,
      );
    }
  });
  testWidgets(
    'local-time fields never prompt for offsets; save failures retain input',
    (tester) async {
      final controller = TransportationEditorController(
        tripId: 'trip',
        userId: 'owner',
        existing: entry(
          'scheduled',
          departure: '2027-04-10T10:00:00',
          arrival: '2027-04-10T04:00:00',
        ),
      );
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TransportationEditor(
              controller: controller,
              onSave: (entry) async {
                calls++;
                expect(entry.notes, 'Uber from airport to hotel');
                expect(entry.departure, '2027-04-10T10:00:00');
                expect(entry.arrival, '2027-04-10T04:00:00');
                throw StateError('offline');
              },
            ),
          ),
        ),
      );
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.textContaining('UTC'), findsNothing);
      expect(find.text('Notes (optional)'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Notes (optional)'),
        'Uber from airport to hotel',
      );
      await tester.ensureVisible(find.text('Save Transportation'));
      await tester.tap(find.text('Save Transportation'));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(
        find.textContaining('Could not save transportation'),
        findsOneWidget,
      );
      expect(find.text('Save Transportation'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
