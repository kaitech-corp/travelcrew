import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/imported_finance_expense.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';

void main() {
  test('keeps exact amount, local clock and stable retry identity', () {
    final draft = ImportedFinanceExpense.fromMap(
      {
        'name': 'Train',
        'amount': 10.01,
        'date': '2027-04-10T10:00:00+09:00',
        'split_type': 'equally',
      },
      currencyCode: 'USD',
      precision: 2,
      requestId: 'stable_request_123',
    );
    expect(draft.date, '2027-04-10');
    expect(draft.localDateTime, '2027-04-10T10:00:00');
    expect(draft.requestFor('trip', 'owner'), {
      'tripId': 'trip',
      'requestId': 'stable_request_123',
      'name': 'Train',
      'date': '2027-04-10',
      'localDateTime': '2027-04-10T10:00:00',
      'amount': '10.01',
      'currencyCode': 'USD',
      'splitType': 'equally',
      'participants': ['owner'],
    });
  });

  test('rejects invalid precision, dates, split and invented UTC clock', () {
    final valid = {'name': 'Train', 'amount': 10.01, 'date': '2027-04-10'};
    for (final candidate in [
      {...valid, 'amount': 10.001},
      {...valid, 'date': '2027-02-30'},
      {...valid, 'date': '2027-04-10T10:00:00Z'},
      {...valid, 'split_type': 'custom'},
      {...valid, 'createdBy': 'attacker'},
    ]) {
      expect(
        () => ImportedFinanceExpense.fromMap(
          candidate,
          currencyCode: 'USD',
          precision: 2,
        ),
        throwsFormatException,
        reason: candidate.toString(),
      );
    }
  });

  test(
    'partial import save retries only pending expense with its original ID',
    () async {
      final controller = CreateTripController();
      addTearDown(controller.onClose);
      final drafts = [
        ImportedFinanceExpense.fromMap(
          {'name': 'Train', 'amount': 10, 'date': '2027-04-10'},
          currencyCode: 'USD',
          precision: 2,
          requestId: 'request_train_123',
        ),
        ImportedFinanceExpense.fromMap(
          {'name': 'Hotel', 'amount': 20, 'date': '2027-04-11'},
          currencyCode: 'USD',
          precision: 2,
          requestId: 'request_hotel_123',
        ),
      ];
      final calls = <Map<String, dynamic>>[];
      var failHotel = true;
      Future<Map<String, dynamic>> save(Map<String, dynamic> request) async {
        calls.add(Map<String, dynamic>.from(request));
        if (request['name'] == 'Hotel' && failHotel) {
          failHotel = false;
          throw StateError('temporary service failure');
        }
        return {'expenseId': request['requestId']};
      }

      await expectLater(
        controller.saveImportedFinanceExpenses(
          drafts,
          tripId: 'trip',
          ownerId: 'owner',
          save: save,
        ),
        throwsStateError,
      );
      await controller.saveImportedFinanceExpenses(
        drafts,
        tripId: 'trip',
        ownerId: 'owner',
        save: save,
      );
      expect(calls.map((call) => call['name']).toList(), [
        'Train',
        'Hotel',
        'Hotel',
      ]);
      expect(calls[1]['requestId'], calls[2]['requestId']);
    },
  );

  test(
    'controller validates currency and keeps generated IDs on retry',
    () async {
      final controller = CreateTripController();
      addTearDown(controller.onClose);
      controller.setFromImport({
        'expense_currency': 'USD',
        'expenses': [
          {'name': 'Train', 'amount': 10.01, 'date': '2027-04-10'},
        ],
      });
      final first = await controller.buildImportedFinanceExpenses(
        currencyOptions: {'USD': 2},
      );
      final retry = await controller.buildImportedFinanceExpenses(
        currencyOptions: {'USD': 2},
      );
      expect(first.single.requestId, retry.single.requestId);
      await expectLater(
        controller.buildImportedFinanceExpenses(currencyOptions: {'JPY': 0}),
        throwsFormatException,
      );
    },
  );

  test('ambiguous trip create response rechecks the original ID', () async {
    final controller = CreateTripController();
    addTearDown(controller.onClose);
    final draft = TripModel.fromMap({
      'id': 'stable_trip',
      'createdBy': 'owner',
    });
    final writes = <String>[];
    var reads = 0;
    Future<bool> exists(String tripId, String ownerId) async {
      expect(tripId, 'stable_trip');
      expect(ownerId, 'owner');
      reads++;
      return reads == 3;
    }

    Future<bool> create(TripModel trip) async {
      writes.add(trip.id);
      return false; // The client lost the response after a possible commit.
    }

    await expectLater(
      controller.ensureCreatedTrip(draft, exists: exists, create: create),
      throwsFormatException,
    );
    await controller.ensureCreatedTrip(draft, exists: exists, create: create);
    expect(writes, ['stable_trip']);
    expect(controller.hasPendingCreatedTrip.value, isTrue);
  });

  test('healthy first trip write does not need the status endpoint', () async {
    final controller = CreateTripController();
    addTearDown(controller.onClose);
    final draft = TripModel.fromMap({
      'id': 'stable_trip',
      'createdBy': 'owner',
    });
    var checked = false;
    await controller.ensureCreatedTrip(
      draft,
      checkBeforeCreate: false,
      exists: (_, _) async {
        checked = true;
        return false;
      },
      create: (_) async => true,
    );
    expect(checked, isFalse);
    expect(controller.hasPendingCreatedTrip.value, isTrue);
  });
}
