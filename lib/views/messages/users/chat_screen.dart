import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/utils/logger.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_button.dart';
import 'package:uuid/uuid.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../utils/common_code.dart';
import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/text_widget.dart';
import 'controller/users_controller.dart';
import 'message_widget.dart';

class MessagesScreen extends GetView<UsersController> {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: runtimeType.toString(),
      screenName: '',
      appBarSize: 70.h,
      title: GestureDetector(
        onTap: () {
          Get.toNamed(
            kGroupDetailScreenRoute,
            arguments: controller.currentTrip.value,
          );
        },
        child: Obx(
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppStyles.labelTextStyle().copyWith(
                        color: const Color(0xFF0B0B0B),
                        fontSize: 16,
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
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 10.77,

                            fontWeight: FontWeight.w500,
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
      ),
      padding: EdgeInsets.zero,
      scaffoldKey: controller.scaffoldState,
      body: Container(
        width: context.width,
        height: context.height,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFFF5F4F7),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 10, color: Colors.white),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50.r),
              topRight: Radius.circular(50.r),
              bottomLeft: Radius.circular(25.r),
              bottomRight: Radius.circular(25.r),
            ),
          ),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(47.r),
                topRight: Radius.circular(47.r),
                bottomLeft: Radius.circular(25.r),
                bottomRight: Radius.circular(25.r),
              ),
              child: Obx(
                () {
                  if (controller.isLoadingChats.isTrue &&
                      (controller.chatRoom.value == null ||
                          controller.messages.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.chatRoom.value == null) {
                    return const Center(child: Text('No messages yet.'));
                  }

                  return ListView.separated(
                    controller: controller.scrollController,
                    padding: EdgeInsets.only(top: 50.h),
                    shrinkWrap: true,
                    itemBuilder: (c, index) {
                      if (index == controller.messages.length) {
                        return  controller.isFetchingMore
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox.shrink();
                      }
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == 0 ? 100.h : 0,
                        ),
                        child: MessageWidget(
                          userModel: controller.chatRoom.value!.users.firstWhere(
                            (u) =>
                                u.id ==
                                controller
                                    .messages[index].createdBy,
                          ),
                          message: controller.messages[index],
                        ),
                      );
                    },
                    separatorBuilder: (c, index) => SizedBox(height: 43.h),
                    itemCount: (controller.messages.length) + 1,
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: Opacity(
                  opacity: 0.70,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFA1A5C1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 10.w,
                      children: [
                        TextWidget(
                          labelText: 'December 12, 2022',
                          textAlign: TextAlign.center,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: Colors.white,
                            fontSize: AppStyles.fontSize10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Obx(
                () =>
                    controller.isLoadingChats.isTrue
                        ? const SizedBox.shrink()
                        : controller.currentTrip.value!.createdBy !=
                                GlobalVariables.loggedInUser.value!.uid &&
                            (controller.chatRoom.value == null ||
                                !(controller.currentTrip.value!.joinedUsers
                                        ?.any(
                                          (u) =>
                                              u ==
                                              GlobalVariables
                                                  .loggedInUser
                                                  .value!
                                                  .uid,
                                        ) ??
                                    false))
                        ? CustomTextButton(
                          width: context.width * 0.9,
                          title: 'Join',
                          foregroundColor: AppColors.kWhiteColor,
                          borderColor: AppColors.kPrimaryColor,
                          backgroundColor: AppColors.kPrimaryColor,
                          onPressed: () {
                            controller.joinRoom();
                          },
                        )
                        : Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: AppColors.kWhiteColor,
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Center(
                            child: TextField(
                              onTapOutside:
                                  (event) =>
                                      CommonCode().removeTextFieldFocus(),
                              controller: controller.tecMessage,
                              focusNode: controller.fnMessage,
                              decoration: InputDecoration(
                                hintText: 'Say something',
                                hintStyle: AppStyles.labelTextStyle().copyWith(
                                  color: const Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.36,
                                ),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 7.w),
                                  child: CircleAvatar(
                                    radius: 20.r,
                                    backgroundColor: AppColors.kPrimaryColor,
                                    child: IconButton(
                                      icon: ImageIcon(
                                        AssetImage(AppImages.kSendMesssage),
                                        size: 20,
                                        color: AppColors.kWhiteColor,
                                      ),
                                      onPressed: () {
                                        CommonCode().removeTextFieldFocus();
                                        controller.saveMessage(
                                          chatToSave: ChatMessage(
                                            chateId: const Uuid().v6(),
                                            messageStatus:
                                                MessageStatus.sent.status,
                                            createdAt: Timestamp.now(),
                                            createdBy:
                                                GlobalVariables
                                                    .loggedInUser
                                                    .value!
                                                    .uid,
                                            sentTo:
                                                controller
                                                    .currentTrip
                                                    .value!
                                                    .id,
                                            messageType: MessageType.Text.name,
                                            data: controller.tecMessage.text,
                                          ),
                                        );
                                         AppLogger.debug(
                                          'Message sent: ${controller.tecMessage.text}',
                                        );
                                        controller.tecMessage.clear();
                                       
                                      },
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 15.w,
                                  vertical: 10.h,
                                ),
                                filled: true,
                                fillColor: AppColors.kWhiteColor,
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
