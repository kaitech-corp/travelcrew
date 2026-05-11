import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../custom_widgets/custom_scaffold.dart';
import 'controller/onboarding_controller.dart';
import 'widgets/onboarding_page_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final OnboardingController controller = Get.find<OnboardingController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      isFullBody: true,
      leadingWidth: 0,
      padding: EdgeInsets.zero,
      scaffoldKey: _scaffoldKey,
      className: 'onboarding',
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: PageView.builder(
          controller: controller.pageController,
          onPageChanged: controller.onPageChanged,
          itemCount: controller.pages.length,
          itemBuilder: (context, index) {
            return OnboardingPageWidget(
              page: controller.pages[index],
              index: index,
            );
          },
        ),
      ),
    );
  }
}
