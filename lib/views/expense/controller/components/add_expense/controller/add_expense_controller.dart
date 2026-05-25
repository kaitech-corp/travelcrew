import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/expense_model.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:uuid/uuid.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

import '../../../../../../services/session_services.dart';

class AddExpenseController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  TextEditingController expenseNameController = TextEditingController(),
      amountController = TextEditingController();

  Rxn<DateTime> expenceDate = Rxn<DateTime>();
  RxString splitType = 'equally'.obs;
  RxMap<String, double> owedTo = <String, double>{}.obs;
  RxMap<String, double> owners = <String, double>{}.obs;
  RxList<PublicUserModel> tripMembers = <PublicUserModel>[].obs;
  RxList<String> selectedMembers = <String>[].obs;

  String? _tripId;
  void Function(ExpenseModel expense)? _onAdd;

  @override
  void onInit() {
    super.onInit();
    initializeFromArguments(Get.arguments);
  }

  void initializeFromArguments(dynamic args) {
    _resetFormState();

    if (args is! Map) {
      return;
    }

    final members = args['tripMembers'];
    if (members is List<PublicUserModel>) {
      tripMembers.assignAll(members);
    }

    final trip = args['trip'];
    if (trip is TripModel) {
      _tripId ??= trip.id;
    }

    final tripId = args['tripId'];
    if (tripId is String && tripId.isNotEmpty) {
      _tripId = tripId;
    }

    final onAdd = args['onAdd'];
    if (onAdd is Function) {
      _onAdd = (expense) => onAdd(expense);
    }
  }

  void _resetFormState() {
    expenseNameController.clear();
    amountController.clear();
    expenceDate.value = null;
    splitType.value = 'equally';
    owedTo.clear();
    owners.clear();
    selectedMembers.clear();
    tripMembers.clear();
    _tripId = null;
    _onAdd = null;
  }

  void toggleMemberSelection(String uid) {
    if (selectedMembers.contains(uid)) {
      selectedMembers.remove(uid);
    } else {
      selectedMembers.add(uid);
    }
  }

  Future<void> addExpense() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final expenseAmount = double.tryParse(amountController.text) ?? 0.0;

    // Validate expense amount
    if (expenseAmount <= 0) {
      showCustomSnackBar(content: 'Please enter a valid expense amount');
      return;
    }

    // Prepare owedTo map based on split type
    Map<String, double> finalOwedTo = {};
    if (splitType.value == 'equally') {
      // For equal split, calculate per person amount
      final totalMembers = tripMembers.length;
      if (totalMembers > 0) {
        final amountPerPerson = expenseAmount / totalMembers;
        for (final member in tripMembers) {
          if (member.uid != GlobalVariables.loggedInUser.value?.uid) {
            finalOwedTo[member.uid] = amountPerPerson;
          }
        }
      }
    } else {
      // Use custom owedTo amounts
      finalOwedTo = Map<String, double>.from(owedTo);
    }

    if (_tripId == null || _tripId!.isEmpty) {
      showCustomSnackBar(
        content: 'Missing trip information',
        contentType: ContentType.failure,
      );
      return;
    }

    final ExpenseModel expenseModel = ExpenseModel(
      paidByUsers: [GlobalVariables.loggedInUser.value?.uid ?? ''],
      name: expenseNameController.text.trim(),
      amount: expenseAmount,
      date: expenceDate.value ?? DateTime.now(),
      id: const Uuid().v6(),
      tripId: _tripId!,
      createdBy: GlobalVariables.loggedInUser.value?.uid ?? '',
      splitType: splitType.value,
      owedTo: finalOwedTo,
      owners: owners,
    );

    try {
      GlobalVariables.showLoader.value = true;
      await FirebaseTripService.addExpenses(expense: expenseModel).then((
        value,
      ) {
        if (value) {
          _onAdd?.call(expenseModel);
          Get.back();
          showCustomSnackBar(content: 'Expense added successfully');
        } else {
          showCustomSnackBar(
            content: 'Failed to add expense',
            contentType: ContentType.failure,
          );
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding expense: $e');
      }
      showCustomSnackBar(
        content: 'Error adding expense: ${e.toString()}',
        contentType: ContentType.failure,
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  /// Updates the owedTo amount for a specific user in custom split
  void updateOwedAmount(String userId, double amount) {
    if (amount > 0) {
      owedTo[userId] = amount;
    } else {
      owedTo.remove(userId);
    }
  }

  /// Validates that custom split amounts don't exceed total expense
  bool validateCustomSplit() {
    if (splitType.value != 'custom') return true;

    final totalOwed = owedTo.values.fold(0.0, (sum, amount) => sum + amount);
    final expenseAmount = double.tryParse(amountController.text) ?? 0.0;

    return totalOwed <= expenseAmount;
  }

  /// Gets remaining amount to be allocated in custom split
  double getRemainingAmount() {
    final expenseAmount = double.tryParse(amountController.text) ?? 0.0;
    final totalOwed = owedTo.values.fold(0.0, (sum, amount) => sum + amount);
    return expenseAmount - totalOwed;
  }

  @override
  void onClose() {
    expenseNameController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
