import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/profile/components/about/controller/about_controller.dart';

import '../../../../utils/app_styles.dart';

class AboutScreen extends GetView<AboutController> {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'About',
      isBackIcon: true,
      scaffoldKey: controller.scaffoldKey,
      centerTitle: true,
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 25.h),
      className: runtimeType.toString(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // About Title
            Text(
              'About',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 22.sp,

                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),

            // About Content
            Text(
              'At TravelCrew, we are a passionate and driven team committed to delivering innovative solutions and exceptional experiences. Our company was founded with the goal of making travel planning with friends and family easier and more enjoyable, and we work tirelessly to build trust and lasting relationships with our clients, partners, and community.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              'We believe in integrity, collaboration, excellence, innovation, and strive to create a positive impact in everything we do. Whether it\'s through our travel planning tools, we are dedicated to making a difference and empowering individuals and groups to reach their fullest potential.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              'Our team is made up of diverse, talented professionals from various backgrounds who share a common vision of achieving greatness. Together, we work towards our collective goals with a sense of purpose, creativity, and enthusiasm.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              'Join us as we continue to push the boundaries of what\'s possible and shape the future of travel planning.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }
}
