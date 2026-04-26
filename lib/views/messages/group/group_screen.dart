import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/views/custom_widgets/any_image_view.dart';
import 'package:travel_crew/views/custom_widgets/text_widget.dart';
import 'package:travel_crew/views/messages/group/controller/group_controller.dart';
import 'package:travel_crew/views/messages/users/controller/users_controller.dart';

import '../../custom_widgets/custom_scaffold.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final GroupController controller = Get.put(GroupController());
    return CustomScaffold(
      screenName: 'Messages',
      isBackIcon: false,
      scaffoldKey: controller.scaffoldKey,
      centerTitle: true,
      className: 'Group',
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.chatRooms.isEmpty) {
          return const Center(child: Text('No chats found.'));
        }
        return ListView.builder(
          itemCount: controller.chatRooms.length,
          itemBuilder: (context, index) {
            final chatRoom = controller.chatRooms[index];
            return ListTile(
              leading: AnyImageView(
                url: chatRoom.trip?.images.first ?? '',
                height: 52.h,
                width: 52.w,
                isCircle: true,
              ),
              title: TextWidget(
                labelText: chatRoom.trip?.title ?? 'No Title',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: TextWidget(
                labelText:
                    '${DateFormat('dd MMM').format(chatRoom.trip?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(chatRoom.trip?.tripEndDate ?? DateTime.now())}',
              ),
              onTap: () {
                Get.put(UsersController());
                Get.find<UsersController>().currentTrip.value = chatRoom.trip;
                Get.toNamed(kMessagesScreenRoute);
              },
            );
          },
        );
      }),
    );
  }
}
