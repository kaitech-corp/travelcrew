import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/profile/controller/profle_controller.dart';
import 'package:travel_crew/views/profile/widgets/profile_widget.dart';

import '../../../utils/app_images.dart';
import '../../utils/app_styles.dart';
import '../custom_widgets/custom_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.profile,
      centerTitle: true,
      showNotificationBell: true,
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30.h),
            Obx(
              () => ProfileWidget(
                isNetworkImage: true,
                title: l10n.personalInformation,
                leadingImage:
                    GlobalVariables.loggedInUser.value?.profileImage ?? '',
                onTap:
                    () => Get.toNamed(
                      kProfileSetUpScreenRoute,
                      arguments: 'fromProfile',
                    ),
              ),
            ),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => Get.toNamed(
                            kConnectionsScreenRoute,
                            arguments: {
                              'userId': GlobalVariables.loggedInUser.value?.uid,
                              'initialIndex': 0,
                            },
                          ),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.kWhiteColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.kLightGreyColor),
                        ),
                        child: Column(
                          children: [
                            Obx(
                              () => Text(
                                '${controller.publicProfile.value?.followers?.length ?? 0}',
                                style: AppStyles.labelTextStyle().copyWith(
                                  fontSize: AppStyles.fontSize18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(l10n.followers),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: GestureDetector(
                      onTap:
                          () => Get.toNamed(
                            kConnectionsScreenRoute,
                            arguments: {
                              'userId': GlobalVariables.loggedInUser.value?.uid,
                              'initialIndex': 1,
                            },
                          ),
                      child: Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.kWhiteColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: AppColors.kLightGreyColor),
                        ),
                        child: Column(
                          children: [
                            Obx(
                              () => Text(
                                '${controller.publicProfile.value?.following?.length ?? 0}',
                                style: AppStyles.labelTextStyle().copyWith(
                                  fontSize: AppStyles.fontSize18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(l10n.following),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.h),
            ProfileWidget(
              title: l10n.changePassword,
              leadingImage: AppImages.kChangePasswordImage,
              onTap: () => Get.toNamed(kChangePasswordScreenRoute),
            ),
            SizedBox(height: 20.h),
            ProfileWidget(
              title: l10n.notifications,
              leadingImage: AppImages.kHelpAndSupportImage,
              trailingIcon: Obx(
                () => Switch(
                  value: controller.isNotificationEnabled.value,
                  onChanged: (v) => controller.isNotificationEnabled.value = v,
                ),
              ),
              onTap: () {},
            ),
            SizedBox(height: 20.h),
            ProfileWidget(
              title: l10n.helpAndSupport,
              leadingImage: AppImages.kProfileInfoIcon,
              onTap: () => Get.toNamed(kHelpNSupportScreenRoute),
            ),
            SizedBox(height: 20.h),
            ProfileWidget(
              title: l10n.privacyPolicyAndTerms,
              leadingImage: AppImages.kTermsIcon,
              onTap: () {
                Get.toNamed(kPrivacyPolicyScreenRoute);
              },
            ),
            SizedBox(height: 20.h),
            ProfileWidget(
              title: l10n.about,
              leadingImage: AppImages.kAboutIcon,
              onTap: () => Get.toNamed(kAboutScreenRoute),
            ),
            SizedBox(height: 20.h),
            ProfileWidget(
              title: l10n.deleteAccount,
              leadingImage: AppImages.kIcDeleteAccount,
              onTap: () {
                showDialog(
                  context: context,
                  builder:
                      (c) => AlertDialog(
                        title: Text(l10n.deleteAccount),
                        content: Text(
                          l10n.confirmDeleteAccount,
                          style: AppStyles.labelTextStyle().copyWith(
                            fontSize: AppStyles.fontSize14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Get.back();
                              AuthService.deleteAccount();
                            },
                            child: Text(l10n.delete),
                          ),
                          TextButton(
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(l10n.cancel),
                          ),
                        ],
                      ),
                );
              },
            ),
            SizedBox(height: 40.h),
            GestureDetector(
              onTap: () async {
                AuthService.signOut();
              },
              child: Container(
                width: 230.23.w,
                padding: EdgeInsets.symmetric(
                  horizontal: 17.44.w,
                  vertical: 15.70.h,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: const Color(0x19EC3535),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1.31,
                      color: Color(0x7FEC3535),
                    ),
                    borderRadius: BorderRadius.circular(41.86.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 6.98.w,
                  children: [
                    Image.asset(AppImages.kLogOutIcon, scale: 4),
                    Text(
                      l10n.logout,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFFDA2828),
                        fontSize: AppStyles.fontSize13,

                        fontWeight: FontWeight.w600,
                        height: 1.25.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 120.h),
          ],
        ),
      ),
    );
  }
}
