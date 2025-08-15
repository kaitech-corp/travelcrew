import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/all_expenses/all_expenses_screen.dart';
import 'package:travel_crew/views/create_trip/create_trip_screen.dart';
import 'package:travel_crew/views/messages/users/user_screen.dart';

import '../../home_page/home_page_screen.dart';
import '../../my_trips/my_trips_screen.dart';

class MainViewController extends GetxController {
  var selectedIndex = 0.obs;
  List<Widget> pages = [
    const HomePageScreen(),
    MyTripsScreen(),
    CreateTripScreen(),
    UsersScreen(),
    // ExpenseScreen(fromMainView: true),
    AllExpensesScreen(),
    // ProfileScreen(),
    // const   CompaniesScreen(),
    // const   JobsScreen(),
    // const   MyProfileScreen(),
  ];
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  void changeIndex(int index) {
    if (index == 2) {
      Get.toNamed(kCreateTripScreenRoute);
      return;
    }
    selectedIndex.value = index;
  }
}
