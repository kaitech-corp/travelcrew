import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/app_images.dart';
import '../../../../utils/app_styles.dart';
import '../../../../utils/debugging.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({
    super.key,
    this.screenTitle = '',
    this.backIcon = true,
    this.className = '',
    this.actions = const [],
    this.onBackButtonTap,
    required this.scaffoldKey,
    this.leadingWidth = 76,
    this.centerTitle,
    this.screenTitleColor,
    this.leadingWidget,
    this.backIconColor,
    this.title,
  });
  final String screenTitle;
  final String className;
  final VoidCallback? onBackButtonTap;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final List<Widget> actions;
  final double leadingWidth;
  final Color? screenTitleColor;
  final Widget? leadingWidget;
  final Widget? title;
  final bool backIcon;
  final bool? centerTitle;
  final Color? backIconColor;
  @override
  Widget build(BuildContext context) {
    kLogging('=============class name$className ${leadingWidth == 0.0}');
    return AppBar(
      scrolledUnderElevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      actions: actions,
      leadingWidth: leadingWidth,
      leading:
          leadingWidth > 0
              ? GestureDetector(
                onTap:
                    onBackButtonTap ??
                    () {
                      if (backIcon) {
                        Get.back();
                      }
                    },
                child: Padding(
                  padding: EdgeInsets.only(left: 18.w),
                  child:
                      leadingWidget ??
                      (backIcon && Navigator.canPop(context)
                          ? Image.asset(AppImages.kBackIcon, scale: 4)
                          : const SizedBox.shrink()),
                ),
              )
              : const SizedBox.shrink(),
      title:
          title ??
          Text(
            screenTitle,
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 27.91.sp,
              fontWeight: FontWeight.w600,
              height: 1.25.h,
            ),
          ),
      centerTitle: centerTitle ?? false,
      foregroundColor: Colors.transparent,
    );
  }
}
