import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';
import 'package:travel_crew/views/profile/components/privacy_policy/controller/privacy_policy_controller.dart';

import '../../../../utils/app_styles.dart';

class PrivacyPolicyScreen extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.privacyPolicyAndTerms,
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
              l10n.terms,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 18.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.termsContent,
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
              l10n.useLicense,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black,
                fontSize: 18.sp,

                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              l10n.useLicenseContent,
              style: AppStyles.labelTextStyle().copyWith(
                color: Colors.black87,
                fontSize: 14.sp,

                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            // Bullet points
            _buildBulletPoint(l10n.bullet1),
            SizedBox(height: 8.h),
            _buildBulletPoint(l10n.bullet2),
            SizedBox(height: 8.h),
            _buildBulletPoint(l10n.bullet3),
            SizedBox(height: 8.h),
            _buildBulletPoint(l10n.bullet4),
            SizedBox(height: 24.h),

            // Additional paragraph
            Text(
              l10n.additionalParagraph,
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
