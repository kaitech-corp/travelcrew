import 'package:travel_crew/services/safety_service.dart';
import 'package:travel_crew/views/safety/safety_actions.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/app_styles.dart';
import 'package:travel_crew/views/custom_widgets/custom_text_button.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_images.dart';
import '../../../../utils/common_code.dart';
import '../../custom_widgets/any_image_view.dart';
import '../../custom_widgets/custom_scaffold.dart';
import '../../custom_widgets/text_widget.dart';
import 'controller/users_controller.dart';
import 'message_widget.dart';
import 'widget/chat_room_load_error.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen>
    with WidgetsBindingObserver {
  final UsersController controller = Get.find<UsersController>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.attachMessageScrollController(_scrollController);
    _scrollController.addListener(controller.markLoadedMessagesRead);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        controller.roomId != null &&
        controller.messages.isNotEmpty &&
        controller.chatRoom.value != null &&
        mounted) {
      controller.markLoadedMessagesRead();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(controller.markLoadedMessagesRead);
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
            colors: [Color(0xFFF7FAFD), Color(0xFFF8F8F8)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.only(top: 10.h),
                child: Obx(() {
                  if (!SafetyService.ready.value) {
                    return const SafetyLoadingView();
                  }
                  final visibleMessages =
                      controller.messages
                          .where(
                            (m) =>
                                !m.moderationRemoved &&
                                !SafetyService.hides(m.createdBy),
                          )
                          .toList();
                  final loadError = controller.chatOpenError.value;
                  final pageError = controller.earlierMessagesError.value;
                  final hasEarlierMessages =
                      controller.hasEarlierMessages.value;
                  final isFetchingMore = controller.isFetchingMore.value;
                  Widget showError(Widget content) => Column(
                    children: [
                      if (loadError != null)
                        ChatRoomLoadError(
                          message: loadError,
                          onRetry: controller.listenToChat,
                        ),
                      Expanded(child: content),
                    ],
                  );
                  if (controller.isOpeningChat.isTrue &&
                      (controller.chatRoom.value == null ||
                          visibleMessages.isEmpty)) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.chatRoom.value == null) {
                    return showError(
                      _EmptyChatState(
                        title: 'No chat available yet',
                        subtitle:
                            'Open the trip chat to start coordinating with your group.',
                      ),
                    );
                  }

                  if (visibleMessages.isEmpty && !hasEarlierMessages) {
                    return showError(
                      _EmptyChatState(
                        title: 'No messages yet',
                        subtitle:
                            'Be the first to share an update, plan, or question.',
                      ),
                    );
                  }

                  return showError(
                    ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.only(top: 8.h, bottom: 150.h),
                      itemCount: visibleMessages.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          if (pageError != null) {
                            return ChatRoomLoadError(
                              message: pageError,
                              onRetry: controller.loadEarlierMessages,
                            );
                          }
                          if (!hasEarlierMessages) {
                            return const SizedBox.shrink();
                          }
                          return Center(
                            child: TextButton(
                              onPressed:
                                  isFetchingMore
                                      ? null
                                      : () async {
                                        final previousMax =
                                            _scrollController.hasClients
                                                ? _scrollController
                                                    .position
                                                    .maxScrollExtent
                                                : 0.0;
                                        final previousOffset =
                                            _scrollController.hasClients
                                                ? _scrollController.offset
                                                : 0.0;
                                        await controller.loadEarlierMessages();
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (!mounted ||
                                                  !_scrollController
                                                      .hasClients) {
                                                return;
                                              }
                                              final position =
                                                  _scrollController.position;
                                              final offset =
                                                  previousOffset +
                                                  position.maxScrollExtent -
                                                  previousMax;
                                              _scrollController.jumpTo(
                                                offset.clamp(
                                                  position.minScrollExtent,
                                                  position.maxScrollExtent,
                                                ),
                                              );
                                            });
                                      },
                              child: Text(
                                isFetchingMore
                                    ? 'Loading earlier messages…'
                                    : 'Load earlier messages',
                              ),
                            ),
                          );
                        }

                        final message = visibleMessages[index - 1];
                        final previousMessage =
                            index > 1 ? visibleMessages[index - 2] : null;
                        final showDateSeparator =
                            previousMessage == null ||
                            !_isSameDay(
                              previousMessage.createdAt.toDate(),
                              message.createdAt.toDate(),
                            );

                        final sender = controller.chatRoom.value!.users
                            .firstWhere(
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
                            MessageWidget(
                              userModel: sender,
                              message: message,
                              roomId: controller.chatRoom.value!.roomId,
                            ),
                          ],
                        );
                      },
                    ),
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
                child: Obx(() {
                  final trip = controller.currentTrip.value;
                  final isMember =
                      trip != null &&
                      (trip.createdBy == GlobalVariables.currentUid ||
                          (trip.joinedUsers?.contains(
                                GlobalVariables.currentUid,
                              ) ??
                              false));

                  if (controller.isOpeningChat.isTrue) {
                    return const SizedBox.shrink();
                  }

                  if (trip == null) {
                    return const SizedBox.shrink();
                  }

                  if (!isMember) {
                    return _JoinPanel(onJoin: controller.joinRoom);
                  }

                  if (controller.chatRoom.value == null) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PendingMessagesPanel(controller: controller),
                      _ComposerBar(
                        controller: controller,
                        onSend: () {
                          CommonCode().removeTextFieldFocus();
                          unawaited(controller.sendDraftMessage());
                        },
                      ),
                    ],
                  );
                }),
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
    return Obx(() {
      final trip = controller.currentTrip.value;
      final memberCount = trip?.joinedUsers?.length ?? 0;
      return Row(
        children: [
          AnyImageView(
            url: trip?.images.firstOrNull ?? '',
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
    });
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
  const _ComposerBar({required this.controller, required this.onSend});

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
              maxLength: 4000,
              focusNode: controller.fnMessage,
              textCapitalization: TextCapitalization.sentences,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write a message',
                counterText: '',
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

class _PendingMessagesPanel extends StatelessWidget {
  const _PendingMessagesPanel({required this.controller});

  final UsersController controller;

  @override
  Widget build(BuildContext context) {
    final pending = controller.pendingMessages;
    final status = controller.pendingChatStatus.value;
    if (pending.isEmpty && status.isEmpty) return const SizedBox.shrink();
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: AppColors.kWhiteColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.kLightGreyColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              pending.isEmpty
                  ? status
                  : '${pending.length} message${pending.length == 1 ? '' : 's'} saved on this device',
              style: AppStyles.labelTextStyle().copyWith(
                fontSize: AppStyles.fontSize13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (pending.isNotEmpty) ...[
              if (status.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(status),
                ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 120.h),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: pending.length,
                  itemBuilder:
                      (context, index) => Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          pending[index].text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed:
                      controller.isRecoveringPending.value
                          ? null
                          : () => unawaited(controller.retryPendingMessages()),
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    controller.isRecoveringPending.value
                        ? 'Retrying…'
                        : 'Retry saved messages',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyChatState extends StatelessWidget {
  const _EmptyChatState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    // Scroll instead of overflowing when large text or a load error above
    // leaves less vertical room than the illustration and copy need.
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
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
