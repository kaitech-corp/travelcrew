import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/models/trip_discovery_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/home_page/controller/home_page_controller.dart';
import 'package:travel_crew/views/home_page/widgets/location_widget.dart';
import '../../services/session_services.dart';
import '../../utils/app_strings.dart';
import '../../utils/app_styles.dart';
import '../custom_widgets/custom_scaffold.dart';
import 'widgets/filter_trips_widget.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final HomePageController controller = Get.find<HomePageController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: '',
      isBackIcon: false,
      leadingWidth: 80,
      padding: EdgeInsets.zero,
      showNotificationBell: true,
      leadingWidget: Padding(
        padding: EdgeInsets.only(left: 5.w),
        child: Obx(
          () => AnyImageView(
            ontap: () {
              Get.toNamed(kProfileScreenRoute);
            },
            url: GlobalVariables.loggedInUser.value?.profileImage ?? '',
            width: 50.w,
            padding: EdgeInsets.zero,
            height: 50.w,
            isCircle: true,
          ),
        ),
      ),
      scaffoldKey: _scaffoldKey,
      className: widget.runtimeType.toString(),
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
                        controller.applyOtherTripsFilter(value);
                      },
                      decoration: InputDecoration(
                        hintText: l10n.search,
                        hintStyle: AppStyles.labelTextStyle().copyWith(
                          fontSize: AppStyles.fontSize13,
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
                      style: AppStyles.labelTextStyle().copyWith(
                        fontSize: AppStyles.fontSize14,
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
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
                                      controller.getPopularTrips();
                                    } else if (index == 2) {
                                      controller.getByLocation();
                                    } else {
                                      controller.getRecommendedTrips();
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
                                              fontSize: AppStyles.fontSize14,
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
                            _buildTripsTab(l10n.nearby, controller.nearbyTrips),
                            _buildTripsTab(
                              l10n.recommended,
                              controller.recommendedTrips,
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

  Widget _buildTripsTab(String tabName, List<TripDiscoveryModel> tripss) {
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
