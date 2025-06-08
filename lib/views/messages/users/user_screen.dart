import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/views/messages/users/widget/users_widget.dart';

import '../../../utils/app_styles.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/users_controller.dart';

class UsersScreen extends GetView<UsersController> {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<UsersController>()) {
      Get.put(UsersController());
    }
    // Future.microtask(() {
    //   controller.getChatRooms();
    // });
    return CustomScaffold(
      screenName: 'Messages',
      scaffoldKey: controller.scaffoldKey,
      centerTitle: true,
      isBackIcon: true,
      className: runtimeType.toString(),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          TextField(
            onChanged: (value) {
              // your logic here
            },
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF333333),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 15,
                left: 10,
                right: 17,
                bottom: 12,
              ),
              hintText: 'Search',
              hintStyle: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF9C9FA3),
                fontSize: 13.44,

                fontWeight: FontWeight.w400,
                height: 1.40,
                letterSpacing: -0.01,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(42.4),
                borderSide: const BorderSide(
                  width: 0.52,
                  color: Color(0xFFD2D5D9),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(42.4),
                borderSide: const BorderSide(
                  width: 0.52,
                  color: Color(0xFFD2D5D9),
                ),
              ),
              isDense: true,
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 10, right: 6),
                child: Icon(Icons.search, size: 20, color: Colors.grey),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 30,
                minHeight: 20,
              ),
            ),
          ),
          SizedBox(height: 10.h),

          Expanded(
            child: Obx(
              () =>
                  controller.isLoading.isTrue
                      ? Center(child: CircularProgressIndicator())
                      : controller.chatRooms.isEmpty
                      ? Center(child: Text('No chats found.'))
                      : ListView.separated(
                        itemCount: controller.chatRooms.length,
                        shrinkWrap: true,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == 9 ? 120.h : 0,
                            ),
                            child: UsersWidget(
                              imageUrl:
                                  controller
                                      .chatRooms[index]
                                      .trip
                                      ?.images
                                      .first ??
                                  '',
                              tripModel: controller.chatRooms[index].trip!,
                              title:
                                  controller.chatRooms[index].trip?.title ?? '',
                              subtitle:
                                  '${DateFormat('dd MMM').format(controller.chatRooms[index].trip?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(controller.chatRooms[index].trip?.tripEndDate ?? DateTime.now())}',
                              unreadCount: 0,
                              timestamp: DateFormat('dd MMM, hh:mma').format(
                                controller.chatRooms[index].chats.last.createdAt
                                    .toDate(),
                              ),
                              memberImages:
                                  controller.chatRooms[index].users
                                      .map((e) => e.profileImage)
                                      .toList(),
                              extraMembers: 4,
                            ),
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
