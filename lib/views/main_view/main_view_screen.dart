import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/views/my_trips/my_trips_screen.dart';

import '../../../utils/app_images.dart';
import '../../main.dart';
import '../custom_widgets/custom_bottom_bar.dart';
import '../custom_widgets/custom_scaffold.dart';
import 'controller/main_view_controller.dart';

class MainViewScreen extends GetView<MainViewController> {
  MainViewScreen({super.key});
  late bool isKeyboardVisible = false;
  @override
  Widget build(BuildContext context) {
    isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    mainViewController = controller;
    // DateTime? lastBackPressed;
    return CustomScaffold(
      className: '',
      screenName: '',
      onWillPop: () async {
        if (controller.selectedIndex.value == 0) {
          await showExitConfirmationDialog(context);
        } else {
          controller.changeIndex(0);
        }
      },
      scaffoldKey: controller.scaffoldKey,
      leadingWidth: 0,
      isFullBody: true,
      appBarSize: 0,
      padding: EdgeInsets.zero,
      body: Stack(
        children: [
          SizedBox(height: context.height, width: context.width),
          Obx(
            () =>
                controller.selectedIndex.value == -1
                    ? const MyTripsScreen()
                    : controller.pages[controller.selectedIndex.value],
          ),
          if (!isKeyboardVisible)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Obx(
                  () => CustomBottomBar(
                    navItems: [
                      BottomNavigationBarItem(
                        icon: ImageIcon(
                          AssetImage(
                            controller.selectedIndex.value == 0
                                ? AppImages.kHomeFilledIcon
                                : AppImages.kHomeIcon,
                          ),
                        ),
                        label: 'Explore',
                      ),
                      BottomNavigationBarItem(
                        icon: ImageIcon(
                          AssetImage(
                            controller.selectedIndex.value == 1
                                ? AppImages.kTripsFilledIcon
                                : AppImages.kTripIcon,
                          ),
                        ),
                        label: 'My Trips',
                      ),
                      BottomNavigationBarItem(
                        icon: ImageIcon(
                          AssetImage(
                            controller.selectedIndex.value == 2
                                ? AppImages.kChatFilledIcon
                                : AppImages.kChatIcon,
                          ),
                        ),
                        label: 'Inbox',
                      ),
                      BottomNavigationBarItem(
                        icon: ImageIcon(
                          AssetImage(
                            controller.selectedIndex.value == 3
                                ? AppImages.kProfileFilledIcon
                                : AppImages.kProfileIcon,
                          ),
                        ),
                        label: 'Profile',
                      ),
                    ],
                    selectedIndex: controller.selectedIndex.value,
                    onTap: (index) {
                      controller.changeIndex(index);
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void getColor(int index, int currentIndex) {
  index == currentIndex ? Colors.white : Colors.red;
}
