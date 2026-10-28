import 'package:travel_crew/services/notifications/chat_activity_service.dart';
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/pending_chat_message_store.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/error_handler.dart';
import 'package:travel_crew/utils/logger.dart';
import 'package:uuid/uuid.dart';

import '../../../../services/chat_firebase_service.dart';

class UsersController extends GetxController {
  UsersController({Future<List<ChatRoom>> Function(String uid)? fetchRooms})
    : _fetchRooms =
          fetchRooms ??
          ((uid) => ChatFirebaseService.getChatRoomsByUserId(userId: uid));

  final Future<List<ChatRoom>> Function(String) _fetchRooms;
  Worker? _roomSessionWorker;
  String _roomAccountUid = '';
  int _roomLoadVersion = 0;
  int _chatOpenVersion = 0;
  final RxnString chatRoomsError = RxnString();
  final RxnString chatOpenError = RxnString();
  final RxnString earlierMessagesError = RxnString();
  final RxString messagesSearch = ''.obs;
  final RxString inboxSearch = ''.obs;
  final TextEditingController messagesSearchController =
      TextEditingController();
  final TextEditingController inboxSearchController = TextEditingController();

  List<ChatRoom> visibleChatRooms(String search) {
    final query = search.trim().toLowerCase();
    return chatRooms.where((room) {
      final trip = room.trip;
      return trip != null &&
          trip.tripStatus != 'deleted' &&
          (query.isEmpty ||
              (trip.title?.toLowerCase().contains(query) ?? false) ||
              trip.destination.toLowerCase().contains(query));
    }).toList();
  }

  static final PendingChatMessageStore _pendingChatStore =
      PendingChatMessageStore();
  Rxn<TripModel?> currentTrip = Rxn<TripModel>();
  RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  RxBool isLoadingChats = false.obs;
  RxBool isOpeningChat = false.obs;
  String? roomId;
  Rxn<ChatRoom> chatRoom = Rxn<ChatRoom>();
  Rxn<Map<String, dynamic>> aiModel = Rxn<Map<String, dynamic>>();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? roomListner;
  DocumentSnapshot<Map<String, dynamic>>? lastVisible;
  final RxBool isFetchingMore = false.obs;
  final RxBool hasEarlierMessages = false.obs;
  final Map<String, ChatMessage> _loadedMessages = {};
  Timestamp? _lastObservedMessageAt;
  Timestamp? _lastReadRequestAt;
  ChatMessage? _retryMessage;
  bool _sendingDraft = false;
  final RxList<PendingChatMessage> pendingMessages = <PendingChatMessage>[].obs;
  final RxString pendingChatStatus = ''.obs;
  final RxBool isRecoveringPending = false.obs;

  RxBool isLoading = false.obs;
  RxList<PublicUserModel> tripUsers = <PublicUserModel>[].obs;
  RxBool isLoadingUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    _roomAccountUid = GlobalVariables.currentUid;
    _roomSessionWorker = ever(GlobalVariables.loggedInUser, (_) {
      final nextUid = GlobalVariables.currentUid;
      if (nextUid == _roomAccountUid) return;
      _roomAccountUid = nextUid;
      _roomLoadVersion++;
      _chatOpenVersion++;
      isLoadingChats.value = false;
      isOpeningChat.value = false;
      chatRooms.clear();
      messagesSearch.value = '';
      inboxSearch.value = '';
      messagesSearchController.clear();
      inboxSearchController.clear();
      chatRoomsError.value = null;
      chatOpenError.value = null;
      earlierMessagesError.value = null;
      currentTrip.value = null;
      chatRoom.value = null;
      roomId = null;
      tripUsers.clear();
      isLoadingUsers.value = false;
      messages.clear();
      _loadedMessages.clear();
      _lastObservedMessageAt = null;
      _lastReadRequestAt = null;
      pendingMessages.clear();
      _retryMessage = null;
      pendingChatStatus.value = '';
      tecMessage.clear();
      unawaited(_cleanupListeners());
      if (nextUid.isNotEmpty) unawaited(loadChatRooms());
    });
    unawaited(loadChatRooms());
  }

  Future<void> getUsersDetail() async {
    final uid = GlobalVariables.currentUid;
    final trip = currentTrip.value;
    final version = _chatOpenVersion;
    try {
      tripUsers.value = [];
      if (trip == null || (trip.joinedUsers?.toList() ?? []).isEmpty) {
        AppLogger.info('No trip or joined users found for getUsersDetail');
        return;
      }

      isLoadingUsers.value = true;
      AppLogger.debug(
        'Getting user details for ${trip.joinedUsers?.length} users',
      );

      final res = await AuthService.getTripUsers(
        userIds: trip.joinedUsers?.toList() ?? [],
      );

      if (isClosed ||
          uid != GlobalVariables.currentUid ||
          trip.id != currentTrip.value?.id ||
          version != _chatOpenVersion) {
        return;
      }
      tripUsers.value = res;
      AppLogger.info('Successfully loaded ${res.length} trip users');
    } catch (error, stackTrace) {
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'getUsersDetail',
      );
    } finally {
      if (!isClosed && version == _chatOpenVersion) {
        isLoadingUsers.value = false;
      }
    }
  }

  /// Load chat rooms for the current user
  Future<void> loadChatRooms() async {
    final uid = GlobalVariables.currentUid;
    final version = ++_roomLoadVersion;
    try {
      if (uid.isEmpty) {
        chatRooms.clear();
        chatRoomsError.value = null;
        isLoadingChats.value = false;
        return;
      }

      isLoadingChats.value = true;
      AppLogger.debug('Loading chat rooms for user: $uid');

      final rooms = await _fetchRooms(uid);
      if (version != _roomLoadVersion || uid != GlobalVariables.currentUid) {
        return;
      }

      chatRooms.value = rooms;
      chatRoomsError.value = null;
      AppLogger.info('Successfully loaded ${rooms.length} chat rooms');
    } catch (error, stackTrace) {
      if (version == _roomLoadVersion && uid == GlobalVariables.currentUid) {
        chatRoomsError.value =
            'Unable to load trip chats. Check your connection and retry.';
      }
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'loadChatRooms',
      );
    } finally {
      if (version == _roomLoadVersion) isLoadingChats.value = false;
    }
  }

  Future<void> listenToChat() async {
    final uid = GlobalVariables.currentUid;
    final destination = currentTrip.value?.id;
    final version = ++_chatOpenVersion;
    bool current() =>
        !isClosed &&
        uid.isNotEmpty &&
        uid == GlobalVariables.currentUid &&
        destination != null &&
        roomId == destination &&
        currentTrip.value?.id == destination &&
        version == _chatOpenVersion;
    try {
      // Clean up existing listeners to prevent memory leaks
      await _cleanupListeners();
      if (version != _chatOpenVersion || uid != GlobalVariables.currentUid) {
        return;
      }

      isOpeningChat.value = true;
      chatOpenError.value = null;
      earlierMessagesError.value = null;
      final sameRoom = roomId == destination;
      roomId = destination;
      if (!sameRoom) {
        messages.clear();
        _loadedMessages.clear();
        _lastObservedMessageAt = null;
        _lastReadRequestAt = null;
        lastVisible = null;
        hasEarlierMessages.value = false;
        chatRoom.value = null;
      }
      isFetchingMore.value = false;
      pendingMessages.clear();
      pendingChatStatus.value = '';

      if (roomId == null) {
        AppLogger.warning('Cannot listen to chat: roomId is null');
        chatOpenError.value = 'This trip chat is unavailable.';
        return;
      }

      await _restorePendingDraft(roomId!);
      if (!current()) return;

      AppLogger.debug('Starting to listen to chat room: $roomId');

      final res = await ChatFirebaseService.checkIfRoomExists(roomId: roomId!);
      if (!current()) return;
      chatRoom.value = res;

      if (res == null) {
        AppLogger.info('Chat room does not exist, creating new room');
        final bool created = await createChatRoom();
        if (!current()) return;
        if (!created) {
          AppLogger.error('Failed to create chat room');
          chatOpenError.value =
              'Unable to open trip chat. Retry when connected.';
          return;
        }
      } else {
        chatRoom.value = res;
        await _ensureCurrentUserInChatRoom();
        if (!current()) return;
      }

      listenToMessages(roomId!);
      listenToCollection(roomId: roomId!);
      unawaited(_recoverPendingMessages(roomId!));
      AppLogger.info('Successfully started listening to chat room: $roomId');
    } catch (error, stackTrace) {
      if (current()) {
        final denied =
            error is FirebaseException && error.code == 'permission-denied';
        if (denied) {
          _clearOpenChatContent();
        }
        chatOpenError.value =
            denied
                ? 'Trip chat is no longer available. Retry to check access.'
                : 'Unable to open trip chat. Retry when connected.';
      }
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'listenToChat',
      );
    } finally {
      if (version == _chatOpenVersion) isOpeningChat.value = false;
    }
  }

  /// Clean up existing listeners to prevent memory leaks
  Future<void> _cleanupListeners() async {
    final room = roomListner;
    final messages = messageListener;
    roomListner = null;
    messageListener = null;
    await Future.wait([
      if (room != null) room.cancel(),
      if (messages != null) messages.cancel(),
    ]);
    AppLogger.debug('Cleaned up existing chat listeners');
  }

  Future<void> stopListeningToChat() async {
    _chatOpenVersion++;
    _lastObservedMessageAt = null;
    _lastReadRequestAt = null;
    await _cleanupListeners();
  }

  void _clearOpenChatContent() {
    _loadedMessages.clear();
    _lastObservedMessageAt = null;
    _lastReadRequestAt = null;
    messages.clear();
    lastVisible = null;
    hasEarlierMessages.value = false;
    chatRoom.value = null;
  }

  void markLoadedMessagesRead() {
    final destination = roomId;
    final observed = _lastObservedMessageAt;
    if (destination == null || observed == null || chatRoom.value == null) {
      return;
    }
    final scroll = _messageScrollController;
    if (scroll != null &&
        scroll.hasClients &&
        scroll.position.maxScrollExtent - scroll.position.pixels >= 160) {
      return;
    }
    if (_lastReadRequestAt != null &&
        observed.compareTo(_lastReadRequestAt!) <= 0) {
      return;
    }
    _lastReadRequestAt = observed;
    final uid = GlobalVariables.currentUid;
    final version = _chatOpenVersion;
    unawaited(
      ChatActivityService.markRead(destination, observed).then((saved) {
        if (!saved &&
            !isClosed &&
            uid == GlobalVariables.currentUid &&
            roomId == destination &&
            version == _chatOpenVersion &&
            _lastReadRequestAt == observed) {
          _lastReadRequestAt = null;
        }
      }),
    );
  }

  Future<void> joinRoom() async {
    try {
      if (chatRoom.value == null || roomId == null) {
        AppLogger.warning('Cannot join room: chatRoom or roomId is null');
        return;
      }

      GlobalVariables.showLoader.value = true;
      AppLogger.info('User joining room: $roomId');

      final currentUser = GlobalVariables.loggedInUser.value;
      if (currentUser == null) {
        AppLogger.error('Cannot join room: user not logged in');
        return;
      }

      final trip = currentTrip.value;
      if (trip == null) {
        AppLogger.error('Cannot join room: trip not found');
        return;
      }

      final isUserAlreadyInTrip =
          trip.createdBy == currentUser.uid ||
          (trip.joinedUsers?.contains(currentUser.uid) ?? false);
      if (!isUserAlreadyInTrip) {
        showCustomSnackBar(content: 'Request to join before opening chat');
        return;
      }

      if (chatRoom.value!.containsUser(currentUser.uid) &&
          isUserAlreadyInTrip) {
        AppLogger.info(
          'User ${currentUser.uid} is already in the chatroom: $roomId',
        );
        showCustomSnackBar(content: 'You are already in this chat room');
        return;
      }

      final destination = roomId!;
      final uid = currentUser.uid;
      final version = _chatOpenVersion;
      final joined = await ChatFirebaseService.ensureChatRoom(
        roomId: destination,
      );
      if (uid != GlobalVariables.currentUid ||
          roomId != destination ||
          version != _chatOpenVersion) {
        return;
      }
      chatRoom.value = joined;
      if (currentTrip.value != null) updateTripOverAll(currentTrip.value!);

      AppLogger.info('Successfully joined room: $roomId');
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'joinRoom',
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }

  Future<void> listenToCollection({required String roomId}) async {
    try {
      if (roomListner == null) {
        final uid = GlobalVariables.currentUid;
        AppLogger.debug('Setting up room listener for: $roomId');
        final res = firestore.collection(kTripChatCollection).doc(roomId);

        roomListner = res.snapshots().listen(
          (event) {
            if (isClosed ||
                this.roomId != roomId ||
                uid != GlobalVariables.currentUid) {
              return;
            }
            try {
              if (event.exists && event.data() != null) {
                chatRoom.value = ChatRoom.fromMap(event.data()!);
                AppLogger.debug('Updated chat room data from listener');
              }
            } catch (error, stackTrace) {
              chatOpenError.value =
                  'Trip chat details could not be displayed. Retry to reload.';
              ErrorHandler.handleError(
                error,
                stackTrace: stackTrace,
                context: 'listenToCollection - data parsing',
              );
            }
          },
          onError: (error) {
            if (isClosed ||
                this.roomId != roomId ||
                uid != GlobalVariables.currentUid) {
              return;
            }
            final denied =
                error is FirebaseException && error.code == 'permission-denied';
            if (denied) {
              _clearOpenChatContent();
            }
            chatOpenError.value =
                denied
                    ? 'Trip chat is no longer available. Retry to check access.'
                    : 'Trip chat stopped updating. Retry to reconnect.';
            ErrorHandler.handleFirebaseError(
              error as Object,
              operation: 'listenToCollection - stream',
            );
          },
        );
      }
    } catch (error, stackTrace) {
      if (!isClosed && this.roomId == roomId) {
        chatOpenError.value = 'Unable to watch trip chat. Retry.';
      }
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'listenToCollection',
      );
    }
  }

  // fn to create a new room to handle chats
  Future<bool> createChatRoom() async {
    try {
      if (roomId == null) {
        AppLogger.error('Cannot create chat room: roomId is null');
        return false;
      }

      final currentUser = GlobalVariables.loggedInUser.value;
      if (currentUser == null) {
        AppLogger.error('Cannot create chat room: user not logged in');
        return false;
      }

      AppLogger.info('Creating new chat room: $roomId');

      final destination = roomId!;
      final version = _chatOpenVersion;
      final created = await ChatFirebaseService.ensureChatRoom(
        roomId: destination,
      );
      if (currentUser.uid != GlobalVariables.currentUid ||
          roomId != destination ||
          version != _chatOpenVersion) {
        return false;
      }
      chatRoom.value = created;
      AppLogger.info('Successfully created chat room: $roomId');
      return true;
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'createChatRoom',
      );
      return false;
    }
  }

  Future<void> sendDraftMessage() async {
    if (_sendingDraft) return;
    final draft = tecMessage.text.trim();
    final uid = GlobalVariables.currentUid;
    final destination = roomId;
    if (draft.isEmpty || uid.isEmpty || destination == null) return;
    final pending = _retryMessage;
    final message =
        pending != null &&
                pending.data == draft &&
                pending.createdBy == uid &&
                pending.sentTo == destination
            ? pending
            : ChatMessage(
              chateId: const Uuid().v6(),
              messageStatus: MessageStatus.sent.status,
              createdAt: Timestamp.now(),
              createdBy: uid,
              sentTo: destination,
              messageType: MessageType.Text.name,
              data: draft,
            );
    _retryMessage = message;
    _sendingDraft = true;
    try {
      await _pendingChatStore.enqueue(
        PendingChatMessage(
          ownerId: uid,
          roomId: destination,
          messageId: message.chateId,
          text: message.data,
          createdAtMillis: message.createdAt.millisecondsSinceEpoch,
        ),
      );
      await _refreshPendingMessages(uid, destination);
      if (isClosed ||
          roomId != destination ||
          GlobalVariables.currentUid != uid) {
        return;
      }
      tecMessage.clear();
      if (await saveMessage(chatToSave: message)) {
        await _pendingChatStore.remove(uid, destination, message.chateId);
        _retryMessage = null;
        await _refreshPendingMessages(uid, destination);
      } else if (!isClosed) {
        pendingChatStatus.value =
            'Message saved on this device. Retry when connected.';
      }
    } catch (error, stackTrace) {
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'sendDraftMessage checkpoint',
      );
      if (!isClosed &&
          roomId == destination &&
          GlobalVariables.currentUid == uid) {
        pendingChatStatus.value =
            'Unable to save or sync the message. Check your connection and retry.';
      }
    } finally {
      _sendingDraft = false;
    }
  }

  ChatMessage _chatMessageFromPending(PendingChatMessage pending) =>
      ChatMessage(
        chateId: pending.messageId,
        messageStatus: MessageStatus.sent.status,
        createdAt: Timestamp.fromMillisecondsSinceEpoch(
          pending.createdAtMillis,
        ),
        createdBy: pending.ownerId,
        sentTo: pending.roomId,
        messageType: MessageType.Text.name,
        data: pending.text,
      );

  Future<void> _refreshPendingMessages(String uid, String destination) async {
    final pending = await _pendingChatStore.load(uid, destination);
    if (!isClosed &&
        roomId == destination &&
        GlobalVariables.currentUid == uid) {
      pendingMessages.assignAll(pending);
      if (pending.isEmpty) pendingChatStatus.value = '';
    }
  }

  Future<void> retryPendingMessages() async {
    final destination = roomId;
    if (destination != null) await _recoverPendingMessages(destination);
  }

  Future<void> _restorePendingDraft(String destination) async {
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty) return;
    try {
      final pending = await _pendingChatStore.load(uid, destination);
      if (isClosed ||
          roomId != destination ||
          GlobalVariables.currentUid != uid) {
        return;
      }
      pendingMessages.assignAll(pending);
      if (pending.isEmpty) return;
      _retryMessage = _chatMessageFromPending(pending.first);
      if (tecMessage.text.isEmpty) tecMessage.text = pending.first.text;
    } catch (error, stackTrace) {
      if (!isClosed) {
        pendingChatStatus.value =
            'Saved messages could not be loaded on this device.';
      }
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'restorePendingChatDraft',
      );
    }
  }

  Future<void> _recoverPendingMessages(String destination) async {
    if (_sendingDraft) return;
    final uid = GlobalVariables.currentUid;
    if (uid.isEmpty) return;
    _sendingDraft = true;
    isRecoveringPending.value = true;
    try {
      final pending = await _pendingChatStore.load(uid, destination);
      await _refreshPendingMessages(uid, destination);
      for (final entry in pending) {
        if (isClosed ||
            roomId != destination ||
            GlobalVariables.currentUid != uid) {
          break;
        }
        await ChatFirebaseService.sendMessage(
          roomId: destination,
          chatToSave: _chatMessageFromPending(entry),
        );
        await _pendingChatStore.remove(uid, destination, entry.messageId);
        await _refreshPendingMessages(uid, destination);
        if (_retryMessage?.chateId == entry.messageId) {
          _retryMessage = null;
          if (!isClosed && tecMessage.text == entry.text) tecMessage.clear();
        }
      }
    } catch (error, stackTrace) {
      if (!isClosed &&
          roomId == destination &&
          GlobalVariables.currentUid == uid) {
        pendingChatStatus.value =
            'Some messages are still saved on this device. Retry when connected.';
      }
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'recoverPendingChatMessages',
      );
    } finally {
      _sendingDraft = false;
      if (!isClosed) isRecoveringPending.value = false;
    }
  }

  Future<bool> saveMessage({required ChatMessage chatToSave}) async {
    var addedOptimistic = false;
    try {
      if (roomId == null) {
        AppLogger.error('Cannot save message: roomId is null');
        return false;
      }

      AppLogger.debug('Saving message in room: $roomId');

      if (chatRoom.value == null ||
          !chatRoom.value!.usersIds.contains(GlobalVariables.currentUid)) {
        await _ensureCurrentUserInChatRoom();
      }
      if (chatToSave.createdBy != GlobalVariables.currentUid ||
          chatToSave.sentTo != roomId) {
        return false;
      }

      // Add message to local list for immediate UI update
      if (!messages.any((message) => message.chateId == chatToSave.chateId)) {
        messages.add(chatToSave);
        addedOptimistic = true;
      }
      scrollToEnd();

      // Send message to Firebase
      await ChatFirebaseService.sendMessage(
        chatToSave: chatToSave,
        roomId: roomId!,
      );

      AppLogger.info('Successfully saved message to room: $roomId');
      return true;
    } catch (error, stackTrace) {
      // Remove message from local list if sending failed
      if (addedOptimistic) {
        messages.removeWhere((msg) => msg.chateId == chatToSave.chateId);
      }
      if (!isClosed &&
          chatToSave.createdBy == GlobalVariables.currentUid &&
          chatToSave.sentTo == roomId &&
          tecMessage.text.isEmpty) {
        tecMessage.text = chatToSave.data;
      }

      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'saveMessage',
      );
      return false;
    }
  }

  Future<void> _ensureCurrentUserInChatRoom() async {
    if (roomId == null) return;
    final destination = roomId!;
    final uid = GlobalVariables.currentUid;
    final version = _chatOpenVersion;
    final current = await ChatFirebaseService.ensureChatRoom(
      roomId: destination,
    );
    if (uid == GlobalVariables.currentUid &&
        roomId == destination &&
        version == _chatOpenVersion) {
      chatRoom.value = current;
    }
  }

  TextEditingController tecMessage = TextEditingController();

  FocusNode fnMessage = FocusNode();

  RxBool showTextField = false.obs;
  Future<void> scrollToEnd() async {
    final controller = _messageScrollController;
    if (controller == null || !controller.hasClients) return;
    await controller.animateTo(
      controller.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  ScrollController? _messageScrollController;
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? messageListener;

  void attachMessageScrollController(ScrollController scrollController) {
    _messageScrollController = scrollController;
  }

  void detachMessageScrollController(ScrollController scrollController) {
    if (_messageScrollController == scrollController) {
      _messageScrollController = null;
    }
  }

  @override
  void onClose() {
    _roomLoadVersion++;
    _chatOpenVersion++;
    _roomSessionWorker?.dispose();
    messagesSearchController.dispose();
    inboxSearchController.dispose();
    roomListner?.cancel();
    messageListener?.cancel();
    tecMessage.dispose();
    fnMessage.dispose();
    super.onClose();
  }

  void listenToMessages(String roomId) {
    try {
      AppLogger.debug('Setting up message listener for room: $roomId');
      final uid = GlobalVariables.currentUid;
      final version = _chatOpenVersion;

      messageListener = firestore
          .collection(kTripChatCollection)
          .doc(roomId)
          .collection(kTripChatMessagesCollection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .listen(
            (event) {
              if (isClosed ||
                  this.roomId != roomId ||
                  uid != GlobalVariables.currentUid ||
                  version != _chatOpenVersion) {
                return;
              }
              try {
                final controller = _messageScrollController;
                final wasNearEnd =
                    controller == null ||
                    !controller.hasClients ||
                    controller.position.maxScrollExtent -
                            controller.position.pixels <
                        160;
                for (final doc in event.docs) {
                  _loadedMessages[doc.id] = ChatMessage.fromMap(doc.data());
                  if (!doc.metadata.hasPendingWrites) {
                    final createdAt = doc.data()['createdAt'];
                    if (createdAt is Timestamp &&
                        (_lastObservedMessageAt == null ||
                            createdAt.compareTo(_lastObservedMessageAt!) > 0)) {
                      _lastObservedMessageAt = createdAt;
                    }
                  }
                }
                lastVisible ??= event.docs.lastOrNull;
                if (event.docs.length < 50 && _loadedMessages.length <= 50) {
                  hasEarlierMessages.value = false;
                } else if (_loadedMessages.length <= 50) {
                  hasEarlierMessages.value = true;
                }
                _publishLoadedMessages();
                if (Get.currentRoute == kMessagesScreenRoute &&
                    WidgetsBinding.instance.lifecycleState ==
                        AppLifecycleState.resumed) {
                  markLoadedMessagesRead();
                }
                if (wasNearEnd) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!isClosed &&
                        this.roomId == roomId &&
                        uid == GlobalVariables.currentUid &&
                        version == _chatOpenVersion) {
                      scrollToEnd();
                    }
                  });
                }
                AppLogger.debug(
                  'Updated ${event.docs.length} recent messages from listener',
                );
              } catch (error, stackTrace) {
                chatOpenError.value =
                    'Some messages could not be displayed. Retry to reload.';
                ErrorHandler.handleError(
                  error,
                  stackTrace: stackTrace,
                  context: 'listenToMessages - data parsing',
                );
              }
            },
            onError: (error) {
              if (!isClosed &&
                  this.roomId == roomId &&
                  uid == GlobalVariables.currentUid &&
                  version == _chatOpenVersion) {
                final denied =
                    error is FirebaseException &&
                    error.code == 'permission-denied';
                if (denied) {
                  _clearOpenChatContent();
                }
                chatOpenError.value =
                    denied
                        ? 'Trip chat is no longer available. Retry to check access.'
                        : 'Trip chat stopped updating. Retry to reconnect.';
              }
              ErrorHandler.handleFirebaseError(
                error as Object,
                operation: 'listenToMessages - stream',
              );
            },
          );
    } catch (error, stackTrace) {
      if (!isClosed && this.roomId == roomId) {
        chatOpenError.value = 'Unable to load trip messages. Retry.';
      }
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'listenToMessages',
      );
    }
  }

  void _publishLoadedMessages() {
    final sorted =
        _loadedMessages.values.toList()..sort((a, b) {
          final byTime = a.createdAt.compareTo(b.createdAt);
          return byTime != 0 ? byTime : a.chateId.compareTo(b.chateId);
        });
    messages.value = sorted;
  }

  Future<void> loadEarlierMessages() async {
    final destination = roomId;
    final cursor = lastVisible;
    final uid = GlobalVariables.currentUid;
    final version = _chatOpenVersion;
    if (destination == null ||
        cursor == null ||
        uid.isEmpty ||
        isFetchingMore.value ||
        !hasEarlierMessages.value) {
      return;
    }
    isFetchingMore.value = true;
    earlierMessagesError.value = null;
    try {
      final snapshot =
          await firestore
              .collection(kTripChatCollection)
              .doc(destination)
              .collection(kTripChatMessagesCollection)
              .orderBy('createdAt', descending: true)
              .startAfterDocument(cursor)
              .limit(50)
              .get();
      if (isClosed ||
          roomId != destination ||
          GlobalVariables.currentUid != uid ||
          version != _chatOpenVersion) {
        return;
      }
      for (final doc in snapshot.docs) {
        _loadedMessages[doc.id] = ChatMessage.fromMap(doc.data());
      }
      if (snapshot.docs.isNotEmpty) lastVisible = snapshot.docs.last;
      hasEarlierMessages.value = snapshot.docs.length == 50;
      _publishLoadedMessages();
    } catch (error, stackTrace) {
      if (!isClosed &&
          roomId == destination &&
          GlobalVariables.currentUid == uid &&
          version == _chatOpenVersion) {
        if (error is FirebaseException && error.code == 'permission-denied') {
          _clearOpenChatContent();
          chatOpenError.value =
              'Trip chat is no longer available. Retry to check access.';
        } else {
          earlierMessagesError.value =
              'Unable to load earlier messages. Retry.';
        }
      }
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'loadEarlierMessages',
      );
    } finally {
      if (!isClosed &&
          roomId == destination &&
          GlobalVariables.currentUid == uid &&
          version == _chatOpenVersion) {
        isFetchingMore.value = false;
      }
    }
  }

  Future<void> leaveGroup({String? userId}) async {
    try {
      if (currentTrip.value == null) {
        AppLogger.warning('Cannot leave group: currentTrip is null');
        return;
      }

      final targetUserId = userId ?? GlobalVariables.loggedInUser.value?.uid;
      if (targetUserId == null) {
        AppLogger.error('Cannot leave group: user ID is null');
        return;
      }

      GlobalVariables.showLoader.value = true;
      AppLogger.info(
        'User leaving group: ${currentTrip.value!.id}, userId: $targetUserId',
      );

      final success = await FirebaseTripService.leaveGroup(
        groupId: currentTrip.value!.id,
        userId: targetUserId,
      );

      if (success) {
        // showCustomSnackBar(
        //   content:
        //       userId != null
        //           ? 'Removed successfully!'
        //           : 'You have left the group',
        // );

        currentTrip.value?.joinedUsers?.remove(targetUserId);
        if (currentTrip.value != null) updateTripOverAll(currentTrip.value!);

        if (userId == null) {
          // Current user is leaving
          mainViewController?.selectedIndex.value = 0;
          Get.offAllNamed(kMainViewScreenRoute);
          AppLogger.info(
            'Current user left the group, navigating to main view',
          );
        } else {
          // Removing another user
          currentTrip.refresh();
          AppLogger.info('Successfully removed user from group: $userId');
        }
      } else {
        AppLogger.warning('Failed to leave group');
      }
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'leaveGroup',
      );
    } finally {
      GlobalVariables.showLoader.value = false;
    }
  }
}
