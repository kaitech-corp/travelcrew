import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/profile/components/privacy_policy/controller/privacy_policy_controller.dart';

import '../../../../utils/app_styles.dart';

class PrivacyPolicyScreen extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      screenName: 'Privacy Policy &\n Terms',
      isBackIcon: true,
      scaffoldKey: controller.scaffoldKey,
      centerTitle: true,
      padding: EdgeInsets.only(left: 18.w, right: 18.w, top: 25.h),
      className: 'Privacy Policy',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Terms Section
            Text(
              '1. Terms',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 18.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Tellus at sit ante rutrum suspendisse pretium, vitae vel dignissim. Nunc, scelerisque adipiscing condimentum massa dignissim tortor leo lacus. Sapien felis ultrices fringilla nisi sit nibh. Etiam volutpat nisl ornare lorem mus at a, et pulvinar.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 14.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),

            // 2. Use License Section
            Text(
              '2. Use License',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 18.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Fermentum erat nisl duis varius risus. Augue ac facilisi porta metus enim. Ullamcorper lacus praesent rhoncus, sapien rutrum nulla mattis vitae ultrices.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 14.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            // Bullet points
            _buildBulletPoint('Fermentum erat nisl duis varius risus.'),
            SizedBox(height: 8.h),
            _buildBulletPoint('Augue ac facilisi porta metus enim.'),
            SizedBox(height: 8.h),
            _buildBulletPoint(
              'Ullamcorper lacus praesent rhoncus, sapien rutrum nulla mattis vitae ultrices.',
            ),
            SizedBox(height: 8.h),
            _buildBulletPoint(
              'Nunc, scelerisque adipiscing condimentum massa dignissim tortor leo lacus.',
            ),
            SizedBox(height: 24.h),

            // Additional paragraph
            Text(
              'Aliquam eget purus sit malesuada tempor euismod. Eget commodo ultricies ut elit hendrerit risus. Elementum tellus nisl lectus bibendum malesuada orci dui. Nunc pharetra.',
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 14.sp,

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

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black87,
            fontSize: 14.sp,

            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            text,
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black87,
              fontSize: 14.sp,

              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
