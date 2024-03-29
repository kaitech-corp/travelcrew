import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/notification_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

class NotificationRepository {
  final CollectionReference<Object> notificationCollection = FirebaseFirestore.instance.collection('notifications');

  final StreamController<List<NotificationData>> _loadedData = StreamController<List<NotificationData>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    // Get all Notifications
    List<NotificationData> notificationListFromSnapshot(QuerySnapshot<Object> snapshot){

      try {
        return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc){
          return NotificationData.fromDocument(doc);
        }).toList();
      } catch (e) {
        CloudFunction().logError('Error retrieving notification list: $e');
        return <NotificationData>[];
      }
    }

    final Stream<List<NotificationData>> notificationList =
    notificationCollection.doc(userService.currentUserID)
        .collection('notifications').orderBy('timestamp', descending: true)
        .snapshots().map(notificationListFromSnapshot);

    _loadedData.addStream(notificationList);


  }

  Stream<List<NotificationData>> notifications() => _loadedData.stream;

}
