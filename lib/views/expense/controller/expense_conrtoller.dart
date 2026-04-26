import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/expense_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

class ExpenseController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> expenseSettleScaffoldKey =
      GlobalKey<ScaffoldState>();
  Rxn<TripModel> tripModel = Rxn<TripModel>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      tripModel.value = Get.arguments;
    }
  }

  TextEditingController expenseNameController = TextEditingController(),
      amountOwedController = TextEditingController();

  ExpenseModel? expenseToSettle;

  Rxn<PublicUserModel> selectedUser = Rxn<PublicUserModel>();

  List<Settlement> get optimalSettlements =>
      tripModel.value != null
          ? ExpenseService().computeOptimalSettlements(tripModel.value!)
          : [];

  Future<void> settleUp() async {
    try {
      if (selectedUser.value != null) {
        final selectedUid = selectedUser.value!.uid;
        if (!expenseToSettle!.paidByUsers.contains(selectedUid)) {
          expenseToSettle!.paidByUsers.add(selectedUid);
        }

        await FirebaseTripService.updateExpense(expenseToSettle!).then((
          value,
        ) async {
          final localExpense = tripModel.value!.expenses!.firstWhere(
            (element) => element.id == expenseToSettle!.id,
          );
          if (!localExpense.paidByUsers.contains(selectedUid)) {
            localExpense.paidByUsers.add(selectedUid);
          }
          tripModel.refresh();
          Get.back();
          showCustomSnackBar(content: 'Expense settled successfully');
        });
      } else {
        showCustomSnackBar(content: 'Please select a user');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error settling up expense: $e');
      }
    }
  }
}

class UserWithDues {
  UserWithDues({required this.user, required this.dues});
  PublicUserModel user;
  double dues;
}

List<PublicUserModel> getUsersWithHavingDues(
  ExpenseModel expenseModel,
  TripModel tripModel,
) {
  return tripModel.joindUsersList
          ?.where((e) => !expenseModel.paidByUsers.contains(e.uid))
          .toList() ??
      [];
}

List<UserWithDues> getUsersWithHavingDuesForTrip(TripModel trip) {
  final List<UserWithDues> users = [];
  for (final expense in trip.expenses ?? []) {
    final res = getUsersWithHavingDues(expense as ExpenseModel, trip);
    users.addAll(
      res.map((e) {
        return UserWithDues(user: e, dues: expense.amount);
      }).toList(),
    );
  }
  return users;
}
