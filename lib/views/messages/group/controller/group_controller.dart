import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/services/chat_firebase_service.dart';
import 'package:travel_crew/services/session_services.dart';

class GroupController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    getChatRooms();
    super.onInit();
  }

  Future<void> getChatRooms() async {
    try {
      isLoading.value = true;
      final res = await ChatFirebaseService.getChatRoomsByUserId(
        userId: GlobalVariables.loggedInUser.value!.uid,
      );
      chatRooms.value = res.where((element) => element.trip != null).toList();
    } catch (e) {
      // Handle error
    }
    isLoading.value = false;
  }
}