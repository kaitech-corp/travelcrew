import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/notification_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

class NotificationRepository {

  Stream<List<NotificationData>> notificationDataStream() {

    final CollectionReference notificationCollection = FirebaseFirestore.instance.collection('notifications');

    // Get all Notifications
    List<NotificationData> _notificationListFromSnapshot(QuerySnapshot snapshot){

      try {
        return snapshot.docs.map((doc){
          Map<String, dynamic> data = doc.data();
          return NotificationData.fromData(data);
        }).toList();
      } catch (e) {
        CloudFunction().logError('Error retrieving notification list:  ${e.toString()}');
        return null;
      }
    }

    return notificationCollection.doc(userService.currentUserID)
        .collection('notifications').orderBy('timestamp', descending: true)
        .snapshots().map(_notificationListFromSnapshot);
  }
}