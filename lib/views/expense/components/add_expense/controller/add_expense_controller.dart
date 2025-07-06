import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

import '../../../../../services/session_services.dart';

class AddExpenseController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController expenseNameController = TextEditingController(),
      amountController = TextEditingController();

  Rxn<DateTime> expenceDate = Rxn<DateTime>(null);

  addExpense() async {
    ExpenseModel expenseModel = ExpenseModel(
      paidByUsers: [],
      name: expenseNameController.text,
      amount: double.parse(amountController.text),
      date: expenceDate.value ?? DateTime.now(),
      id: Uuid().v6(),
      tripId: Get.arguments['tripId'],
      createdBy: GlobalVariables.loggedInUser.value?.uid ?? '',
    );

    try {
      GlobalVariables.showLoader.value = true;
      await FirebaseTripService.addExpenses(expense: expenseModel).then((
        value,
      ) {
        if (value) {
          Get.arguments['onAdd']?.call(expenseModel);
          Get.back();
          showCustomSnackBar(content: 'Expense added successfully');
        } else {
          showCustomSnackBar(content: 'Failed to add expense');
        }
      });
    } catch (e) {}
    GlobalVariables.showLoader.value = false;
  }
}
