import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/trip_model.dart';

void main() {
  test(
    'malformed embedded expenses keep the review flag without breaking a trip',
    () {
      final trip = TripModel.fromMap({
        'id': 'trip',
        'createdBy': 'owner',
        'destination': 'Tokyo',
        'country': 'Japan',
        'startDate': '2027-04-10T00:00:00',
        'expenses': [
          {'name': 'Bad amount', 'amount': 'unknown'},
          {'name': 'Bad date', 'amount': 2, 'date': 'not-a-date'},
          'not-an-expense',
        ],
        'financeMigrationStatus': 'reviewing',
      });
      expect(trip.hasLegacyExpenseRecords, isTrue);
      expect(trip.expenses, isEmpty);
      expect(trip.financeMigrationStatus, 'reviewing');
      expect(
        trip.copyWith(title: 'Edited').financeMigrationStatus,
        'reviewing',
      );
      expect(trip.toMap().containsKey('financeMigrationStatus'), isFalse);
    },
  );
}
