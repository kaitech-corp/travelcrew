import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/location_dropdown.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_images.dart';
import '../../../utils/custom_snackbar.dart';
import '../../custom_widgets/custom_text_field.dart';
import '../controller/create_trip_controller.dart';

class StepsSix extends StatelessWidget {
  const StepsSix({super.key, required this.controller});
  final CreateTripController controller;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formStep6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Search Friend (In-App)',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.93.sp,
              fontWeight: FontWeight.w600,
              height: 1.33.h,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => LocationDropdownWidget(
              hintText: 'Search',
              onTap: (placeId, searchText) {
                if (searchText.placeId != null) {
                  controller.invitedUsersList.add(searchText.placeId!);
                }
              },
              items: controller.searchedFriends,
              onChanged: (value) => controller.searchFriends(),

              suffixIconConstraints: BoxConstraints(maxHeight: 60.h),
              selectedText: controller.searchText.value,
              // validator:
              //     (p0) =>
              //         p0?.isBlank == true
              //             ? 'Please enter a friend\'s name'
              //             : null,
              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 10.w),
                child: ImageIcon(
                  AssetImage(AppImages.kSendIcon),
                  size: 25.sp,
                  color: AppColors.kPrimaryColor,
                ),
              ),
              textEditingController: controller.searchFriendController,
              focusNode: FocusNode(),
            ),
          ),
          SizedBox(height: 27.h),
          Text(
            'Send Invites (Email)',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          CustomTextField(
            controller: controller.sendInviteEmailController,
            focusNode: controller.sendInviteEmailFocusNode,
            suffixIcon: GestureDetector(
              onTap: () {
                if (controller.sendInviteEmailController.text.isEmail) {
                  controller.invitedUsersList.add(
                    controller.sendInviteEmailController.text,
                  );
                  controller.sendInviteEmailController.clear();
                } else {
                  showCustomSnackBar(
                    contentType: ContentType.failure,
                    title: 'Error',
                    content: 'Please enter a valid email',
                  );
                }
              },
              child: ImageIcon(
                AssetImage(AppImages.kSendIcon),
                size: 18.sp,
                color: AppColors.kPrimaryColor,
              ),
            ),
            onFieldSubmitted: (p0) {
              if (p0.isEmail) {
                controller.invitedUsersList.add(p0);
                controller.sendInviteEmailController.clear();
              }
            },
            hintText: 'Test@gmail.com',
          ),
          SizedBox(height: 27.h),
          Text(
            'Users who will be invited',
            style: AppStyles.labelTextStyle().copyWith(
              color: Colors.black,
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Obx(
            () => Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children:
                  controller.invitedUsersList
                      .map(
                        (e) => Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kPrimaryColor.withAlpha(26),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            e,
                            style: AppStyles.labelTextStyle().copyWith(
                              color: Colors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
