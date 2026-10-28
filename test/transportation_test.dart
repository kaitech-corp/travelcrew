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
  int revision = 1,
}) => TransportationModel.fromMap(id, 'trip', {
  'userId': 'owner',
  'displayName': 'Owner',
  'mode': mode,
  'departure': departure,
  'arrival': arrival,
  'notes': '',
  'revision': revision,
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('saving and closing the modal keeps controllers alive', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: preview.Preview()));
    await tester.tap(find.text('Add Transportation'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notes (optional)'),
      'Hotel shuttle',
    );
    await tester.ensureVisible(find.text('Save Transportation'));
    await tester.tap(find.text('Save Transportation'));
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
  });

  test('manual imports keep notes and each location’s clock', () {
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
          'notes': 'Example Air TC123, Randy and Alex',
          'departure': '2027-04-10T10:00:00',
          'arrival': '2027-04-11T14:00:00',
        },
        {'mode': 'scooter', 'notes': 'Rental'},
        {'mode': 'train', 'departure': '2027-04-12'},
      ],
    });
    final imported = controller.importedTransportation;
    expect(imported.length, 3);
    expect(imported.first.notes, contains('TC123'));
    expect(imported.first.departure, '2027-04-10T10:00:00');
    expect(imported.first.arrival, '2027-04-11T14:00:00');
    expect(imported[1].mode, TransportationMode.scooter);
    expect(imported[2].departure, '2027-04-12');
  });

  test('MCP flight reopens with minimal fields, local clocks and saver', () {
    final record = TransportationModel.fromMap('transport_0', 'trip', {
      'id': 'transport_0',
      'tripId': 'trip',
      'userId': 'owner',
      'displayName': 'Randy',
      'mode': 'flight',
      'revision': 1,
      'departure': '2027-03-14T02:30:00',
      'arrival': '2027-03-14T01:30:00',
      'notes': 'Example Air TC123, Tokyo to Los Angeles',
    });
    expect(record.mode, TransportationMode.flight);
    expect(record.issue, isNull);
    final editor = TransportationEditorController(
      tripId: 'trip',
      userId: 'owner',
      existing: record,
    );
    addTearDown(editor.onClose);
    final saved = editor.buildEntry();
    expect(saved.toMap().keys, {
      'id',
      'tripId',
      'userId',
      'displayName',
      'mode',
      'departure',
      'arrival',
      'notes',
      'revision',
      'isDeleted',
    });
    expect(saved.departure, record.departure);
    expect(saved.arrival, record.arrival);
    expect(saved.notes, record.notes);
    expect(saved.displayName, 'Randy');
    expect(saved.revision, 1);
  });

  test('all modes reload and sort without converting local clocks', () {
    for (final mode in TransportationMode.values) {
      final item = entry(mode.name, mode: mode.name);
      expect(item.issue, isNull);
      expect(
        TransportationModel.fromMap(item.id, item.tripId, item.toMap()).mode,
        mode,
      );
    }
    final local = entry('local', departure: '2027-04-10T10:00:00');
    final later = entry('later', departure: '2027-04-11T10:00:00');
    expect(TransportationModel.sort([later, local]).map((item) => item.id), [
      'local',
      'later',
    ]);
    expect(
      TransportationModel.formatDate(local.departure),
      'Apr 10, 2027 · 10:00 AM',
    );
  });

  test('location clocks display directly and offsets are rejected', () {
    final flight = entry(
      'flight',
      mode: 'flight',
      departure: '2027-04-10T10:00:00',
      arrival: '2027-04-10T04:00:00',
    );
    expect(flight.issue, isNull);
    expect(flight.toMap()['departure'], '2027-04-10T10:00:00');
    expect(
      TransportationModel.formatDate(flight.arrival),
      'Apr 10, 2027 · 4:00 AM',
    );
    for (final invalid in [
      '2027-02-30',
      '2027-04-10T10:00:00Z',
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
  });

  test(
    'editing preserves local clocks and revision without a timezone prompt',
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
      final reopened = TransportationEditorController(
        existing: saved,
        tripId: 'trip',
        userId: 'owner',
      );
      addTearDown(reopened.onClose);
      reopened.notes.text = 'Airport transfer';
      expect(reopened.buildEntry().departure, saved.departure);
      expect(reopened.buildEntry().revision, saved.revision);
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
        departure: '2027-04-10T10:00:00',
        arrival: '2027-04-10T04:00:00',
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
    'local time fields avoid offsets and a failed save retains input',
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
      expect(find.text('Uber from airport to hotel'), findsOneWidget);
    },
  );
}
