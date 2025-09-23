import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:travel_crew/main.dart';
import 'package:travel_crew/models/Notifications/user_notification_model.dart';
import 'package:travel_crew/models/chat_module/chat_message.dart';
import 'package:travel_crew/models/chat_module/chat_user.dart';
import 'package:travel_crew/models/chat_module/chatroom.dart';
import 'package:travel_crew/models/public_user_model.dart';
import 'package:travel_crew/models/trip_model.dart';
import 'package:travel_crew/services/auth_service.dart';
import 'package:travel_crew/services/firebase_trip_service.dart';
import 'package:travel_crew/services/notifications/notifications_firebase_service.dart';
import 'package:travel_crew/services/session_services.dart';
import 'package:travel_crew/services/trips_changes.dart';
import 'package:travel_crew/utils/app_strings.dart';
import 'package:travel_crew/utils/custom_snackbar.dart';
import 'package:travel_crew/utils/error_handler.dart';
import 'package:travel_crew/utils/logger.dart';

import '../../../../services/chat_firebase_service.dart';

class UsersController extends GetxController {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> groupDetailKey = GlobalKey<ScaffoldState>();
  Rxn<TripModel?> currentTrip = Rxn<TripModel>();
  RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  RxBool isLoadingChats = false.obs;
  String? roomId;
  Rxn<ChatRoom> chatRoom = Rxn<ChatRoom>();
  Rxn<Map<String, dynamic>> aiModel = Rxn<Map<String, dynamic>>();
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? roomListner;
  DocumentSnapshot? lastVisible;
  bool isFetchingMore = false;

  RxBool isLoading = false.obs;
  RxList<PublicUserModel> tripUsers = <PublicUserModel>[].obs;
  RxBool isLoadingUsers = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load chat rooms when controller is initialized
    loadChatRooms();
  }
  Future<void> getUsersDetail() async {
    try {
      tripUsers.value = [];
      if (currentTrip.value == null ||
          (currentTrip.value!.joinedUsers?.toList() ?? []).isEmpty) {
        AppLogger.info('No trip or joined users found for getUsersDetail');
        return;
      }

      isLoadingUsers.value = true;
      AppLogger.debug('Getting user details for ${currentTrip.value!.joinedUsers?.length} users');

      final res = await AuthService.getTripUsers(
        userIds: currentTrip.value!.joinedUsers?.toList() ?? [],
      );

      tripUsers.value = res;
      AppLogger.info('Successfully loaded ${res.length} trip users');
    } catch (error, stackTrace) {
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: 'getUsersDetail',
      );
    } finally {
      isLoadingUsers.value = false;
    }
  }

  /// Load chat rooms for the current user
  Future<void> loadChatRooms() async {
    try {
      final currentUser = GlobalVariables.loggedInUser.value;
      if (currentUser == null) {
        AppLogger.warning('Cannot load chat rooms: user not logged in');
        return;
      }

      isLoadingChats.value = true;
      AppLogger.debug('Loading chat rooms for user: ${currentUser.uid}');

      final rooms = await ChatFirebaseService.getChatRoomsByUserId(
        userId: currentUser.uid,
      );

      chatRooms.value = rooms;
      AppLogger.info('Successfully loaded ${rooms.length} chat rooms');
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'loadChatRooms',
      );
    } finally {
      isLoadingChats.value = false;
    }
  }

  

  Future<void> listenToChat() async {
    try {
      // Clean up existing listeners to prevent memory leaks
      await _cleanupListeners();
      
      isLoadingChats.value = true;
      roomId = currentTrip.value?.id;
      
      if (roomId == null) {
        AppLogger.warning('Cannot listen to chat: roomId is null');
        return;
      }
      
      AppLogger.debug('Starting to listen to chat room: $roomId');
      
      final res = await ChatFirebaseService.checkIfRoomExists(roomId: roomId!);
      chatRoom.value = res;
      
      if (res == null) {
        AppLogger.info('Chat room does not exist, creating new room');
        final bool created = await createChatRoom();
        if (!created) {
          AppLogger.error('Failed to create chat room');
          return;
        }
      }
      
      listenToMessages(roomId!);
      listenToCollection(roomId: roomId!);
      AppLogger.info('Successfully started listening to chat room: $roomId');
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'listenToChat',
      );
    } finally {
      isLoadingChats.value = false;
    }
  }

  /// Clean up existing listeners to prevent memory leaks
  Future<void> _cleanupListeners() async {
    await roomListner?.cancel();
    await messageListener?.cancel();
    roomListner = null;
    messageListener = null;
    AppLogger.debug('Cleaned up existing chat listeners');
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

      // Check if user is already in the chatroom
      final isUserAlreadyInTrip = currentTrip.value?.joinedUsers?.contains(currentUser.uid) ?? false;

      if (chatRoom.value!.containsUser(currentUser.uid) && isUserAlreadyInTrip) {
        AppLogger.info('User ${currentUser.uid} is already in the chatroom: $roomId');
        showCustomSnackBar(content: 'You are already in this chat room');
        return;
      }

      // Safely add user to chatroom using the helper method
      final userAddedToChat = chatRoom.value!.addUserSafely(
        ChatUser(
          id: currentUser.uid,
          unreadedMessages: 0,
          lastActive: Timestamp.now(),
          name: currentUser.displayName ?? '',
          profileImage: GlobalVariables.userProfile.value?.profileImage ?? '',
          isOnline: true,
          isTyping: false,
        ),
      );

      if (userAddedToChat) {
        AppLogger.debug('Added user to chat room successfully');
      } else {
        AppLogger.debug('User was already in chat room');
      }

      // Add user to trip joinedUsers only if not already present
      if (!isUserAlreadyInTrip) {
        currentTrip.value?.joinedUsers?.add(currentUser.uid);
        AppLogger.debug('Added user to trip joinedUsers list');
      }
      
      if (currentTrip.value != null) updateTripOverAll(currentTrip.value!);
      chatRoom.refresh();
      
      // Send notification
      FirebaseNotificationsService.saveNotifications(
        message: '${currentUser.displayName} joined your trip.',
        title: 'Trip Joined',
        sentTo: [currentTrip.value!.createdBy],
        notificationForId: currentTrip.value!.id,
        notificationType: NotificationType.trip.status,
      );
      
      await ChatFirebaseService.updateChatRoom(
        roomId: roomId!,
        chatToSave: chatRoom.value!,
      );
      
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
        AppLogger.debug('Setting up room listener for: $roomId');
        final res = firestore
            .collection(kTripChatCollection)
            .doc(roomId);
            
        roomListner = res.snapshots().listen(
          (event) {
            try {
              if (event.exists && event.data() != null) {
                chatRoom.value = ChatRoom.fromMap(event.data()!);
                AppLogger.debug('Updated chat room data from listener');
              }
            } catch (error, stackTrace) {
              ErrorHandler.handleError(
                error,
                stackTrace: stackTrace,
                context: 'listenToCollection - data parsing',
              );
            }
          },
          onError: (error) {
            ErrorHandler.handleFirebaseError(
              error as Object,
              operation: 'listenToCollection - stream',
            );
          },
        );
      }
    } catch (error, stackTrace) {
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

      chatRoom.value = ChatRoom(
        usersIds: [currentUser.uid],
        updatedAt: Timestamp.now(),
        roomId: roomId!,
        users: [
          ChatUser(
            id: currentUser.uid,
            unreadedMessages: 0,
            lastActive: Timestamp.now(),
            name: currentUser.displayName ?? '',
            profileImage: GlobalVariables.userProfile.value?.profileImage ?? '',
            isOnline: true,
            isTyping: false,
          ),
        ],
      );

      await ChatFirebaseService.createChatRoom(chatroom: chatRoom.value!);
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

  Future<void> saveMessage({required ChatMessage chatToSave}) async {
    try {
      if (roomId == null) {
        AppLogger.error('Cannot save message: roomId is null');
        return;
      }

      AppLogger.debug('Saving message in room: $roomId');
      
      // Add message to local list for immediate UI update
      messages.add(chatToSave);
      scrollToEnd();
      
      // Send message to Firebase
      await ChatFirebaseService.sendMessage(
        chatToSave: chatToSave, 
        roomId: roomId!,
      );
      
      AppLogger.info('Successfully saved message to room: $roomId');
    } catch (error, stackTrace) {
      // Remove message from local list if sending failed
      messages.removeWhere((msg) => msg.chateId == chatToSave.chateId);
      
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'saveMessage',
      );
    }
  }

  TextEditingController tecMessage = TextEditingController();

  FocusNode fnMessage = FocusNode();

  RxBool showTextField = false.obs;
  Future<void> scrollToEnd() async {
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  ScrollController scrollController = ScrollController();
  RxList<ChatMessage> messages = <ChatMessage>[].obs;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? messageListener;


  @override
  void onClose() {
    roomListner?.cancel();
    messageListener?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  void listenToMessages(String roomId) {
    try {
      AppLogger.debug('Setting up message listener for room: $roomId');
      
      messageListener = firestore
          .collection(kTripChatCollection)
          .doc(roomId)
          .collection(kTripChatMessagesCollection)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen(
            (event) {
              try {
                if (event.docs.isNotEmpty) {
                  final newMessages = event.docs
                      .map((e) => ChatMessage.fromMap(e.data()))
                      .toList()
                      .reversed
                      .toList();
                  
                  messages.value = newMessages;
                  scrollToEnd();
                  AppLogger.debug('Updated ${newMessages.length} messages from listener');
                }
              } catch (error, stackTrace) {
                ErrorHandler.handleError(
                  error,
                  stackTrace: stackTrace,
                  context: 'listenToMessages - data parsing',
                );
              }
            },
            onError: (error) {
              ErrorHandler.handleFirebaseError(
                error as Object,
                operation: 'listenToMessages - stream',
              );
            },
          );
    } catch (error, stackTrace) {
      ErrorHandler.handleFirebaseError(
        error,
        stackTrace: stackTrace,
        operation: 'listenToMessages',
      );
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
      AppLogger.info('User leaving group: ${currentTrip.value!.id}, userId: $targetUserId');

      final success = await FirebaseTripService.leaveGroup(
        groupId: currentTrip.value!.id,
        userId: targetUserId,
      );

      if (success) {
        showCustomSnackBar(
          content: userId != null
              ? 'Removed successfully!'
              : 'You have left the group',
        );
        
        currentTrip.value?.joinedUsers?.remove(targetUserId);
        if (currentTrip.value != null) updateTripOverAll(currentTrip.value!);
        
        if (userId == null) {
          // Current user is leaving
          mainViewController?.selectedIndex.value = 0;
          Get.offAllNamed(kMainViewScreenRoute);
          AppLogger.info('Current user left the group, navigating to main view');
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
