import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/utils/app_strings.dart';

import '../../../../utils/app_styles.dart';
import '../../../home_page/widgets/trips_widget.dart';
import '../controller/users_controller.dart';

class UsersWidget extends StatelessWidget {
  const UsersWidget({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.tripModel,
    required this.subtitle,
    this.unreadCount = 0,
    required this.timestamp,
    required this.memberImages,
    this.extraMembers = 0,
  });
  final String imageUrl;
  final String title;
  final String subtitle;
  final int unreadCount;
  final String timestamp;
  final TripModel tripModel;
  final List<String> memberImages;
  final int extraMembers;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        late UsersController usersController;
        if (!Get.isRegistered<UsersController>()) {
          usersController = Get.put(UsersController());
        } else {
          usersController = Get.find<UsersController>();
        }
        usersController.currentTrip.value = tripModel;

        usersController.listenToChat();

        await Get.toNamed(kMessagesScreenRoute);
        await usersController.stopListeningToChat();
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.w),
        child: Row(
          spacing: 12.w,
          children: [
            CircleAvatar(radius: 25.r, backgroundImage: NetworkImage(imageUrl)),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: title,
                            style: AppStyles.labelTextStyle().copyWith(
                              fontSize: AppStyles.fontSize16,
                              fontWeight: FontWeight.bold,
                            ),
                            children: [
                              if (unreadCount > 0)
                                WidgetSpan(
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 3.w),
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFEE4266),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            55.56,
                                          ),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '$unreadCount',
                                          style: AppStyles.labelTextStyle()
                                              .copyWith(
                                                color: Colors.white,
                                                fontSize: AppStyles.fontSize12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      Text(
                        timestamp,
                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: const Color(0xFF6B7280),
                          fontSize: AppStyles.fontSize13,

                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 14,
                            color: Colors.black,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            subtitle,
                            style: AppStyles.labelTextStyle().copyWith(
                              fontSize: AppStyles.fontSize14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      buildMemberAvatars(
                        memberAvatars: memberImages.take(3).toList(),
                        additionalMembers: memberImages.length - 2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
