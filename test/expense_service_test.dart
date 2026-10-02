import 'package:flutter_test/flutter_test.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/expense_service.dart';
import 'package:travel_crew/services/session_services.dart';

void main() {
  group('ExpenseService', () {
    setUp(() {
      GlobalVariables.loggedInUser.value = null;
    });

    test('includes the trip creator when computing settlements', () {
      final trip = _trip(
        createdBy: 'owner',
        joinedUsers: ['member'],
        expenses: [
          ExpenseModel(
            createdBy: 'owner',
            tripId: 'trip-1',
            name: 'Dinner',
            paidByUsers: [],
            amount: 100,
            date: DateTime.utc(2026),
          ),
        ],
      );

      final settlements = ExpenseService().computeOptimalSettlements(trip);

      expect(settlements, hasLength(1));
      expect(settlements.single.fromUserId, 'member');
      expect(settlements.single.toUserId, 'owner');
      expect(settlements.single.amount, 50);
    });

    test(
      'does not duplicate paid users during equal split settlement math',
      () {
        final trip = _trip(
          createdBy: 'owner',
          joinedUsers: ['member'],
          expenses: [
            ExpenseModel(
              createdBy: 'owner',
              tripId: 'trip-1',
              name: 'Taxi',
              paidByUsers: ['member'],
              amount: 40,
              date: DateTime.utc(2026),
            ),
          ],
        );

        expect(ExpenseService().computeOptimalSettlements(trip), isEmpty);
      },
    );

    test('getTripExpenseSummary tracks total expenses', () {
      final trip = _trip(
        createdBy: 'owner',
        joinedUsers: [],
        expenses: [
          ExpenseModel(
            createdBy: 'owner',
            tripId: 'trip-1',
            name: 'Coffee',
            paidByUsers: [],
            amount: 50,
            date: DateTime.utc(2026),
          ),
        ],
      );
      final summary = ExpenseService().getTripExpenseSummary(trip);
      expect(summary['totalExpenses'], equals(50.0));
      expect(summary['expenseCount'], equals(1));
    });
  });
}

TripModel _trip({
  required String createdBy,
  required List<String> joinedUsers,
  required List<ExpenseModel> expenses,
}) {
  return TripModel(
    id: 'trip-1',
    destination: 'Tokyo',
    createdBy: createdBy,
    country: 'Japan',
    startDate: DateTime.utc(2026),
    endDate: '',
    daysToGo: 0,
    images: const [],
    joinedUsers: joinedUsers,
    expenses: expenses,
  );
}
