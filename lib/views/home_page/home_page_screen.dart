import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/home_page/controller/home_page_controller.dart';
import 'package:travel_crew/views/home_page/widgets/location_widget.dart';
import 'package:travel_crew/views/home_page/widgets/trips_widget.dart';
import '../../services/session_services.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_styles.dart';
import '../custom_widgets/custom_scaffold.dart';
import 'widgets/filter_trips_widget.dart';

class HomePageScreen extends GetView<HomePageController> {
  const HomePageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      leadingWidth: Get.width,
      padding: EdgeInsets.zero,
      leadingWidget: Padding(
        padding: EdgeInsets.only(right: 20.w, left: 5.w),
        child: Row(
          children: [
            Obx(
              () => AnyImageView(
                ontap: () {
                  Get.toNamed(kProfileScreenRoute);
                },
                url: GlobalVariables.loggedInUser.value?.profileImage ?? '',
                width: 50.w,
                padding: EdgeInsets.zero,
                height: 50.h,
                isCircle: true,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Get.toNamed(kNotificationScreenRoute);
              },
              child: Image.asset(AppImages.kNotificationIcon, scale: 4),
            ),
          ],
        ),
      ),
      scaffoldKey: controller.scaffoldKey,
      className: runtimeType.toString(),
      body: Padding(
        padding: EdgeInsets.only(left: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  Container(
                    width: Get.width * 0.75,
                    height: 43,
                    padding: const EdgeInsets.only(
                      top: 12,
                      left: 10,
                      right: 17,
                      bottom: 12,
                    ),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                          width: 0.52,
                          color: Color(0xFFD2D5D9),
                        ),
                        borderRadius: BorderRadius.circular(42.4),
                      ),
                    ),
                    child: TextFormField(
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (value) {
                        controller.applyMyTripsFilter(value);
                        controller.applyOtherTripsFilter(value);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        hintStyle: AppStyles.labelTextStyle().copyWith(
                          fontSize: 13.44,
                          fontWeight: FontWeight.w400,
                          height: 1.40,
                          color: const Color(0xFF9C9FA3),
                          letterSpacing: -0.01,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        prefixIconConstraints: BoxConstraints(maxWidth: 30.w),
                        prefixIcon: const ImageIcon(
                          AssetImage(AppImages.kSearchIcon),
                          color: AppColors.kGreyColor,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: AppStyles.labelTextStyle().copyWith(fontSize: 14),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      // showGeneralDialog(
                      //   context: context,
                      //   pageBuilder: (_, d, c) {
                      //     return Dialog(
                      //       backgroundColor: AppColors.kGreyColor,
                      //       child: FilterTripsWidget(),
                      //     );
                      //   },
                      // );
                      await showModalBottomSheet(
                        backgroundColor: AppColors.kGreyColor,
                        isScrollControlled: true,
                        context: context,
                        builder: (_) {
                          return FilterTripsWidget(
                            onPriceRangeChanged: (
                              minimum,
                              maximum,
                              continents,
                            ) {
                              Get.back();
                              controller.getFilterdTrips(
                                minimum: minimum,
                                maximum: maximum,
                                continents: continents,
                              );
                            },
                          );
                        },
                      );
                    },
                    child: Container(
                      width: 43.41.w,
                      height: 43.41.h,
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF4F4F4),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(AppImages.kFilterIcon, scale: 3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.h, bottom: 1.h, right: 20.h),
              child: Row(
                children: [
                  Text(
                    l10n.myTrips,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF121212),
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      mainViewController?.selectedIndex.value = -1;
                      // Get.toNamed(kMyTripsScreenRoute);
                    },
                    child: Text(
                      l10n.viewAll,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFF121212),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 150.h,
              child: Obx(
                () =>
                    controller.isLoadingMyTrips.isTrue
                        ? const Center(child: CircularProgressIndicator())
                        : controller.filteredMyTrips.isEmpty
                        ? Center(child: Text(l10n.noTripsFound))
                        : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder:
                              (c, index) => TripsWidget(
                                tripModel: controller.filteredMyTrips[index],
                                onTap: () {
                                  Get.toNamed(
                                    kSpecificTripViewScreenRoute,
                                    arguments:
                                        controller.filteredMyTrips[index],
                                  );
                                },
                                images:
                                    controller.filteredMyTrips[index].images,
                                daysToGo:
                                    (controller
                                                .filteredMyTrips[index]
                                                .tripStartDate
                                                ?.isAfter(DateTime.now()) ??
                                            false)
                                        ? controller
                                                .filteredMyTrips[index]
                                                .tripStartDate
                                                ?.difference(DateTime.now())
                                                .inDays ??
                                            0
                                        : 0,
                                destination:
                                    controller
                                        .filteredMyTrips[index]
                                        .destination,
                                country:
                                    controller.filteredMyTrips[index].country,
                                startDate: DateFormat('dd MMM').format(
                                  controller
                                          .filteredMyTrips[index]
                                          .tripStartDate ??
                                      DateTime.now(),
                                ),
                                endDate: DateFormat('dd MMM').format(
                                  controller
                                          .filteredMyTrips[index]
                                          .tripEndDate ??
                                      DateTime.now(),
                                ),
                              ),
                          separatorBuilder: (c, index) => SizedBox(width: 7.w),
                          itemCount: controller.filteredMyTrips.length,
                        ),
              ),
            ),

            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   child: Row(
            //     spacing: 7.w,
            //     children:
            //         trips
            //             .map(
            //               (e) => TripsWidget(
            //                 onTap: () {
            //                   Get.toNamed(
            //                     kSpecificTripViewScreenRoute,
            //                     arguments: e,
            //                   );
            //                 },
            //                 images: e.images,
            //                 daysToGo: e.daysToGo,
            //                 destination: e.destination,
            //                 country: e.country,
            //                 startDate: DateFormat('dd MMM').format(e.startDate),
            //                 endDate: e.endDate,
            //               ),
            //             )
            //             .toList(),
            //   ),
            // ),
            SizedBox(height: 16.h),
            Obx(
              () =>
                  controller.isTabsReady.value
                      ? SizedBox(
                        height: 25.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder:
                              (c, index) => Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    controller.selectedTabIndex.value = index;
                                    controller.tabController.animateTo(index);
                                    if (index == 0) {
                                      controller.getOtherTrips();
                                    } else if (index == 1) {
                                      controller.getPopulatTrips();
                                    } else if (index == 2) {
                                      controller.getByLocation();
                                    } else {
                                      controller.getOtherTrips();
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        controller.tabs[index],
                                        style: AppStyles.labelTextStyle()
                                            .copyWith(
                                              color:
                                                  controller
                                                              .selectedTabIndex
                                                              .value ==
                                                          index
                                                      ? const Color(0xFFF36D72)
                                                      : AppColors.kBlackColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                      if (controller.selectedTabIndex.value ==
                                          index) ...{
                                        Container(
                                          height: 2.h,
                                          width: 20.w,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF36D72),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      },
                                    ],
                                  ),
                                ),
                              ),
                          separatorBuilder: (c, index) => SizedBox(width: 25.w),
                          itemCount: controller.tabs.length,
                        ),
                      )
                      : SizedBox(
                        height: 40.h,
                        child: Center(
                          child: SizedBox(
                            height: 2,
                            width: 100.w,
                            child: const LinearProgressIndicator(),
                          ),
                        ),
                      ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(
                () =>
                    controller.isLoadingOtherTrips.isTrue
                        ? const Center(child: CircularProgressIndicator())
                        : controller.isTabsReady.value
                        ? TabBarView(
                          controller: controller.tabController,
                          children: [
                            _buildTripsTab(
                              l10n.all,
                              controller.otherFilteredTrips,
                            ),
                            _buildTripsTab(
                              l10n.popular,
                              controller.otherFilteredTrips,
                            ),
                            _buildTripsTab(
                              l10n.nearby,
                              controller.otherFilteredTrips,
                            ),
                            _buildTripsTab(
                              l10n.recommended,
                              controller.otherFilteredTrips,
                            ),
                          ],
                        )
                        : const Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripsTab(String tabName, List<TripModel> tripss) {
    return tripss.isEmpty
        ? const Center(child: Text('No trips found.'))
        : ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.only(right: 18.w, bottom: 100.h),
          itemBuilder: (c, index) => LocationWidget(tripModel: tripss[index]),
          separatorBuilder: (c, index) => SizedBox(height: 16.h),
          itemCount: tripss.length,
        );
  }
}
