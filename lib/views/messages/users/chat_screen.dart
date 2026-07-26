import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import 'package:travel_crew/services/session_services.dart';
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

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final UsersController controller = Get.find<UsersController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.attachMessageScrollController(_scrollController);
  }

  @override
  void dispose() {
    controller.detachMessageScrollController(_scrollController);
    unawaited(controller.stopListeningToChat());
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      className: widget.runtimeType.toString(),
      screenName: '',
      appBarSize: 78.h,
      title: _ChatHeader(controller: controller),
      padding: EdgeInsets.zero,
      scaffoldKey: _scaffoldKey,
      body: Container(
        width: context.width,
        height: context.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF7FAFD),
              Color(0xFFF8F8F8),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Obx(() {
                  if (controller.isLoadingChats.isTrue &&
                      (controller.chatRoom.value == null ||
                          controller.messages.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.chatRoom.value == null) {
                    return _EmptyChatState(
                      title: 'No chat available yet',
                      subtitle:
                          'Open the trip chat to start coordinating with your group.',
                    );
                  }

                  if (controller.messages.isEmpty) {
                    return _EmptyChatState(
                      title: 'No messages yet',
                      subtitle:
                          'Be the first to share an update, plan, or question.',
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      top: 8.h,
                      bottom: 150.h,
                    ),
                    itemCount: controller.messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == controller.messages.length) {
                        return controller.isFetchingMore
                            ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                            : const SizedBox.shrink();
                      }

                      final message = controller.messages[index];
                      final previousMessage =
                          index > 0 ? controller.messages[index - 1] : null;
                      final showDateSeparator =
                          previousMessage == null ||
                          !_isSameDay(
                            previousMessage.createdAt.toDate(),
                            message.createdAt.toDate(),
                          );

                      final sender = controller.chatRoom.value!.users.firstWhere(
                        (u) => u.id == message.createdBy,
                        orElse:
                            () => ChatUser(
                              id: message.createdBy,
                              unreadedMessages: 0,
                              name: 'Unknown',
                              profileImage: '',
                              isOnline: false,
                              isTyping: false,
                            ),
                      );

                      return Column(
                        children: [
                          if (showDateSeparator)
                            _DateSeparator(date: message.createdAt.toDate()),
                          MessageWidget(userModel: sender, message: message),
                        ],
                      );
                    },
                  );
                }),
              ),
            ),
            Positioned(
              left: 16.w,
              right: 16.w,
              bottom: 12.h,
              child: SafeArea(
                top: false,
                child: Obx(
                  () {
                    final trip = controller.currentTrip.value;
                    final isMember =
                        trip != null &&
                        (trip.createdBy == GlobalVariables.currentUid ||
                            (trip.joinedUsers?.contains(
                                  GlobalVariables.currentUid,
                                ) ??
                                false));

                    if (controller.isLoadingChats.isTrue) {
                      return const SizedBox.shrink();
                    }

                    if (trip == null) {
                      return const SizedBox.shrink();
                    }

                    if (!isMember) {
                      return _JoinPanel(
                        onJoin: controller.joinRoom,
                      );
                    }

                    return _ComposerBar(
                      controller: controller,
                      onSend: () {
                        final text = controller.tecMessage.text.trim();
                        if (text.isEmpty) return;
                        CommonCode().removeTextFieldFocus();
                        controller.saveMessage(
                          chatToSave: ChatMessage(
                            chateId: const Uuid().v6(),
                            messageStatus: MessageStatus.sent.status,
                            createdAt: Timestamp.now(),
                            createdBy: GlobalVariables.loggedInUser.value!.uid,
                            sentTo: controller.currentTrip.value!.id,
                            messageType: MessageType.Text.name,
                            data: text,
                          ),
                        );
                        AppLogger.debug('Message sent: $text');
                        controller.tecMessage.clear();
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.controller});

  final UsersController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final trip = controller.currentTrip.value;
        final memberCount = trip?.joinedUsers?.length ?? 0;
        return Row(
          children: [
            AnyImageView(
              url: trip?.images.first ?? '',
              height: 50.h,
              width: 50.w,
              isCircle: true,
              containerBackgroundColor: AppColors.kGreyColor.withValues(
                alpha: .12,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextWidget(
                          labelText: trip?.title ?? 'Trip Chat',
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: AppColors.kBlackColor,
                            fontSize: AppStyles.fontSize16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.kLightBlueColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Group',
                          style: AppStyles.labelTextStyle().copyWith(
                            color: AppColors.kPrimaryColor,
                            fontSize: AppStyles.fontSize12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Image.asset(
                        AppImages.kCalendarIcon,
                        color: AppColors.kGreyyColor,
                        scale: 7,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: TextWidget(
                          labelText:
                              '${DateFormat('dd MMM').format(controller.currentTrip.value?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(controller.currentTrip.value?.tripEndDate ?? DateTime.now())}',
                          textAlign: TextAlign.start,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppStyles.labelTextStyle().copyWith(
                            color: AppColors.kGreyyColor,
                            fontSize: AppStyles.fontSize13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        '$memberCount members',
                        style: AppStyles.labelTextStyle().copyWith(
                          color: AppColors.kGreyyColor,
                          fontSize: AppStyles.fontSize12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DateSeparator extends StatelessWidget {
  const _DateSeparator({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: AppColors.kWhiteColor,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.kLightGreyColor),
          ),
          child: Text(
            DateFormat('EEEE, d MMM').format(date),
            style: AppStyles.labelTextStyle().copyWith(
              color: AppColors.kGreyyColor,
              fontSize: AppStyles.fontSize12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _JoinPanel extends StatelessWidget {
  const _JoinPanel({required this.onJoin});

  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.kLightGreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.kLightBlueColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.forum_outlined,
              color: AppColors.kPrimaryColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'Join the trip chat',
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: AppStyles.fontSize16,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'You need to join the trip before sending messages.',
            textAlign: TextAlign.center,
            style: AppStyles.labelTextStyle().copyWith(
              color: AppColors.kGreyyColor,
              fontSize: AppStyles.fontSize13,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          SizedBox(height: 14.h),
          CustomTextButton(
            width: double.infinity,
            title: 'Join chat',
            foregroundColor: AppColors.kWhiteColor,
            borderColor: AppColors.kPrimaryColor,
            backgroundColor: AppColors.kPrimaryColor,
            onPressed: onJoin,
          ),
        ],
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.onSend,
  });

  final UsersController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.kWhiteColor,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.kLightGreyColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onTapOutside: (event) => CommonCode().removeTextFieldFocus(),
              controller: controller.tecMessage,
              focusNode: controller.fnMessage,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a message',
                hintStyle: AppStyles.labelTextStyle().copyWith(
                  color: AppColors.kGreyyColor,
                  fontSize: AppStyles.fontSize14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          InkWell(
            onTap: onSend,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.kPrimaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: AppColors.kWhiteColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                color: AppColors.kLightBlueColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: AppColors.kPrimaryColor,
                size: 38,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppStyles.labelTextStyle().copyWith(
                color: AppColors.kGreyyColor,
                fontSize: AppStyles.fontSize14,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
