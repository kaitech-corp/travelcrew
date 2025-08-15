import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/profile/components/about/controller/about_controller.dart';

import '../../../../utils/app_styles.dart';

class AboutScreen extends GetView<AboutController> {
  const AboutScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.about,
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
              l10n.aboutTitle,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 22.sp,

                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 16.h),

            // About Content
            Text(
              l10n.aboutContent1,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.aboutContent2,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.aboutContent3,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 15.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            Text(
              l10n.aboutContent4,
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
