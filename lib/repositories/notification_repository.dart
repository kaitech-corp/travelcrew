import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';
import '../models/notification_model/notification_model.dart';

class NotificationRepository {
  final CollectionReference<Object> notificationCollection = FirebaseFirestore.instance.collection('notifications');

  final StreamController<List<NotificationModel>> _loadedData = StreamController<List<NotificationModel>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    // Get all Notifications
    List<NotificationModel> notificationListFromSnapshot(QuerySnapshot<Object> snapshot){

      try {
        return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
          return NotificationModel.fromJson(doc as Map<String, Object>);
        }).toList();
      } catch (e) {
        CloudFunction().logError('Error retrieving notification list: $e');
        return <NotificationModel>[];
      }
    }

    final Stream<List<NotificationModel>> notificationList =
    notificationCollection.doc(userService.currentUserID)
        .collection('notifications').orderBy('timestamp', descending: true)
        .snapshots().map(notificationListFromSnapshot);

    _loadedData.addStream(notificationList);


  }

  Stream<List<NotificationModel>> notifications() => _loadedData.stream;

}
