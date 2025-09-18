import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/home_page/widgets/trips_widget.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

import '../../utils/app_styles.dart';
import '../../utils/common_code.dart';
import '../custom_widgets/custom_scaffold.dart';

class MyTripsScreen extends GetView<MyTripsController> {
  const MyTripsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    Future.microtask(() {
      controller.getTrips();
    });
    return CustomScaffold(
      onWillPop: () {
        mainViewController?.selectedIndex.value = 0;
      },
      screenName: l10n.myTrips,
      scaffoldKey: controller.scaffoldKey,
      centerTitle: true,
      className: runtimeType.toString(),
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Obx(
              () => Row(
                children: [
                  GestureDetector(
                    onTap: () => controller.changeTab(0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 19.09,
                        vertical: 9.55,
                      ),
                      decoration: ShapeDecoration(
                        color:
                            controller.selectedTabIndex.value == 0
                                ? const Color(0x0C19A7EC)
                                : const Color(0xFFF1F1F1),
                        shape: RoundedRectangleBorder(
                          side:
                              controller.selectedTabIndex.value == 0
                                  ? const BorderSide(
                                    width: 0.80,
                                    color: Color(0xFF19A7EC),
                                  )
                                  : BorderSide.none,
                          borderRadius: BorderRadius.circular(35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            l10n.upcoming,
                            style: AppStyles.labelTextStyle().copyWith(
                              color: Colors.black,
                              fontSize: AppStyles.fontSize12,

                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  GestureDetector(
                    onTap: () => controller.changeTab(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 19.09,
                        vertical: 9.55,
                      ),
                      decoration: ShapeDecoration(
                        color:
                            controller.selectedTabIndex.value == 1
                                ? const Color(0x0C19A7EC)
                                : const Color(0xFFF1F1F1),
                        shape: RoundedRectangleBorder(
                          side:
                              controller.selectedTabIndex.value == 1
                                  ? const BorderSide(
                                    width: 0.80,
                                    color: Color(0xFF19A7EC),
                                  )
                                  : BorderSide.none,
                          borderRadius: BorderRadius.circular(54.09),
                        ),
                      ),
                      child: Row(
                        children: [
                          Opacity(
                            opacity: 0.80,
                            child: Text(
                              l10n.complete,
                              style: AppStyles.labelTextStyle().copyWith(
                                color: Colors.black,
                                fontSize: 12.73,

                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // SizedBox(height: 20.h),
            Obx(
              () =>
                  controller.selectedTabIndex.value == 1
                      ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20.h),
                          TextFormField(
                            textCapitalization: TextCapitalization.sentences,
                            onTapUpOutside:
                                (event) => CommonCode().removeTextFieldFocus(),
                            onChanged: (v) {
                              controller.applyFilter();
                            },

                            focusNode: FocusNode(),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                                borderSide: BorderSide.none,
                              ),
                              // suffixIcon: widget.suffixIcon,
                              // fillColor:
                              //     widget.controller.showDropdown.isTrue
                              //         ? AppColors.kPrimaryColor.withValues(
                              //           alpha: .1,
                              //         )
                              //         : AppColors.kLightGreyColor,
                              filled: true,
                              fillColor: AppColors.kLightGreyColor,
                              hintStyle: AppStyles.labelTextStyle().copyWith(
                                fontSize: AppStyles.fontSize16,
                                color: Colors.grey[600],
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              prefixIconConstraints: BoxConstraints(
                                maxWidth: 60.w,
                              ),
                              suffixIcon: Image.asset(
                                AppImages.kFilterIcon,
                                scale: 5,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.r),
                                borderSide: const BorderSide(
                                  color: AppColors.kPrimaryColor,
                                ),
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 7.w),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 20.r,
                                  child: Icon(
                                    Icons.search,
                                    color: AppColors.kBlackColor,
                                    size: AppStyles.fontSize24,
                                  ),
                                ),
                              ),
                              hintText: l10n.cityCountryZone,
                            ),
                            controller: controller.searchController,
                          ),
                        ],
                      )
                      : const SizedBox.shrink(),
            ),
            SizedBox(height: 20.h),
            Obx(
              () => SizedBox(
                height:
                    controller.selectedTabIndex.value == 1
                        ? Get.height * 0.6
                        : Get.height * .7,
                child:
                    controller.isLoading.isTrue
                        ? const Center(child: CircularProgressIndicator())
                        : controller.filteredTrips.isEmpty
                        ? Center(child: Text(l10n.noTripsFound))
                        : ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.filteredTrips.length,
                          itemBuilder:
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: TripsWidget(
                                  tripModel: controller.filteredTrips[index],
                                  onTap: () {
                                    Get.toNamed(
                                      kSpecificTripViewScreenRoute,
                                      arguments:
                                          controller.filteredTrips[index],
                                    );
                                  },
                                  images:
                                      controller.filteredTrips[index].images,
                                  daysToGo:
                                      controller.filteredTrips[index].daysToGo,
                                  destination:
                                      controller
                                          .filteredTrips[index]
                                          .destination,
                                  country:
                                      controller.filteredTrips[index].country,
                                  startDate: DateFormat('dd MMM').format(
                                    controller
                                            .filteredTrips[index]
                                            .tripStartDate ??
                                        DateTime.now(),
                                  ),
                                  endDate: DateFormat('dd MMM').format(
                                    controller
                                            .filteredTrips[index]
                                            .tripEndDate ??
                                        DateTime.now(),
                                  ),
                                ),
                              ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
