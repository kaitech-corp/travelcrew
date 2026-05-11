import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/home_page/widgets/trips_widget.dart';
import 'package:travel_crew/views/my_trips/controller/my_trips_controller.dart';

import '../../utils/app_styles.dart';
import '../../utils/common_code.dart';
import '../custom_widgets/custom_scaffold.dart';

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen> {
  final MyTripsController controller = Get.find<MyTripsController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller.getTrips();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      onWillPop: () {
        mainViewController?.selectedIndex.value = 0;
      },
      screenName: l10n.myTrips,
      scaffoldKey: _scaffoldKey,
      centerTitle: true,
      showNotificationBell: false,
      className: widget.runtimeType.toString(),
      actions: [
        GestureDetector(
          onTap: () => Get.toNamed(kImportTripScreenRoute),
          child: Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: const Icon(
              Icons.auto_awesome_rounded,
              size: 22,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Get.toNamed(kCreateTripScreenRoute),
          child: Padding(
            padding: EdgeInsets.only(right: 15.w),
            child: Image.asset(AppImages.kAddIcon, scale: 5),
          ),
        ),
      ],
      body: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Obx(
              () => Row(
                children: [
                  _buildTab(context, 0, l10n.upcoming),
                  SizedBox(width: 10.w),
                  _buildTab(context, 1, 'Active'),
                  SizedBox(width: 10.w),
                  _buildTab(context, 2, 'Past'),
                ],
              ),
            ),
            Obx(
              () =>
                  controller.selectedTabIndex.value !=
                          -1 // Show search for all tabs if needed, but the original only showed for "Complete"
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
                height: Get.height * 0.65,
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
                                      controller
                                          .filteredTrips[index]
                                          .computedDaysToGo,
                                  tripTimingLabel: _tripTimingLabel(
                                    controller.filteredTrips[index],
                                  ),
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

  String _tripTimingLabel(TripModel trip) {
    final days = trip.computedDaysToGo;
    if (days > 0) {
      return 'in ${days}d.';
    }
    if (days == 0) {
      return 'Today';
    }

    final end = trip.tripEndDate ?? trip.effectiveStartDate;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(end.year, end.month, end.day);

    if (!endDate.isBefore(today)) {
      return 'Active';
    }

    final daysAgo = today.difference(endDate).inDays;
    return '${daysAgo}d. ago';
  }

  Widget _buildTab(BuildContext context, int index, String label) {
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 9.0),
        decoration: ShapeDecoration(
          color:
              controller.selectedTabIndex.value == index
                  ? const Color(0x0C19A7EC)
                  : const Color(0xFFF1F1F1),
          shape: RoundedRectangleBorder(
            side:
                controller.selectedTabIndex.value == index
                    ? const BorderSide(width: 0.80, color: Color(0xFF19A7EC))
                    : BorderSide.none,
            borderRadius: BorderRadius.circular(35),
          ),
        ),
        child: Text(
          label,
          style: AppStyles.labelTextStyle().copyWith(
            color: Colors.black,
            fontSize: AppStyles.fontSize12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
