import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/Notifications/user_notification_model.dart';
import 'package:travel_crew/models/chat_module/ChatMessage.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/models/user_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/notifications/notfication_services.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';

import '../../../../models/chat_module/ChatUser.dart';
import '../../../../services/chat_firebase_service.dart';
import '../../../../services/notifications/NotificationsFirebaseService.dart';

class UsersController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> groupDetailKey = GlobalKey<ScaffoldState>();
  Rxn<TripModel?> currentTrip = Rxn<TripModel>(null);
  RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  RxBool isLoadingChats = false.obs;
  String? roomId;
  Rxn<ChatRoom> chatRoom = Rxn<ChatRoom>();
  Rxn<Map<String, dynamic>> aiModel = Rxn<Map<String, dynamic>>(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? roomListner;

  RxBool isLoading = false.obs;
  RxList<UserModel> tripUsers = <UserModel>[].obs;
  RxBool isLoadingUsers = false.obs;
  getUsersDetail() async {
    try {
      tripUsers.value = [];
      if (currentTrip.value == null ||
          (currentTrip.value!.joinedUsers?.toList() ?? []).isEmpty) {
        return;
      }

      isLoadingUsers.value = true;

      var res = await AuthService.getTripUsers(
        userIds: currentTrip.value!.joinedUsers?.toList() ?? [],
      );

      tripUsers.value = res;
    } catch (e) {
      print(e);
    }
    isLoadingUsers.value = false;
  }

  getChatRooms() async {
    try {
      isLoading.value = true;
      var res = await ChatFirebaseService.getChatRoomsByUserId(
        userId: GlobalVariables.loggedInUser.value!.id,
      );
      chatRooms.value = res.where((element) => element.trip != null).toList();
    } catch (e) {}
    isLoading.value = false;
  }

  listenToChat() async {
    try {
      roomListner = null;
      isLoadingChats.value = true;
      roomId = null;
      chatRoom.value = null;
      roomId = currentTrip.value!.id;
      var res = await ChatFirebaseService.checkIfRoomExists(
        roomId: roomId ?? '',
      );
      chatRoom.value = res;
      bool result = true;
      if (res == null) {
        result = await createChatRoom();
      }
      listenToCollection(roomId: roomId!);
    } catch (e) {
      print(e);
    }

    isLoadingChats.value = false;
  }

  joinRoom() async {
    try {
      GlobalVariables.showLoader.value = true;
      chatRoom.value!.users.add(
        ChatUser(
          id: GlobalVariables.loggedInUser.value!.id,
          unreadedMessages: 0,
          lastActive: Timestamp.now(),
          name: GlobalVariables.loggedInUser.value!.userName ?? '',
          profileImage: GlobalVariables.loggedInUser.value!.profileImage ?? '',
          isOnline: true,
          isTyping: false,
        ),
      );
      chatRoom.value!.usersIds.add(GlobalVariables.loggedInUser.value!.id);
      currentTrip.value?.joinedUsers?.add(
        GlobalVariables.loggedInUser.value!.id,
      );
      if (currentTrip.value != null) updateTripOverAll(currentTrip.value!);
      chatRoom.refresh();
      FirebaseNotificationsService.saveNotifications(
        message:
            '${GlobalVariables.loggedInUser.value!.userName} joined your trip.',
        title: 'Trip Joined',
        sentTo: [currentTrip.value!.createdBy],
        notificationForId: currentTrip.value!.id,
        notificationType: NotificationType.trip.status,
      );
      sendPushMessageToTopic(
        title: 'Trip Joined',
        body:
            '${GlobalVariables.loggedInUser.value!.userName} joined your trip.',
        topic: currentTrip.value!.createdBy,
      );
      await ChatFirebaseService.updateChatRoom(
        roomId: roomId!,
        chatToSave: chatRoom.value!,
      );
    } catch (e) {
      print(e);
    }
    GlobalVariables.showLoader.value = false;
  }

  listenToCollection({required String roomId}) async {
    try {
      if (roomListner == null) {
        var res = FirebaseFirestore.instance
            .collection(kTripChatCollection)
            .doc(roomId);
        // chatRoom.value = ChatRoom.fromMap(res.);
        roomListner = res.snapshots().listen((event) {
          if (event.exists) {
            chatRoom.value = ChatRoom.fromMap(event.data()!);
          }
        });
      }
    } catch (e) {}
  }

  // fn to create a new room to handle chats
  Future<bool> createChatRoom() async {
    try {
      // GlobalVariables.showLoader.value = true;

      chatRoom.value = ChatRoom(
        usersIds: [GlobalVariables.loggedInUser.value!.id],
        updatedAt: Timestamp.now(),
        roomId: roomId!,
        users: [
          ChatUser(
            id: GlobalVariables.loggedInUser.value!.id,
            unreadedMessages: 0,
            lastActive: Timestamp.now(),
            name: GlobalVariables.loggedInUser.value!.userName ?? '',
            profileImage:
                GlobalVariables.loggedInUser.value!.profileImage ?? '',
            isOnline: true,
            isTyping: false,
          ),
        ],
        chats: [],
      );

      await ChatFirebaseService.createChatRoom(chatroom: chatRoom.value!);
      return true;
    } catch (e) {}
    return false;
  }

  saveMessage({required ChatMessage chatToSave}) async {
    try {
      chatRoom.value!.chats.add(chatToSave);
      chatRoom.refresh();
      scrollToEnd();
      ChatFirebaseService.sendMessage(chatToSave: chatToSave, roomId: roomId!);
    } catch (e) {
      print(e);
    }
  }

  TextEditingController tecMessage = TextEditingController();

  FocusNode fnMessage = FocusNode();

  final List<Map<String, String>> members = const [
    {
      "name": "Rosa Rovorosa",
      "email": "Rosita_Melano@example.com",
      "image": "https://i.pravatar.cc/150?img=1",
      "isAdmin": "true",
    },
    {
      "name": "Elias Marlow",
      "email": "Rosita_Melano@example.com",
      "image": "https://i.pravatar.cc/150?img=2",
    },
    {
      "name": "Elias Marlow",
      "email": "Rosita_Melano@example.com",
      "image": "https://i.pravatar.cc/150?img=3",
    },
    {
      "name": "Elias Marlow",
      "email": "Rosita_Melano@example.com",
      "image": "https://i.pravatar.cc/150?img=4",
    },
    {
      "name": "Elias Marlow",
      "email": "Rosita_Melano@example.com",
      "image": "https://i.pravatar.cc/150?img=5",
    },
  ];

  RxBool showTextField = false.obs;
  scrollToEnd() async {
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  ScrollController scrollController = ScrollController();

  leaveGroup({String? userId}) async {
    try {
      if (currentTrip.value == null) {
        return;
      }
      GlobalVariables.showLoader.value = true;
      await FirebaseTripService.leaveGroup(
        groupId: currentTrip.value!.id,
        userId: userId ?? GlobalVariables.loggedInUser.value!.id,
      ).then((v) {
        GlobalVariables.showLoader.value = F;
        if (v) {
          showCustomSnackBar(
            content:
                userId != null
                    ? 'Removed successfully!'
                    : 'You have left the group',
          );
          currentTrip.value?.joinedUsers?.remove(
            userId ?? GlobalVariables.loggedInUser.value!.id,
          );
          if (currentTrip.value != null) updateTripOverAll(currentTrip.value!);
          if (userId == null) {
            mainViewController?.selectedIndex.value = 0;
            Get.offAllNamed(kMainViewScreenRoute);
          } else {
            (currentTrip.value?.joinedUsers ?? []).remove(userId);
            currentTrip.refresh();
          }
        }
      });
    } catch (e) {}
    GlobalVariables.showLoader.value = false;
  }
}
