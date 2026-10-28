import 'package:travel_crew/utils/travel_time.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/models/lodging_model.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';

const departure = '2027-04-10T10:00:00+09:00';
const arrival = '2027-04-10T04:00:00-07:00';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('editing a venue clock is independent of the phone DST gap', () {
    final wall = TravelTime.withClock(DateTime(2027, 3, 14), 2, 30, '+09:00');
    expect(wall.hour, 2);
    expect(
      TravelTime.serialize(wall, '+09:00'),
      '2027-03-14T02:30:00.000+09:00',
    );
  });
  test('flight transportation keeps each location clock without an offset', () {
    final flight = TransportationModel.fromImport(
      {
        'mode': 'flight',
        'departure': '2027-04-10T10:00:00',
        'arrival': '2027-04-10T04:00:00',
      },
      id: 'flight-1',
      tripId: 'trip-1',
      userId: 'user-1',
    );
    expect(flight.departure, '2027-04-10T10:00:00');
    expect(flight.arrival, '2027-04-10T04:00:00');
    expect(flight.toMap()['departure'], '2027-04-10T10:00:00');
    expect(flight.toMap()['arrival'], '2027-04-10T04:00:00');
  });

  test('trip and lodging edit round trips preserve property offsets', () {
    final trip = TripModel.fromMap({
      'checkInDate': '2027-04-10T15:00:00+09:00',
      'checkOutDate': '2027-04-12T11:00:00+09:00',
    });
    final lodging = LodgingModel.fromTrip(trip.copyWith(title: 'Updated'));
    expect(lodging.checkInDate!.hour, 15);
    expect(lodging.toMap()['checkInDate'], '2027-04-10T15:00:00.000+09:00');
    expect(
      LodgingModel.fromMap('hotel', lodging.toMap()).checkOutDate!.hour,
      11,
    );
    final editor = CreateTripController();
    addTearDown(editor.onClose);
    editor.tripModel.value = TripModel.fromMap({
      ...trip.toMap(),
      'startDate': '2027-04-10',
      'tripStartDate': '2027-04-10',
      'tripEndDate': '2027-04-12',
    });
    editor.setAllValuesToEdit();
    final patch = editor.buildTripUpdate([]);
    expect(patch.containsKey('checkInDate'), isFalse);
  });

  test(
    'manual imports preserve venue clocks and expense local clocks',
    () async {
      final editor = CreateTripController();
      addTearDown(editor.onClose);
      editor.setFromImport({
        'start_date': '2027-04-10',
        'end_date': '2027-04-12',
        'transportation': [
          {
            'mode': 'flight',
            'departure': '2027-04-10T10:00:00',
            'arrival': '2027-04-10T04:00:00',
          },
        ],
        'lodging': {'check_in': '2027-04-10T15:00:00+09:00'},
        'activities': [
          {'title': 'Museum', 'start_datetime': departure},
        ],
        'expenses': [
          {'name': 'Ticket', 'amount': 10, 'date': departure},
        ],
        'expense_currency': 'USD',
      });
      expect(
        editor.importedTransportation.single.departure,
        '2027-04-10T10:00:00',
      );
      expect(
        editor.importedTransportation.single.arrival,
        '2027-04-10T04:00:00',
      );
      expect(editor.checkInStartTime.value!.hour, 15);
      expect(
        editor.activityList.single.toMap()['startDateTime'],
        '2027-04-10T10:00:00.000+09:00',
      );
      final drafts = await editor.buildImportedFinanceExpenses(
        currencyOptions: {'USD': 2},
      );
      expect(drafts.single.date, '2027-04-10');
      expect(drafts.single.localDateTime, '2027-04-10T10:00:00');
      expect(drafts.single.currencyCode, 'USD');
      expect(editor.startDate.value, DateTime(2027, 4, 10));
    },
  );

  test('date-only travel and expenses never shift days', () {
    const date = '2027-04-10T00:00:00.000';
    final trip = TripModel.fromMap({
      'startDate': date,
      'tripStartDate': date,
      'tripEndDate': date,
      'checkInDate': date,
    });
    expect(trip.toMap()['tripStartDate'], date);
    expect(LodgingModel.fromTrip(trip).toMap()['checkInDate'], date);
    final expense = ExpenseModel.fromMap({'date': '2027-04-10'});
    expect(expense.date, DateTime(2027, 4, 10));
    expect(expense.toMap()['date'], date);
    final timedExpense = ExpenseModel.fromMap({
      'date': departure,
    }).copyWith(name: 'Updated');
    expect(timedExpense.date, DateTime.parse(departure).toLocal());
    expect(
      DateTime.parse(timedExpense.toMap()['date'] as String),
      DateTime.parse(departure),
    );
  });
}
