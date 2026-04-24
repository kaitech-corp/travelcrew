import 'dart:math';

import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/session_services.dart';

class Settlement {
  Settlement({
    required this.fromUserId,
    required this.toUserId,
    required this.amount,
  });

  final String fromUserId;
  final String toUserId;
  final double amount;
}

class ExpenseService {
  /// Calculates debts between users for a specific trip
  /// Returns a map where positive values indicate money owed TO the current user
  /// and negative values indicate money the current user owes TO others
  Map<String, double> calculateUserDebts(TripModel trip) {
    final Map<String, double> userDebts = {};
    final currentUserId = GlobalVariables.loggedInUser.value?.uid ?? '';
    final joinedUsers = trip.joinedUsers ?? [];

    if (joinedUsers.isEmpty || (trip.expenses?.isEmpty ?? true)) {
      return userDebts;
    }

    // Initialize all users with 0 debt
    for (final userId in joinedUsers) {
      userDebts[userId] = 0.0;
    }

    // Calculate debts for each expense
    for (final expense in trip.expenses ?? []) {
      _processExpenseDebts(expense, userDebts, joinedUsers, currentUserId);
    }

    // Remove users with no debt and current user
    userDebts.removeWhere((userId, debt) => userId == currentUserId || debt.abs() < 0.01);

    return userDebts;
  }

  /// Processes debt calculations for a single expense
  void _processExpenseDebts(
    ExpenseModel expense,
    Map<String, double> userDebts,
    List<String> joinedUsers,
    String currentUserId,
  ) {
    if (expense.splitType == 'equally') {
      _processEqualSplit(expense, userDebts, joinedUsers, currentUserId);
    } else {
      _processCustomSplit(expense, userDebts, currentUserId);
    }

    // Handle multiple payers (when expense is split among multiple people who paid)
    _processMultiplePayers(expense, userDebts, currentUserId);
  }

  /// Handles equally split expenses
  void _processEqualSplit(
    ExpenseModel expense,
    Map<String, double> userDebts,
    List<String> joinedUsers,
    String currentUserId,
  ) {
    final totalParticipants = joinedUsers.length;
    final sharePerPerson = expense.amount / totalParticipants;
    final paidBy = expense.createdBy;

    // Each user owes their share to the person who paid
    for (final userId in joinedUsers) {
      if (userId != paidBy) {
        // If the current user paid, others owe them
        if (paidBy == currentUserId) {
          userDebts[userId] = (userDebts[userId] ?? 0) + sharePerPerson;
        }
        // If someone else paid and current user didn't pay, current user owes them
        else if (userId == currentUserId) {
          userDebts[paidBy] = (userDebts[paidBy] ?? 0) - sharePerPerson;
        }
      }
    }
  }

  /// Handles custom split expenses using owedTo map
  void _processCustomSplit(
    ExpenseModel expense,
    Map<String, double> userDebts,
    String currentUserId,
  ) {
    final paidBy = expense.createdBy;
    
    if (expense.owedTo.isNotEmpty) {
      expense.owedTo.forEach((userId, amount) {
        if (userId != paidBy) {
          if (paidBy == currentUserId) {
            // Current user paid, others owe them
            userDebts[userId] = (userDebts[userId] ?? 0) + amount;
          } else if (userId == currentUserId) {
            // Current user owes the person who paid
            userDebts[paidBy] = (userDebts[paidBy] ?? 0) - amount;
          }
        }
      });
    }
  }

  /// Handles expenses where multiple users contributed to payment
  void _processMultiplePayers(
    ExpenseModel expense,
    Map<String, double> userDebts,
    String currentUserId,
  ) {
    // If there are multiple payers, adjust debts accordingly
    if (expense.paidByUsers.length > 1) {
      final totalPayers = expense.paidByUsers.length;
      final amountPerPayer = expense.amount / totalPayers;

      for (final payerId in expense.paidByUsers) {
        if (payerId != expense.createdBy) {
          // This payer contributed to the expense
          if (payerId == currentUserId) {
            // Current user was one of the payers, reduce what they owe to creator
            userDebts[expense.createdBy] = (userDebts[expense.createdBy] ?? 0) + amountPerPayer;
          } else if (expense.createdBy == currentUserId) {
            // Current user is creator, reduce what this payer owes them
            userDebts[payerId] = (userDebts[payerId] ?? 0) - amountPerPayer;
          }
        }
      }
    }
  }

  /// Calculates the total amount spent by the current user
  double calculateUserTotalSpent(TripModel trip) {
    final currentUserId = GlobalVariables.loggedInUser.value?.uid ?? '';
    if (trip.expenses?.isEmpty ?? true) {
      return 0.0;
    }

    double totalSpent = 0.0;
    for (final expense in trip.expenses ?? []) {
      if (expense.createdBy == currentUserId) {
        totalSpent += expense.amount;
      }
      // Add any additional payments made by current user
      if (expense.paidByUsers.contains(currentUserId) && expense.createdBy != currentUserId) {
        // Calculate the portion paid by current user
        final payerCount = expense.paidByUsers.length;
        if (payerCount > 0) {
          totalSpent += expense.amount / payerCount;
        }
      }
    }
    return totalSpent;
  }

  /// Calculates the current user's share of total trip expenses
  double calculateUserShare(TripModel trip) {
    final joinedUsers = trip.joinedUsers ?? [];
    if (joinedUsers.isEmpty || (trip.expenses?.isEmpty ?? true)) {
      return 0.0;
    }

    double totalShare = 0.0;
    for (final expense in trip.expenses ?? []) {
      if (expense.splitType == 'equally') {
        totalShare += expense.amount / joinedUsers.length;
      } else if (expense.owedTo.isNotEmpty) {
        final currentUserId = GlobalVariables.loggedInUser.value?.uid ?? '';
        totalShare += expense.owedTo[currentUserId] ?? 0.0;
      }
    }
    return totalShare;
  }

  /// Calculates total trip expenses
  double calculateTotalTripExpenses(TripModel trip) {
    if (trip.expenses?.isEmpty ?? true) {
      return 0.0;
    }

    return (trip.expenses ?? []).fold(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Gets expenses created by a specific user
  List<ExpenseModel> getExpensesByUser(TripModel trip, String userId) {
    if (trip.expenses?.isEmpty ?? true) {
      return [];
    }

    return (trip.expenses ?? []).where((expense) => expense.createdBy == userId).toList();
  }

  /// Gets expenses where a specific user owes money
  List<ExpenseModel> getExpensesOwedByUser(TripModel trip, String userId) {
    if (trip.expenses?.isEmpty ?? true) {
      return [];
    }

    return (trip.expenses ?? []).where((expense) {
      if (expense.splitType == 'equally') {
        return expense.createdBy != userId;
      } else {
        return expense.owedTo.containsKey(userId) && expense.createdBy != userId;
      }
    }).toList();
  }

  /// Calculates net balance for current user (positive = owed money, negative = owes money)
  double calculateNetBalance(TripModel trip) {
    final userDebts = calculateUserDebts(trip);
    return userDebts.values.fold(0.0, (sum, debt) => sum + debt);
  }

  /// Groups expenses by category or type
  Map<String, List<ExpenseModel>> groupExpensesByCategory(TripModel trip) {
    if (trip.expenses?.isEmpty ?? true) {
      return {};
    }

    final Map<String, List<ExpenseModel>> groupedExpenses = {};
    
    for (final expense in trip.expenses ?? []) {
      // You can customize this logic based on expense categories
      // For now, grouping by expense name prefix or using a default category
      String category = _extractCategory(expense.name);
      
      if (!groupedExpenses.containsKey(category)) {
        groupedExpenses[category] = [];
      }
      groupedExpenses[category]!.add(expense);
    }

    return groupedExpenses;
  }

  /// Extracts category from expense name (can be customized)
  String _extractCategory(String expenseName) {
    final name = expenseName.toLowerCase();
    
    if (name.contains('food') || name.contains('restaurant') || name.contains('meal')) {
      return 'Food & Dining';
    } else if (name.contains('transport') || name.contains('taxi') || name.contains('uber') || name.contains('flight')) {
      return 'Transportation';
    } else if (name.contains('hotel') || name.contains('accommodation') || name.contains('lodging')) {
      return 'Accommodation';
    } else if (name.contains('activity') || name.contains('tour') || name.contains('ticket')) {
      return 'Activities';
    } else if (name.contains('shopping') || name.contains('souvenir')) {
      return 'Shopping';
    } else {
      return 'Other';
    }
  }

  /// Validates if an expense can be added (e.g., budget constraints)
  bool canAddExpense(TripModel trip, double expenseAmount) {
    final currentTotal = calculateTotalTripExpenses(trip);
    return (currentTotal + expenseAmount) <= trip.tripBudget;
  }

  /// Computes the minimum set of transfers to clear all outstanding debts for a trip.
  ///
  /// Uses a greedy creditor/debtor matching algorithm: repeatedly pair the
  /// largest creditor with the largest debtor until all balances are zero.
  /// This guarantees the fewest possible transactions (O(n) transfers for n users).
  List<Settlement> computeOptimalSettlements(TripModel trip) {
    final balances = _computeNetBalances(trip);
    balances.removeWhere((_, v) => v.abs() < 0.01);
    if (balances.isEmpty) return [];

    final creditors = balances.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final debtors = balances.entries.where((e) => e.value < 0).toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final creditAmounts = creditors.map((e) => e.value).toList();
    final debitAmounts = debtors.map((e) => e.value.abs()).toList();

    final settlements = <Settlement>[];
    var ci = 0;
    var di = 0;

    while (ci < creditors.length && di < debtors.length) {
      final transfer = (min(creditAmounts[ci], debitAmounts[di]) * 100).round() / 100;
      if (transfer > 0.01) {
        settlements.add(Settlement(
          fromUserId: debtors[di].key,
          toUserId: creditors[ci].key,
          amount: transfer,
        ));
      }
      creditAmounts[ci] -= transfer;
      debitAmounts[di] -= transfer;
      if (creditAmounts[ci] < 0.01) ci++;
      if (debitAmounts[di] < 0.01) di++;
    }

    return settlements;
  }

  /// Computes each user's net balance across all unsettled expenses.
  /// Positive = owed money by others. Negative = owes money to others.
  Map<String, double> _computeNetBalances(TripModel trip) {
    final joinedUsers = trip.joinedUsers ?? [];
    final balances = <String, double>{for (final uid in joinedUsers) uid: 0.0};

    for (final expense in trip.expenses ?? []) {
      final payer = expense.createdBy;
      final unsettled = joinedUsers
          .where((uid) => uid != payer && !expense.paidByUsers.contains(uid))
          .toList();

      if (unsettled.isEmpty) continue;

      if (expense.splitType == 'equally') {
        final share = expense.amount / joinedUsers.length;
        for (final uid in unsettled) {
          balances[uid] = (balances[uid] ?? 0) - share;
          balances[payer] = (balances[payer] ?? 0) + share;
        }
      } else {
        for (final uid in unsettled) {
          final owed = expense.owedTo[uid] ?? 0;
          if (owed > 0.01) {
            balances[uid] = (balances[uid] ?? 0) - owed;
            balances[payer] = (balances[payer] ?? 0) + owed;
          }
        }
      }
    }

    return balances;
  }

  /// Gets summary statistics for the trip expenses
  Map<String, dynamic> getTripExpenseSummary(TripModel trip) {
    final totalExpenses = calculateTotalTripExpenses(trip);
    final userShare = calculateUserShare(trip);
    final userSpent = calculateUserTotalSpent(trip);
    final netBalance = calculateNetBalance(trip);
    final remainingBudget = trip.tripBudget - totalExpenses;
    
    return {
      'totalExpenses': totalExpenses,
      'userShare': userShare,
      'userSpent': userSpent,
      'netBalance': netBalance,
      'remainingBudget': remainingBudget,
      'budgetUtilization': (totalExpenses / trip.tripBudget) * 100,
      'expenseCount': trip.expenses?.length ?? 0,
    };
  }
}
