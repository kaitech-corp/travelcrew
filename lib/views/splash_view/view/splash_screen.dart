import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../controller/splash_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SplashController controller = Get.find<SplashController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    Future.microtask(controller.setUser);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      isFullBody: true,
      leadingWidth: 0,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
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
