import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      isFullBody: true,
      leadingWidth: 0,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      body: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(color: AppColors.kWhiteColor),
        child: Stack(
          children: [
            Center(
              child: Image.asset(AppImages.kAppLogo, width: context.width),
            ),
          ],
        ),
      ),
    );
  }
}
