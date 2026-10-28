import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/activity_model.dart';
import 'package:travel_crew/models/transportation_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/pending_trip_import_store.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/views/create_trip/controller/create_trip_controller.dart';

void main() {
  final memory = <String, String>{};
  PendingTripImportStore store() => PendingTripImportStore(
    read: (key) async => memory[key],
    write: (key, value) async => memory[key] = value,
    delete: (key) async => memory.remove(key),
  );
  PendingTripImport pending({
    String tripId = 'trip-1',
    Set<String> saved = const {},
  }) => PendingTripImport(
    trip: TripModel.fromMap({
      'id': tripId,
      'createdBy': 'owner-1',
      'destination': 'Tokyo',
      'startDate': '2027-04-10',
      'tripEndDate': '2027-04-12',
    }),
    transportation: [
      TransportationModel.fromImport(
        {'mode': 'train', 'departure': '2027-04-10T10:00:00'},
        id: 'train-1',
        tripId: '',
        userId: 'owner-1',
      ),
    ],
    activities: [
      ActivityModel(
        likesCount: 0,
        title: 'Museum',
        tripId: '',
        description: '',
      ),
    ],
    expenses: [
      {'name': 'Ticket', 'amount': 10.01, 'date': '2027-04-10'},
      {'name': 'Dinner', 'amount': 20, 'date': '2027-04-11'},
    ],
    expenseRequestIds: ['request-1', 'request-2'],
    savedExpenseRequestIds: saved,
    expenseCurrency: 'USD',
  );

  setUp(memory.clear);
  tearDown(() => GlobalVariables.loggedInUser.value = null);

  test(
    'restores exact trip, travel drafts and partially saved request IDs',
    () async {
      final cache = store();
      await cache.save(pending(saved: {'request-1'}));
      final recovered = await cache.load('owner-1');
      expect(recovered!.trip.id, 'trip-1');
      expect(recovered.transportation.single.departure, '2027-04-10T10:00:00');
      expect(recovered.activities.single.title, 'Museum');
      expect(recovered.expenses[0]['amount'], 10.01);
      expect(recovered.expenseRequestIds, ['request-1', 'request-2']);
      expect(recovered.savedExpenseRequestIds, {'request-1'});
      expect(await cache.load('other-owner'), isNull);
      await cache.delete('owner-1');
      expect(await cache.load('owner-1'), isNull);
    },
  );

  test('does not overwrite a different unfinished trip', () async {
    final cache = store();
    await cache.save(pending());
    await expectLater(
      cache.save(pending(tripId: 'trip-2')),
      throwsFormatException,
    );
    expect((await cache.load('owner-1'))!.trip.id, 'trip-1');
  });

  test('rejects wrong owner and invalid checkpoint before reuse', () async {
    final source = pending().encode();
    expect(
      () => PendingTripImport.decode(source, 'owner-2'),
      throwsFormatException,
    );
    memory['pendingTripImport.v1.owner-1'] = '{"version":99}';
    await expectLater(store().load('owner-1'), throwsFormatException);
  });

  test(
    'storage write errors propagate and leave earlier checkpoint intact',
    () async {
      final cache = store();
      await cache.save(pending());
      final failing = PendingTripImportStore(
        read: (key) async => memory[key],
        write: (_, _) async => throw StateError('keychain unavailable'),
        delete: (key) async => memory.remove(key),
      );
      await expectLater(
        failing.save(pending(saved: {'request-1'})),
        throwsStateError,
      );
      expect((await cache.load('owner-1'))!.savedExpenseRequestIds, isEmpty);
    },
  );

  test(
    'new controller resumes saved IDs and skips committed expenses',
    () async {
      GlobalVariables.loggedInUser.value = UserModel(
        uid: 'owner-1',
        email: 'owner@example.com',
      );
      final cache = store();
      await cache.save(pending(saved: {'request-1'}));
      final controller = CreateTripController()..pendingImportStore = cache;
      addTearDown(controller.onClose);
      expect(await controller.restorePendingTrip(), isTrue);
      expect(controller.hasPendingCreatedTrip.value, isTrue);
      controller.prepareImportedActivityIds('trip-1');
      final activityId = controller.activityList.single.id;
      expect(activityId, isNotEmpty);
      final attemptedActivities = <String>[];
      await expectLater(
        controller.saveImportedActivities(
          save: (activity) async {
            attemptedActivities.add(activity.id!);
            return false;
          },
        ),
        throwsStateError,
      );
      await cache.save(
        PendingTripImport(
          trip: (await cache.load('owner-1'))!.trip,
          transportation: controller.importedTransportation.toList(),
          activities: controller.activityList.toList(),
          expenses: controller.importedExpenseData.toList(),
          expenseRequestIds: ['request-1', 'request-2'],
          savedExpenseRequestIds: {'request-1'},
          expenseCurrency: 'USD',
        ),
      );
      final relaunched = CreateTripController()..pendingImportStore = cache;
      addTearDown(relaunched.onClose);
      expect(await relaunched.restorePendingTrip(), isTrue);
      relaunched.prepareImportedActivityIds('trip-1');
      expect(relaunched.activityList.single.id, activityId);
      await relaunched.saveImportedActivities(
        save: (activity) async {
          attemptedActivities.add(activity.id!);
          return true;
        },
      );
      expect(attemptedActivities, [activityId, activityId]);
      final drafts = await controller.buildImportedFinanceExpenses(
        currencyOptions: {'USD': 2},
      );
      final saved = <String>[];
      await controller.saveImportedFinanceExpenses(
        drafts,
        tripId: 'trip-1',
        ownerId: 'owner-1',
        save: (request) async {
          saved.add(request['requestId'] as String);
          return {'expenseId': request['requestId']};
        },
      );
      expect(saved, ['request-2']);
      expect((await cache.load('owner-1'))!.savedExpenseRequestIds, {
        'request-1',
        'request-2',
      });
    },
  );
}
