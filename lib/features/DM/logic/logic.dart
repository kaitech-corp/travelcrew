    import 'package:cloud_firestore/cloud_firestore.dart';


import '../../../models/chat_model/chat_model.dart';
import '../../../models/public_profile_model/public_profile_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

final CollectionReference<Object?> dmChatCollection =
      FirebaseFirestore.instance.collection('dmChat');
  final CollectionReference<Object?> userPublicProfileCollection =
      FirebaseFirestore.instance.collection('userPublicProfile');  

      const String userID = '';
  /// Add new direct message
  Future<void> addNewDMChatMessage(String displayName, String message,
      String uid, Map<String, dynamic> status) async {
    final String key = dmChatCollection.doc().id;

    final String chatID =
        createChatDoc(userService.currentUserID, uid);

    final DocumentSnapshot<Object?> ref =
        await dmChatCollection.doc(chatID).get();
    if (!ref.exists) {
      await dmChatCollection.doc(chatID).set(<String, dynamic>{
        'ids': <String?>[uid, userService.currentUserID],
        'lastUpdatedTimestamp': FieldValue.serverTimestamp(),
      });
    } else {
      await dmChatCollection.doc(chatID).update(<String, dynamic>{
        'lastUpdatedTimestamp': FieldValue.serverTimestamp(),
      });
    }
    try {
      return await dmChatCollection
          .doc(chatID)
          .collection('messages')
          .doc(key)
          .set(<String, dynamic>{
        'chatID': chatID,
        'displayName': displayName,
        'fieldID': key,
        'message': message,
        'status': status,
        'timestamp': FieldValue.serverTimestamp(),
        'uid': uid,
      });
    } catch (e) {
      CloudFunction().logError('Error writing new dm chat:  $e');
    }
  }

  /// Delete a chat message
  Future<void> deleteDMChatMessage({required ChatModel message}) async {
    /// String chatID = TCFunctions().createChatDoc(userService.currentUserID, userID);
    try {
      return await dmChatCollection
          .doc(message.chatID)
          .collection('messages')
          .doc(message.fieldID)
          .delete();
    } catch (e) {
      CloudFunction().logError('Error deleting dm chat message:  $e');
    }
  }

  /// Clear DM chat notifications.
  Future<void> clearDMChatNotifications(String uid) async {
    try {
      final String chatID =
          createChatDoc(userService.currentUserID, uid);
      final Query<Map<String, dynamic>> db = dmChatCollection
          .doc(chatID)
          .collection('messages')
          .where('status.${userService.currentUserID}', isEqualTo: false);
      final QuerySnapshot<Object?> snapshot = await db.get();
      for (final QueryDocumentSnapshot<Object?> doc in snapshot.docs) {
        dmChatCollection.doc(chatID).collection('messages').doc(doc.id).update(
            <String, dynamic>{'status.${userService.currentUserID}': true});
      }
    } catch (e) {
      CloudFunction().logError('Error clearing dm chat notifications:  $e');
    }
  }

  /// Get all direct message chat messages
  Stream<List<ChatModel>>? get dmChatList {
    try {
      final String chatID =
          createChatDoc(userService.currentUserID, userID!);
      return dmChatCollection
          .doc(chatID)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map(_chatListFromSnapshot);
    } catch (e) {
      CloudFunction().logError('Error retrieving dm chat messages:  $e');
      return null;
    }
  }

  /// Get all chat messages
  List<ChatModel> _chatListFromSnapshot(QuerySnapshot<Object?> snapshot) {
    try {
      return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
        return ChatModel.fromJson(doc as Map<String, Object>);
      }).toList();
    } catch (e) {
      CloudFunction().logError('Error retrieving chat list:  $e');
      return <ChatModel>[];
    }
  }

  Stream<List<ChatModel>>? get dmChatListNotification {
    final String chatID =
        createChatDoc(userService.currentUserID, userID!);
    try {
      return dmChatCollection
          .doc(chatID)
          .collection('messages')
          .where('status.${userService.currentUserID}', isEqualTo: false)
          .snapshots()
          .map(_chatListFromSnapshot);
    } catch (e) {
      CloudFunction().logError('Error retrieving dm chat notifications:  $e');
      return null;
    }
  }

  /// Get user list of DM chats
  Stream<List<UserPublicProfile>> retrieveDMChats() async* {
    final List<String> uidsOfAllChats = <String>[];
    final List<UserPublicProfile> user = await usersList();
    final List<UserPublicProfile> sortedUserList = <UserPublicProfile>[];

    final QuerySnapshot<Object?> ref = await dmChatCollection
        .orderBy('lastUpdatedTimestamp', descending: true)
        .where('ids', arrayContains: userService.currentUserID)
        .get();
    for (final QueryDocumentSnapshot<Object?> doc in ref.docs) {
      uidsOfAllChats.add(doc.id);
    }
    final List<String> idList = <String>[];
    for (final String id in uidsOfAllChats) {
      final List<String> y = id.split('_');
      y.remove(userService.currentUserID);
      idList.add(y[0]);
    }

    for (final String profile in idList) {
      sortedUserList.add(user
          .where((UserPublicProfile element) => profile == element.uid)
          .first);
    }
    yield sortedUserList;
  }

  String createChatDoc(String x, String y) {
    final List<String> userList = <String>[x, y];
    userList.sort();
    final String docID = '${userList[0]}_${userList[1]}';
    return docID;
  }

  ///Get all users Future Builder
  Future<List<UserPublicProfile>> usersList() async {
    try {
      final QuerySnapshot<Object?> ref =
          await userPublicProfileCollection.get();
      final List<UserPublicProfile> userList =
          ref.docs.map((QueryDocumentSnapshot<Object?> doc) {
        // final Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;
        return UserPublicProfile.fromJson(doc as Map<String, Object>);
      }).toList();
      userList.sort((UserPublicProfile a, UserPublicProfile b) =>
          a.displayName.compareTo(b.displayName));
      return userList;
    } catch (e) {
      CloudFunction().logError('Error retrieving all users: $e');
      return <UserPublicProfile>[];
    }
  }

    /// Get Access users for Crew list
  /// Get user list of DM chats
  Stream<List<UserPublicProfile>> getcrewList(List<String> accessUsers) async* {
    try {
      final List<UserPublicProfile> users = await usersList();
      yield users
          .where((UserPublicProfile user) => accessUsers.contains(user.uid))
          .toList();
    } catch (e) {
      CloudFunction().logError('Error in getcrewList for members layout: $e');
    }
  }