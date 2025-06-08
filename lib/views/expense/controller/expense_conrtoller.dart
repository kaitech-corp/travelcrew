import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
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

  Rxn<UserModel> selectedUser = Rxn<UserModel>(null);

  settleUp() async {
    try {
      if (selectedUser.value != null) {
        expenseToSettle!.paidByUsers.add(selectedUser.value!.id);

        await FirebaseTripService.updateExpense(expenseToSettle!).then((
          value,
        ) async {
          tripModel.value!.expenses!
              .firstWhere((element) => element.id == expenseToSettle!.id)
              .paidByUsers
              .add(selectedUser.value!.id);
          tripModel.refresh();
          Get.back();
          showCustomSnackBar(content: 'Expense settled successfully');
        });
      } else {
        showCustomSnackBar(content: 'Please select a user');
      }
    } catch (e) {}
  }
}

class UserWithDues {
  UserModel user;
  double dues;
  UserWithDues({required this.user, required this.dues});
}

List<UserModel> getUsersWithHavingDues(
  ExpenseModel expenseModel,
  TripModel tripModel,
) {
  return tripModel.joindUsersList
          ?.where((e) => !expenseModel.paidByUsers.contains(e.id))
          .toList() ??
      [];
}

List<UserWithDues> getUsersWithHavingDuesForTrip(TripModel trip) {
  List<UserWithDues> users = [];
  for (var expence in trip.expenses ?? []) {
    var res = getUsersWithHavingDues(expence, trip);
    users.addAll(
      res.map((e) {
        return UserWithDues(user: e, dues: expence.amount);
      }).toList(),
    );
  }
  return users;
}
