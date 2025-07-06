import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_colors.dart';
import 'package:travel_crew/utils/app_images.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';

class TripsWidget extends StatelessWidget {
  final String destination;
  final List<String> images;
  final String country;
  final String imageUrl;
  final TripModel? tripModel;
  final String startDate;
  final String endDate;
  final List<String> memberAvatars;
  final int additionalMembers;
  final int daysToGo;
  final VoidCallback? onTap;
  const TripsWidget({
    super.key,
    this.tripModel,
    this.destination = 'Bali',
    required this.images,
    this.country = 'Indonesia',
    this.imageUrl = '',
    this.startDate = '12 May',
    this.endDate = '20 May',
    this.memberAvatars = const [AppImages.kMember1Icon, AppImages.kMember2Icon],
    this.additionalMembers = 4,
    this.daysToGo = 7,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: Get.width * 0.84,
        margin: EdgeInsets.only(left: 3.w, right: 5.w, bottom: 10.h, top: 10),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.91,
              strokeAlign: BorderSide.strokeAlignOutside,
              color: const Color(0xFFE7E7E7),
            ),
            borderRadius: BorderRadius.circular(21.90),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              spreadRadius: 0,
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.r),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [_buildTripImage(), _buildTripDetails()],
          ),
        ),
      ),
    );
  }

  Widget _buildTripImage() {
    return Padding(
      padding: const EdgeInsets.all(7),
      child: AnyImageView(
        url: images.isNotEmpty ? images.first : '',

        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(18.r),
        width: 135.w,
        height: 101.h,
      ),
    );
  }

  Widget _buildTripDetails() {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 18.sp,
                color: Colors.black54,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  country,
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: 11.84,
                    fontWeight: FontWeight.w500,
                    height: 1.29,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  tripModel?.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppStyles.labelTextStyle().copyWith(
                    fontSize: 20.29,
                    fontWeight: FontWeight.w600,
                    height: 1.33,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '|',
                style: AppStyles.labelTextStyle().copyWith(
                  fontSize: 24.sp,
                  color: Colors.black26,
                ),
              ),
              SizedBox(width: 8.w),
              Image.asset(AppImages.kPlaneIcon, scale: 4),
              SizedBox(width: 4.w),
              Text(
                '${daysToGo}d. to go',
                style: AppStyles.labelTextStyle().copyWith(
                  fontSize: 10.99,
                  fontWeight: FontWeight.w500,
                  height: 1.23,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date range
              Row(
                children: [
                  Image.asset(
                    AppImages.kCalendarIcon,
                    scale: 6,
                    color: AppColors.kBlackColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '$startDate - $endDate',
                    style: AppStyles.labelTextStyle().copyWith(
                      fontSize: 9.98,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              buildMemberAvatars(
                memberAvatars:
                    (tripModel?.joindUsersList
                                ?.map((e) => e.urlToImage ?? '')
                                .toList() ??
                            [])
                        .take(4)
                        .toList(),
                additionalMembers: (tripModel?.joindUsersList?.length ?? 0) - 4,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildMemberAvatars({
  required List<String> memberAvatars,
  int additionalMembers = 0,
}) {
  final hasMembers = memberAvatars.isNotEmpty;
  return SizedBox(
    height: 32.h,
    width: 60.w,
    child: Stack(
      alignment: Alignment.centerRight,
      children: [
        if (hasMembers)
          ...List.generate(
            memberAvatars.length > 4 ? 4 : memberAvatars.length,
            (index) => Positioned(
              right: index * 16.w,
              child: AnyImageView(
                height: 22.h,
                width: 22.w,
                isCircle: true,
                url: memberAvatars[index],
                fit: BoxFit.cover,
                fileType:
                    memberAvatars[index].startsWith('http')
                        ? SourceType.network
                        : SourceType.asset,
              ),
            ),
          )
        else if (additionalMembers > 0)
          Positioned(
            right: 0,
            child: Container(
              height: 23.h,
              width: 23.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black87,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$additionalMembers',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: Colors.white,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
