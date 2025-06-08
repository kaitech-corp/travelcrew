import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/messages/group/controller/group_controller.dart';

import '../../custom_widgets/custom_scaffold.dart';

class GroupScreen extends GetView<GroupController> {
  const GroupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: '',
      isBackIcon: true,
      scaffoldKey: controller.scaffoldKey,
      centerTitle: true,
      className: 'Group',
      leadingWidth: Get.width,
      leadingWidget: Row(
        children: [
          Image.asset(AppImages.kBackIcon, scale: 4),
          SizedBox(width: 10.w),
          CircleAvatar(
            radius: 30.r,
            backgroundImage: AssetImage(AppImages.kLocationImage),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(children: [SizedBox(height: 50.h)]),
      ),
    );
  }
}
