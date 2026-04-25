import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_scaffold.dart';

import '../../../utils/app_images.dart';
import '../../custom_widgets/bottom_sheets/custom_image_bottomsheet.dart';
import '../../custom_widgets/custom_text_field.dart';
import 'controller/sign_up_controller.dart';

class ProfileSetupPage extends GetView<SignUpController> {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: runtimeType.toString(),
      scaffoldKey: controller.profileSetupKey,
      screenName: Get.arguments == 'fromProfile' ? 'Personal information' : '',
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: controller.profileSetupFormKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                if (Get.arguments != 'fromProfile') ...{
                  /// Title
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Profile Setup',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize28,
                        fontWeight: FontWeight.w600,
                        height: 1.20,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                },

                /// Profile Avatar
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    SizedBox(height: 120.h, width: context.width),
                    Positioned(
                      top: 0,
                      child: Obx(
                        () => AnyImageView(
                          height: 100.h,
                          width: 100.w,
                          fileType:
                              Get.arguments == 'fromProfile' &&
                                      controller.selectedImage.isEmpty
                                  ? SourceType.network
                                  : SourceType.file,
                          isCircle: true,
                          url:
                              Get.arguments == 'fromProfile' &&
                                      controller.selectedImage.isEmpty
                                  ? GlobalVariables
                                          .loggedInUser
                                          .value
                                          ?.profileImage ??
                                      ''
                                  : controller.selectedImage.value,
                        ),
                      ),
                    ),
                    Positioned(
                      child: AnyImageView(
                        ontap: () async {
                          final List<String> pickedImage =
                              await ImagePickerBottomSheet()
                                  .getImageFromCameraOrGallery(context);
                          if (pickedImage.isNotEmpty) {
                            controller.selectedImage.value = pickedImage.first;
                          }
                        },
                        height: 52.h,
                        isCircle: true,
                        fileType: SourceType.asset,
                        width: 52.w,
                        url: AppImages.kCameraIcon,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    AnyImageView(
                      fileType: SourceType.asset,
                      url: AppImages.kIcUser,
                      height: 35.h,
                      width: 35.w,
                      padding: const EdgeInsets.all(5),
                      containerBackgroundColor: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Name',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.black,
                        fontSize: AppStyles.fontSize14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                CustomTextField(
                  controller: controller.userNameController,
                  focusNode: controller.userNameFocus,
                  hintText: 'User Name',
                  validator: (p0) {
                    if (p0 == null || p0.isEmpty) {
                      return 'Please enter name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.h),

                Row(
                  children: [
                    AnyImageView(
                      fileType: SourceType.asset,
                      url: AppImages.kPhoneIcon,
                      height: 35.h,
                      width: 35.w,
                      padding: const EdgeInsets.all(5),
                      containerBackgroundColor: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Nationality & Phone Number',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.grey,
                        fontSize: AppStyles.fontSize14,

                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                /// Phone Number with Country
                IntlPhoneField(
                  // autovalidateMode: AutovalidateMode.onUnfocus,
                  // Validator function is not working properly. Validation is triggered on every keystroke.
                  // validator: (p0) {
                  //   if (p0 == null || !p0.isValidNumber()) {
                  //     return 'Please enter a valid phone number';
                  //   }
                  //   return null;
                  // },

                  controller: controller.phoneController,
                  focusNode: controller.phoneFocus,
                  initialCountryCode:
                      controller.selectedCountry.value?.code ?? 'US',
                  // disableLengthCheck: true,
                  dropdownIconPosition: IconPosition.trailing,
                  dropdownTextStyle: AppStyles.labelTextStyle().copyWith(
                    fontSize: AppStyles.fontSize14,
                    fontWeight: FontWeight.w500,
                    height: 1.25,
                    color: Colors.grey[600],
                  ),
                  onCountryChanged:
                      (value) => controller.selectedCountry.value = value,
                  dropdownIcon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  decoration: InputDecoration(
                    errorMaxLines: 2,
                    hintText: '555 *** ****',
                    hintStyle: AppStyles.labelTextStyle().copyWith(
                      fontSize: AppStyles.fontSize14,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: Colors.grey[600],
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.r),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF4F4F4),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 16.h,
                    ),
                  ),
                  onChanged: (phone) {
                    debugPrint(phone.completeNumber);
                  },
                ),

                const SizedBox(height: 30),

                /// Complete Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (controller.profileSetupFormKey.currentState!
                          .validate()) {
                        controller.updateProfile();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      Get.arguments == 'fromProfile' ? 'Update' : 'Complete',
                      style: AppStyles.labelTextStyle().copyWith(
                        color: Colors.white,
                        fontSize: AppStyles.fontSize14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
