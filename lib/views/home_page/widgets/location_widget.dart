import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

import '../../../utils/app_colors.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/app_styles.dart';

class LocationWidget extends StatelessWidget {
  const LocationWidget({super.key, required this.tripModel});
  final TripModel tripModel;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(kSpecificTripViewScreenRoute, arguments: tripModel);
      },
      child: Stack(
        children: [
          AnyImageView(
            width: Get.width,
            height: Get.height * 0.35,
            borderRadius: BorderRadius.circular(36.39.r),
            url: tripModel.images.lastOrNull ?? '',
          ),
          Positioned(
            bottom: 0,
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(36.39.r),
                bottomRight: Radius.circular(36.39.r),
              ),
              child: BlurryContainer(
                width: context.width * .9,
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 18.w),
                blur: 10,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36.39.r),
                  bottomRight: Radius.circular(36.39.r),
                ),
                color: Colors.black.withValues(alpha: .25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tripModel.title ?? '',
                      style: GoogleFonts.urbanist().copyWith(
                        color: Colors.white,
                        fontSize: AppStyles.fontSize24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 15.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: AppStyles.fontSize20,
                          color: Colors.white,
                        ),
                        // Image.asset(AppImages.kLocationIcon, scale: 4),
                        SizedBox(width: 4.w),
                        Text(
                          tripModel.country,
                          style: GoogleFonts.urbanist().copyWith(
                            color: Colors.white,
                            fontSize: AppStyles.fontSize12,
                            fontWeight: FontWeight.w500,
                            height: 1.29,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: AppStyles.fontSize15,
                              color: Colors.yellow,
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              '4.8',
                              style: AppStyles.labelTextStyle().copyWith(
                                color: Colors.white,
                                fontSize: AppStyles.fontSize12,
                                fontWeight: FontWeight.w500,
                                height: 1.29,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 20.h,
            right: 20.w,
            child: GestureDetector(
              onTap: () async {
                try {
                  final userId = GlobalVariables.loggedInUser.value?.uid;
                  if (userId == null) {
                    showCustomSnackBar(
                      content: 'Please login to favorite trips',
                    );
                    return;
                  }

                  GlobalVariables.addingToFavourites.value = tripModel.id;

                  final isCurrentlyFavorite =
                      GlobalVariables.loggedInUser.value?.favouriteTrips
                          .contains(tripModel.id) ??
                      false;

                  await FirebaseTripService.toggleTripFavorite(
                    tripId: tripModel.id,
                    userId: userId,
                    isFavorite: isCurrentlyFavorite,
                  );

                  GlobalVariables.addingToFavourites.value = '';
                } catch (e) {
                  GlobalVariables.addingToFavourites.value = '';
                }
              },
              child: BlurryContainer(
                padding: EdgeInsets.all(10.sp),
                blur: 7,
                height: 51.14.h,
                width: 51.14.w,
                color: Colors.black.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(50.r),
                child: Obx(
                  () =>
                      GlobalVariables.addingToFavourites.value == tripModel.id
                          ? showLoaderWhenAddingToFavourites()
                          : Icon(
                            GlobalVariables.loggedInUser.value?.favouriteTrips
                                        .contains(tripModel.id) ??
                                    false
                                ? Icons.star_rounded
                                : Icons.star_border,
                            size: 25.sp,
                            color:
                                GlobalVariables
                                            .loggedInUser
                                            .value
                                            ?.favouriteTrips
                                            .contains(tripModel.id) ??
                                        false
                                    ? AppColors.productBgColor
                                    : Colors.white,
                          ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget showLoaderWhenAddingToFavourites({double? height, double? width}) {
  return SizedBox(
    height: height ?? 10.h,
    width: width ?? 10.w,
    child: const Center(
      child: CircularProgressIndicator(
        color: AppColors.productBgColor,
        strokeWidth: 2,
      ),
    ),
  );
}
