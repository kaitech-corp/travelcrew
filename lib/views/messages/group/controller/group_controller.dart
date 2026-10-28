import 'dart:async';

import 'package:get/get.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/services/chat_firebase_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/utils/logger.dart';

class GroupController extends GetxController {
  GroupController({Future<List<ChatRoom>> Function(String uid)? fetchRooms})
    : _fetchRooms =
          fetchRooms ??
          ((uid) => ChatFirebaseService.getChatRoomsByUserId(userId: uid));

  final Future<List<ChatRoom>> Function(String) _fetchRooms;
  Worker? _sessionWorker;
  String _accountUid = '';
  int _loadVersion = 0;
  RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  RxBool isLoading = false.obs;
  RxnString loadError = RxnString();

  @override
  void onInit() {
    super.onInit();
    _accountUid = GlobalVariables.currentUid;
    _sessionWorker = ever(GlobalVariables.loggedInUser, (_) {
      final uid = GlobalVariables.currentUid;
      if (uid == _accountUid) return;
      _accountUid = uid;
      _loadVersion++;
      chatRooms.clear();
      loadError.value = null;
      isLoading.value = false;
      if (uid.isNotEmpty) unawaited(getChatRooms());
    });
    unawaited(getChatRooms());
  }

  Future<void> getChatRooms() async {
    final uid = GlobalVariables.currentUid;
    final version = ++_loadVersion;
    try {
      if (uid.isEmpty) {
        chatRooms.clear();
        loadError.value = null;
        isLoading.value = false;
        return;
      }
      isLoading.value = true;
      final res = await _fetchRooms(uid);
      if (version != _loadVersion || uid != GlobalVariables.currentUid) return;
      chatRooms.value = res.where((element) => element.trip != null).toList();
      loadError.value = null;
    } catch (e) {
      AppLogger.warning('Unable to load group chats: ${e.runtimeType}');
      if (version == _loadVersion && uid == GlobalVariables.currentUid) {
        loadError.value =
            'Unable to load trip chats. Check your connection and retry.';
      }
    } finally {
      if (version == _loadVersion) isLoading.value = false;
    }
  }

  @override
  void onClose() {
    _loadVersion++;
    _sessionWorker?.dispose();
    super.onClose();
  }
}
