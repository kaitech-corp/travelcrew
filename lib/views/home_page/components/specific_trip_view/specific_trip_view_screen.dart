import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/custom_trip_tabs.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/expense_tab.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/components/transport_tab.dart';
import 'package:travel_crew/views/home_page/components/specific_trip_view/controller/specific_trip_view_controller.dart';

import '../../../custom_widgets/custom_elevated_button.dart';
import '../../../custom_widgets/custom_scaffold.dart';
import '../../../messages/users/controller/users_controller.dart';
import '../../../onboarding/widgets/page_indicator.dart';
import '../../widgets/location_widget.dart';
import 'components/activities_tab.dart';
import 'components/lodging_tab.dart';

class SpecificTripViewScreen extends GetView<SpecificTripViewController> {
  const SpecificTripViewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Future.microtask(() {
      controller.tripModel.value =
          Get.arguments is TripModel
              ? Get.arguments as TripModel
              : Get.arguments['trip'] as TripModel;
    });
    return CustomScaffold(
      onWillPop: () {
        if (Navigator.canPop(context)) {
          Get.back();
        } else {
          Get.offAllNamed(kMainViewScreenRoute);
          // Get.close(1);
        }
      },
      screenName: '',
      isBackIcon: false,
      leadingWidth: 0,
      isFullBody: true,
      appBarSize: 0,
      padding: EdgeInsets.zero,
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      body: Obx(
        () =>
            controller.tripModel.value == null
                ? const SizedBox()
                : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: Get.height * 0.45,
                            child: PageView.builder(
                              itemCount:
                                  controller.tripModel.value?.images.length ??
                                  0,
                              itemBuilder:
                                  (c, index) => Stack(
                                    children: [
                                      Container(
                                        width: Get.width,
                                        height: Get.height * 0.45,
                                        color: Colors.black,
                                      ),
                                      AnyImageView(
                                        width: Get.width,
                                        height: Get.height * 0.45,
                                        url:
                                            controller
                                                .tripModel
                                                .value
                                                ?.images[index] ??
                                            '',
                                      ),
                                      Align(
                                        alignment: Alignment.topCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 40.h),
                                          child: Row(
                                            children: [
                                              SizedBox(width: 10.w),
                                              GestureDetector(
                                                onTap: () => Get.back(),
                                                child: BlurryContainer(
                                                  padding: EdgeInsets.all(
                                                    10.sp,
                                                  ),
                                                  blur: 7,
                                                  height: 51.14.h,
                                                  width: 51.14.w,
                                                  color: Colors.black
                                                      .withValues(alpha: .15),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: const Icon(
                                                    Icons.arrow_back_ios_new,
                                                    color:
                                                        AppColors.kWhiteColor,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              GestureDetector(
                                                // onTap:
                                                //     () => controller.doitFavourite(
                                                //       controller
                                                //           .tripModel
                                                //           .value
                                                //           ?.id,
                                                //       isFavourites:
                                                //           GlobalVariables
                                                //               .userProfile
                                                //               .value
                                                //               ?.favouriteTrips
                                                //               ?.contains(
                                                //                 controller
                                                //                     .tripModel
                                                //                     .value
                                                //                     ?.id,
                                                //               ) ??
                                                //           false,
                                                //     ),
                                                child: BlurryContainer(
                                                  padding: EdgeInsets.all(
                                                    10.sp,
                                                  ),
                                                  blur: 7,
                                                  height: 51.14.h,
                                                  width: 51.14.w,
                                                  color: Colors.black
                                                      .withValues(alpha: .15),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: Obx(
                                                    () =>
                                                        GlobalVariables
                                                                    .addingToFavourites
                                                                    .value ==
                                                                controller
                                                                    .tripModel
                                                                    .value!
                                                                    .id
                                                            ? showLoaderWhenAddingToFavourites()
                                                            : const Icon(
                                                              Icons
                                                                  .star_rounded,
                                                              // color:
                                                              //     GlobalVariables
                                                              //                 .loggedInUser
                                                              //                 .value
                                                              //                 ?.favouriteTrips
                                                              //                 ?.contains(
                                                              //                   controller.tripModel.value?.id,
                                                              //                 ) ??
                                                              //             false
                                                              //         ? AppColors
                                                              //             .productBgColor
                                                              //         : const Color(
                                                              //           0xFF77818D,
                                                              //         ),
                                                              size: 25,
                                                            ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                              GestureDetector(
                                                onTap: () {
                                                  showDialog(
                                                    context: context,
                                                    builder:
                                                        (c) => Stack(
                                                          children: [
                                                            SizedBox(
                                                              height:
                                                                  context
                                                                      .height,
                                                              width:
                                                                  context.width,
                                                            ),
                                                            Positioned(
                                                              top: 60.h,
                                                              right: 30.w,
                                                              child: SizedBox(
                                                                width: 204.07.w,
                                                                child: BlurryContainer(
                                                                  blur: 7,
                                                                  color: Colors
                                                                      .black
                                                                      .withValues(
                                                                        alpha:
                                                                            .15,
                                                                      ),
                                                                  padding:
                                                                      EdgeInsets.all(
                                                                        11.sp,
                                                                      ),
                                                                  child: Column(
                                                                    spacing:
                                                                        7.h,
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      if (GlobalVariables.isLoggedInUser(
                                                                        controller.tripModel.value?.createdBy ??
                                                                            '',
                                                                      ))
                                                                        MoreVertDialogueWidget(
                                                                          title:
                                                                              'Edit Trip',
                                                                          onTap: () {
                                                                            Get.back();
                                                                            Get.offAndToNamed(
                                                                              kCreateTripScreenRoute,
                                                                              arguments:
                                                                                  controller.tripModel.value,
                                                                            );
                                                                          },
                                                                          imagePath:
                                                                              AppImages.kIcEditTrip,
                                                                        ),
                                                                      // Show "Invite" option for trip owner
                                                                      if (GlobalVariables.isLoggedInUser(
                                                                        controller.tripModel.value?.createdBy ??
                                                                            '',
                                                                      ))
                                                                        MoreVertDialogueWidget(
                                                                          title:
                                                                              'Invite',
                                                                          onTap: () {
                                                                            Get.back();
                                                                            controller.inviteToTrip();
                                                                          },
                                                                          iconData:
                                                                              LucideIcons.userPlus,
                                                                        ),
                                                                      // Show "Join Trip" option for non-owners who haven't joined
                                                                      if (!GlobalVariables.isLoggedInUser(
                                                                            controller.tripModel.value?.createdBy ??
                                                                                '',
                                                                          ) &&
                                                                          !(controller.tripModel.value?.joinedUsers?.contains(
                                                                                GlobalVariables.loggedInUser.value?.uid,
                                                                              ) ??
                                                                              false))
                                                                        MoreVertDialogueWidget(
                                                                          title:
                                                                              'Join Trip',
                                                                          onTap: () {
                                                                            Get.back();
                                                                            controller.joinTrip();
                                                                          },
                                                                          iconData:
                                                                              LucideIcons.plus,
                                                                        ),
                                                                      MoreVertDialogueWidget(
                                                                        imagePath:
                                                                            AppImages.kIcShareTrip,
                                                                        title:
                                                                            'Share Trip',
                                                                        onTap: () async {
                                                                          Get.back();
                                                                          await Share.share(
                                                                            'Check out this trip I found on Travel Crew!',
                                                                            subject:
                                                                                'Travel Crew Trip',
                                                                          );
                                                                        },
                                                                      ),
                                                                      if (GlobalVariables.isLoggedInUser(
                                                                        controller.tripModel.value?.createdBy ??
                                                                            '',
                                                                      ))
                                                                        MoreVertDialogueWidget(
                                                                          title:
                                                                              'Remove',
                                                                          onTap: () {
                                                                            Get.back();
                                                                            showDialog(
                                                                              context:
                                                                                  context,
                                                                              builder:
                                                                                  (
                                                                                    c,
                                                                                  ) => AlertDialog(
                                                                                    title: const Text(
                                                                                      'Are you sure you want to delete this trip?',
                                                                                    ),
                                                                                    content: const Text(
                                                                                      'This action cannot be undone.',
                                                                                    ),
                                                                                    actions: [
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          Get.back();
                                                                                        },
                                                                                        child: const Text(
                                                                                          'Cancel',
                                                                                        ),
                                                                                      ),
                                                                                      TextButton(
                                                                                        onPressed: () {
                                                                                          controller.removeTrip();
                                                                                          Get.back();
                                                                                        },
                                                                                        child: const Text(
                                                                                          'Delete',
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                            );
                                                                          },
                                                                          iconData:
                                                                              LucideIcons.trash2,
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  );
                                                },
                                                child: BlurryContainer(
                                                  padding: EdgeInsets.all(
                                                    10.sp,
                                                  ),
                                                  blur: 7,
                                                  height: 51.14.h,
                                                  width: 51.14.w,
                                                  color: Colors.black
                                                      .withValues(alpha: .15),
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  child: const Icon(
                                                    Icons.more_vert,
                                                    color:
                                                        AppColors.kWhiteColor,
                                                    size: 25,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10.w),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 15.h,
                                          ),
                                          child: PageIndicator(
                                            currentIndex: index,
                                            totalIndexes:
                                                Get.arguments is TripModel
                                                    ? Get
                                                            .arguments
                                                            .images
                                                            .length
                                                        as int
                                                    : 3,
                                            height: 24,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  controller.tripModel.value?.title ?? '',
                                  style: AppStyles.labelTextStyle()
                                      .copyWith()
                                      .copyWith(
                                        color: const Color(0xFF0F0F0F),
                                        fontSize: 22,

                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    Image.asset(
                                      AppImages.kPinLocation,
                                      scale: 4,
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      controller.tripModel.value?.country ?? '',
                                      style: AppStyles.labelTextStyle()
                                          .copyWith(
                                            color: const Color(0xFF1D7FC2),
                                            fontSize: 15,

                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'Description',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: const Color(0xFF0F0F0F),
                                    fontSize: AppStyles.fontSize17,

                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  controller.tripModel.value?.tripLocation ??
                                      '',
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: const Color(0xFF77818D),
                                    fontSize: 15,

                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFFFAFAFA),
                                    shape: RoundedRectangleBorder(
                                      side: const BorderSide(
                                        width: 0.20,
                                        color: Color(0xFFD2D5D9),
                                      ),
                                      borderRadius: BorderRadius.circular(19),
                                    ),
                                    shadows: const [
                                      BoxShadow(
                                        color: Color(0x0A4580C4),
                                        blurRadius: 20,
                                        offset: Offset(2, 12),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Trip Start',
                                            style: AppStyles.labelTextStyle()
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF0F0F0F,
                                                  ),
                                                  fontSize:
                                                      AppStyles.fontSize17,

                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          SizedBox(height: 20.h),
                                          Row(
                                            children: [
                                              Image.asset(
                                                AppImages.kCalendarIcon,
                                                scale: 4,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                DateFormat(
                                                  'EEEE, dd MMM',
                                                ).format(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.tripStartDate ??
                                                      DateTime.now(),
                                                ),
                                                style:
                                                    AppStyles.labelTextStyle()
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFFA4ABB3,
                                                          ),
                                                          fontSize:
                                                              AppStyles
                                                                  .fontSize13,

                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20.h),
                                          Row(
                                            children: [
                                              Image.asset(
                                                AppImages.kClockIcon,
                                                scale: 4,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.tripStartDate ??
                                                      DateTime.now(),
                                                ),
                                                style:
                                                    AppStyles.labelTextStyle()
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFFA4ABB3,
                                                          ),
                                                          fontSize:
                                                              AppStyles
                                                                  .fontSize13,

                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 20.w),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Trip End',
                                            style: AppStyles.labelTextStyle()
                                                .copyWith(
                                                  color: const Color(
                                                    0xFF0F0F0F,
                                                  ),
                                                  fontSize:
                                                      AppStyles.fontSize17,

                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),
                                          SizedBox(height: 20.h),
                                          Row(
                                            children: [
                                              Image.asset(
                                                AppImages.kCalendarIcon,
                                                scale: 4,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                DateFormat(
                                                  'EEEE, dd MMM',
                                                ).format(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.tripEndDate ??
                                                      DateTime.now(),
                                                ),
                                                style:
                                                    AppStyles.labelTextStyle()
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFFA4ABB3,
                                                          ),
                                                          fontSize:
                                                              AppStyles
                                                                  .fontSize13,

                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20.h),
                                          Row(
                                            children: [
                                              Image.asset(
                                                AppImages.kClockIcon,
                                                scale: 4,
                                              ),
                                              SizedBox(width: 10.w),
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                  controller
                                                          .tripModel
                                                          .value
                                                          ?.tripEndDate ??
                                                      DateTime.now(),
                                                ),
                                                style:
                                                    AppStyles.labelTextStyle()
                                                        .copyWith(
                                                          color: const Color(
                                                            0xFFA4ABB3,
                                                          ),
                                                          fontSize:
                                                              AppStyles
                                                                  .fontSize13,

                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Row(
                                  children: [
                                    Text(
                                      controller
                                              .tripModel
                                              .value
                                              ?.joinedUsers
                                              ?.length
                                              .toString() ??
                                          '0',
                                      style: AppStyles.labelTextStyle()
                                          .copyWith(
                                            color: const Color(0xFF0F0F0F),
                                            fontSize: AppStyles.fontSize22,

                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    SizedBox(width: 5.w),
                                    Text(
                                      'People are Going',
                                      style: AppStyles.labelTextStyle()
                                          .copyWith(
                                            color: const Color(0xFF0F0F0F),
                                            fontSize: 13,

                                            fontWeight: FontWeight.w500,
                                            height: 1.40,
                                            letterSpacing: -0.01,
                                          ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Obx(
                                  () =>
                                      controller
                                                  .tripModel
                                                  .value
                                                  ?.joindUsersList
                                                  ?.isEmpty ??
                                              true
                                          ? const Center(
                                            child: Text(
                                              'No one has joined yet',
                                            ),
                                          )
                                          : ListView.separated(
                                            padding: EdgeInsets.zero,
                                            shrinkWrap: true,
                                            separatorBuilder:
                                                (context, index) =>
                                                    SizedBox(height: 10.h),
                                            itemCount:
                                                controller
                                                    .tripModel
                                                    .value
                                                    ?.joindUsersList
                                                    ?.length ??
                                                0,
                                            itemBuilder: (context, index) {
                                              return Row(
                                                children: [
                                                  AnyImageView(
                                                    ontap: () {
                                                      // Get.toNamed(kProfileScreenRoute);
                                                    },
                                                    url:
                                                        controller
                                                            .tripModel
                                                            .value
                                                            ?.joindUsersList?[index]
                                                            .profileImage ??
                                                        '',
                                                    width: 50.w,
                                                    padding: EdgeInsets.zero,
                                                    height: 50.h,
                                                    isCircle: true,
                                                  ),
                                                  // Image.network(
                                                  //   controller
                                                  //           .tripModel
                                                  //           .value
                                                  //           ?.joindUsersList?[index]
                                                  //           .profileImage ??
                                                  //       '',
                                                  //   scale: 4,
                                                  // ),
                                                  SizedBox(width: 10.w),
                                                  Expanded(
                                                    child: Text(
                                                      controller
                                                              .tripModel
                                                              .value
                                                              ?.joindUsersList?[index]
                                                              .displayName ??
                                                          '',
                                                      style: AppStyles.labelTextStyle()
                                                          .copyWith(
                                                            color: const Color(
                                                              0xFF1F1F1F,
                                                            ),
                                                            fontSize:
                                                                AppStyles
                                                                    .fontSize13,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                ),
                                SizedBox(height: 30.h),
                                // Container(
                                //   padding: const EdgeInsets.symmetric(
                                //     horizontal: 19.09,
                                //     vertical: 9.55,
                                //   ),
                                //   decoration: ShapeDecoration(
                                //     color: const Color(0x0C19A7EC),
                                //     shape: RoundedRectangleBorder(
                                //       side: BorderSide(
                                //         width: 0.80,
                                //         color: const Color(0xFF19A7EC),
                                //       ),
                                //       borderRadius: BorderRadius.circular(35),
                                //     ),
                                //   ),
                                //   child: Row(
                                //     mainAxisSize: MainAxisSize.min,
                                //     mainAxisAlignment: MainAxisAlignment.center,
                                //     crossAxisAlignment: CrossAxisAlignment.center,
                                //     children: [
                                //       Icon(Icons.add, size: 20),
                                //       Text(
                                //         'Invite Friends',
                                //         style: AppStyles.labelTextStyle().copyWith(
                                //           color: Colors.black,
                                //           fontSize: 12.73,

                                //           fontWeight: FontWeight.w500,
                                //           height: 1.25,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                // SizedBox(height: 20.h),
                                // Text(
                                //   'Trip Privacy',
                                //   style: AppStyles.labelTextStyle().copyWith(
                                //     color: Colors.black,
                                //     fontSize: AppStyles.fontSize20,

                                //     fontWeight: FontWeight.w600,
                                //   ),
                                // ),
                                // SizedBox(height: 10.h),
                                // Row(
                                //   children: [
                                //     SizedBox(
                                //       width: Get.width * 0.65,
                                //       child: Text(
                                //         'Choose who can see and join your trip. Keep it private for invited members or make it public for everyone to explore!',
                                //         style: AppStyles.labelTextStyle().copyWith(
                                //           color: Colors.grey,
                                //           fontSize: AppStyles.fontSize13,

                                //           fontWeight: FontWeight.w400,
                                //         ),
                                //       ),
                                //     ),
                                //     SizedBox(width: 10.w),
                                //     CustomLockToggle(isLocked: controller.isLocked),
                                //     SizedBox(height: 20.h),
                                //   ],
                                // ),
                                // SizedBox(height: 20.h),
                                Obx(
                                  () => SizedBox(
                                    width: Get.width,
                                    child: CustomTripTabs(
                                      tabs: controller.tripTabs,
                                      selectedIndex:
                                          controller.selectedTabIndex.value,
                                      onTabChanged: controller.changeTab,
                                      selectedTabColor: Colors.blue.withValues(
                                        alpha: 0.1,
                                      ),
                                      unselectedTextColor: Colors.black87,
                                      height: 45,
                                      tabSpacing: 12,
                                      padding: const EdgeInsets.only(right: 1),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Obx(() {
                                  switch (controller.selectedTabIndex.value) {
                                    case 0:
                                      return TransportTab(
                                        controller: controller,
                                      );
                                    case 1:
                                      return ExpenseTab(controller: controller);
                                    case 2:
                                      return LodgingTab(controller: controller);
                                    case 3:
                                      return ActivitiesTab(
                                        controller: controller,
                                      );
                                    default:
                                      return TransportTab(
                                        controller: controller,
                                      );
                                  }
                                }),
                                SizedBox(height: 70.h),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10.h,
                      left: 18.w,
                      right: 18.w,
                      child: CustomElevatedButton(
                        width: Get.width,
                        height: Get.height * 0.06,
                        title:
                            controller.tripModel.value?.joinedUsers?.any(
                                      (element) =>
                                          element ==
                                          GlobalVariables
                                              .loggedInUser
                                              .value!
                                              .uid,
                                    ) ??
                                    false
                                ? 'Open Chat'
                                : 'Send Message',
                        onPressed: () async {
                          late UsersController usersController;
                          if (!Get.isRegistered<UsersController>()) {
                            usersController = Get.put(UsersController());
                          } else {
                            usersController = Get.find<UsersController>();
                          }
                          usersController.currentTrip.value =
                              Get.arguments is TripModel
                                  ? Get.arguments as TripModel
                                  : Get.arguments['trip'] as TripModel;

                          usersController.listenToChat();

                          await Get.toNamed(kMessagesScreenRoute);
                          if (usersController.roomListner != null) {
                            await usersController.roomListner!.cancel();
                            usersController.roomListner = null;
                          }
                        },
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class MoreVertDialogueWidget extends StatelessWidget {
  const MoreVertDialogueWidget({
    super.key,
    required this.title,
    this.iconData,
    this.imagePath,
    this.onTap,
  });
  final String title;
  final String? imagePath;
  final Function()? onTap;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          title == 'Remove'
              ? BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.kRedColor),
                color: AppColors.kRedColor.withValues(alpha: .1),
              )
              : null,
      padding: EdgeInsets.all(8.sp),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 11.13.w,
          children: [
            iconData != null
                ? Icon(
                  iconData,
                  color: AppColors.kWhiteColor,
                  size: AppStyles.fontSize24,
                )
                : AnyImageView(
                  width: 22.26.w,
                  height: 22.26.h,
                  url: imagePath ?? '',
                  fileType: SourceType.asset,
                ),
            Expanded(
              child: Text(
                title,
                style: AppStyles.labelTextStyle().copyWith(
                  color: Colors.white,
                  fontSize: 16.70.sp,
                  fontWeight: FontWeight.w600,
                  height: 1.33.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
