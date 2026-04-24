import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/views/inbox/inbox_screen.dart';
import 'package:travel_crew/views/profile/profile_screen.dart';

import '../../home_page/home_page_screen.dart';
import '../../my_trips/my_trips_screen.dart';

class MainViewController extends GetxController {
  var selectedIndex = 0.obs;
  List<Widget> pages = [
    const HomePageScreen(),
    const MyTripsScreen(),
    const InboxScreen(),
    const ProfileScreen(),
  ];
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  void changeIndex(int index) {
    selectedIndex.value = index;
  }
}
