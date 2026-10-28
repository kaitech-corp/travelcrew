import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:travel_crew/l10n/app_localizations.dart';
import 'package:travel_crew/views/messages/users/widget/users_widget.dart';
import 'package:travel_crew/views/messages/users/widget/chat_room_load_error.dart';

import '../../../utils/app_styles.dart';
import '../../custom_widgets/custom_scaffold.dart';
import 'controller/users_controller.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final UsersController controller =
      Get.isRegistered<UsersController>()
          ? Get.find<UsersController>()
          : Get.put(UsersController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return CustomScaffold(
      screenName: l10n.messages,
      scaffoldKey: _scaffoldKey,
      centerTitle: true,
      className: widget.runtimeType.toString(),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          TextField(
            controller: controller.messagesSearchController,
            onChanged: (value) => controller.messagesSearch.value = value,
            style: AppStyles.labelTextStyle().copyWith(
              fontSize: AppStyles.fontSize14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF333333),
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.only(
                top: 15,
                left: 10,
                right: 17,
                bottom: 12,
              ),
              hintText: l10n.search,
              hintStyle: AppStyles.labelTextStyle().copyWith(
                color: const Color(0xFF9C9FA3),
                fontSize: AppStyles.fontSize13,

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
            child: Obx(() {
              final error = controller.chatRoomsError.value;
              final rooms = controller.visibleChatRooms(
                controller.messagesSearch.value,
              );
              if (controller.isLoadingChats.isTrue &&
                  controller.chatRooms.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.chatRooms.isEmpty) {
                return error == null
                    ? Center(child: Text(l10n.noChatsFound))
                    : Center(
                      child: ChatRoomLoadError(
                        message: error,
                        onRetry: controller.loadChatRooms,
                      ),
                    );
              }
              if (rooms.isEmpty) {
                return Column(
                  children: [
                    if (error != null)
                      ChatRoomLoadError(
                        message: error,
                        onRetry: controller.loadChatRooms,
                      ),
                    Expanded(child: Center(child: Text(l10n.noChatsFound))),
                  ],
                );
              }
              return Column(
                children: [
                  if (error != null)
                    ChatRoomLoadError(
                      message: error,
                      onRetry: controller.loadChatRooms,
                    ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: rooms.length,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final trip = rooms[index].trip;
                        if (trip == null || trip.tripStatus == 'deleted') {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == 9 ? 120.h : 0,
                          ),
                          child: UsersWidget(
                            imageUrl:
                                rooms[index].trip?.images.firstOrNull ?? '',
                            tripModel: trip,
                            title: rooms[index].trip?.title ?? '',
                            subtitle:
                                '${DateFormat('dd MMM').format(rooms[index].trip?.tripStartDate ?? DateTime.now())} - ${DateFormat('dd MMM').format(rooms[index].trip?.tripEndDate ?? DateTime.now())}',
                            timestamp: DateFormat(
                              'dd MMM, hh:mma',
                            ).format(rooms[index].updatedAt.toDate()),
                            memberImages:
                                rooms[index].users
                                    .map((e) => e.profileImage)
                                    .toList(),
                            extraMembers: 4,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
