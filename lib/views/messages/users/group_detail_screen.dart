import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_colors.dart' show AppColors;
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';

import '../../../utils/app_images.dart';
import '../../../utils/app_styles.dart';
import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/text_widget.dart';

class GroupDetailScreen extends StatefulWidget {
  const GroupDetailScreen({super.key});

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen> {
  final UsersController controller = Get.find<UsersController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    controller.currentTrip.value = Get.arguments;
    controller.getUsersDetail();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: widget.runtimeType.toString(),
      screenName: '',
      appBarSize: 70.h,
      title: Obx(
        () => Row(
          children: [
            AnyImageView(
              url: controller.currentTrip.value?.images.first ?? '',
              height: 52.h,
              width: 52.w,
              isCircle: true,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    labelText: controller.currentTrip.value?.title ?? '',
                    textAlign: TextAlign.start,
                    style: AppStyles.labelTextStyle().copyWith(
                      color: const Color(0xFF0B0B0B),
                      fontSize: AppStyles.fontSize16,
                      fontWeight: FontWeight.w600,
                      height: 1.82,
                    ),
                  ),
                  Row(
                    children: [
                      Image.asset(
                        AppImages.kCalendarIcon,
                        color: AppColors.kBlackColor,
                        scale: 7,
                      ),
                      TextWidget(
                        labelText:
                            ' ${DateFormat('dd MMM').format(controller.currentTrip.value?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(controller.currentTrip.value?.tripEndDate ?? DateTime.now())}',

                        textAlign: TextAlign.center,
                        style: AppStyles.labelTextStyle().copyWith(
                          color: const Color(0xFF666666),
                          fontSize: AppStyles.fontSize14,

                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      padding: EdgeInsets.zero,
      scaffoldKey: _scaffoldKey,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Members',
                style: AppStyles.labelTextStyle().copyWith(
                  fontSize: AppStyles.fontSize20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: context.height * .68,
              minHeight: context.height * .2,
            ),
            child: Obx(
              () =>
                  controller.isLoadingUsers.isTrue
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: controller.tripUsers.length + 1,
                        itemBuilder: (context, index) {
                          final member =
                              index == 0
                                  ? controller.currentTrip.value!.createdByUser
                                  : controller.tripUsers[index - 1];
                          return member == null
                              ? const SizedBox.shrink()
                              : ListTile(
                                leading: AnyImageView(
                                  url: member.profileImage ?? '',
                                  height: 50.h,
                                  width: 50.w,
                                  isCircle: true,
                                ),
                                title: Text(
                                  member.displayName,
                                  style: AppStyles.labelTextStyle().copyWith(
                                    color: Colors.black,
                                    fontSize: AppStyles.fontSize15,
                                    fontWeight: FontWeight.w700,
                                    height: 1.33,
                                  ),
                                ),
                                // subtitle: Text(
                                //   member.email,
                                //   style: AppStyles.labelTextStyle().copyWith(
                                //     color: Colors.grey,
                                //     fontSize: AppStyles.fontSize10,
                                //     fontWeight: FontWeight.w500,
                                //     height: 1.33,
                                //   ),
                                // ),
                                trailing:
                                    member.uid ==
                                            controller
                                                .currentTrip
                                                .value
                                                ?.createdBy
                                        ? Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade200,
                                            borderRadius: BorderRadius.circular(
                                              20.r,
                                            ),
                                          ),
                                          child: Text(
                                            'Admin',
                                            style: TextStyle(
                                              fontSize: AppStyles.fontSize14,
                                            ),
                                          ),
                                        )
                                        : GlobalVariables
                                                .loggedInUser
                                                .value!
                                                .uid ==
                                            controller
                                                .currentTrip
                                                .value!
                                                .createdBy
                                        ? InkWell(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
                                                    title: const Text(
                                                      'Remove User',
                                                    ),
                                                    content: Text(
                                                      'Are you sure you want to remove from group?',
                                                      style: TextStyle(
                                                        fontSize:
                                                            AppStyles
                                                                .fontSize16,
                                                      ),
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed:
                                                            () => Get.back(),
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          controller.leaveGroup(
                                                            userId: member.uid,
                                                          );
                                                          Get.back();
                                                        },
                                                        child: const Text(
                                                          'Remove',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );
                                          },
                                          child: const Icon(Icons.more_vert),
                                        )
                                        : null,
                              );
                        },
                      ),
            ),
          ),
          if (!GlobalVariables.isLoggedInUser(
                controller.currentTrip.value!.createdBy,
              ) &&
              controller.currentTrip.value!.joinedUsers!.contains(
                GlobalVariables.currentUid,
              ))
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('Leave Group'),
                          content: Text(
                            'Are you sure you want to leave this group?',
                            style: TextStyle(fontSize: AppStyles.fontSize16),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                controller.leaveGroup();
                                Get.back();
                              },
                              child: const Text('Leave'),
                            ),
                          ],
                        ),
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: Text(
                  'Leave Group',
                  style: AppStyles.labelTextStyle().copyWith(
                    color: const Color(0xFFDA2828),
                    fontSize: AppStyles.fontSize13,
                    fontWeight: FontWeight.w600,
                    height: 1.25.h,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 24.w,
                  ),
                  side: const BorderSide(color: Colors.red),
                  backgroundColor: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
