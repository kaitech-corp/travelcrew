import 'package:get/get.dart';

class RangePickerController extends GetxController {
  // Observable variables to hold the selected start and end dates
  Rx<DateTime> startDate = DateTime.now().obs;
  Rx<DateTime> endDate = DateTime.now().obs;

  // Method to set the start date
  void setStartDate(DateTime date) {
    startDate.value = date;
  }

  // Method to set the end date
  void setEndDate(DateTime date) {
    endDate.value = date;
  }

  // Method to reset the date range
  void resetDateRange() {
    startDate.value = DateTime.now();
    endDate.value = DateTime.now();
  }
}
