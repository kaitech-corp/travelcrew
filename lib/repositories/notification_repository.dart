import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/notification_model.dart';
import '../../../services/database.dart';
import '../../../services/functions/cloud_functions.dart';

class NotificationRepository {
  final CollectionReference notificationCollection = FirebaseFirestore.instance.collection('notifications');

  final _loadedData = StreamController<List<NotificationData>>.broadcast();


  void dispose() {
    _loadedData.close();
  }

  void refresh() {
    // Get all Notifications
    List<NotificationData> _notificationListFromSnapshot(QuerySnapshot snapshot){

      try {
        return snapshot.docs.map((doc){
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return NotificationData.fromData(data);
        }).toList();
      } catch (e) {
        CloudFunction().logError('Error retrieving notification list:  ${e.toString()}');
        return [];
      }
    }

    Stream<List<NotificationData>> notificationList =
    notificationCollection.doc(userService.currentUserID)
        .collection('notifications').orderBy('timestamp', descending: true)
        .snapshots().map(_notificationListFromSnapshot);

    _loadedData.addStream(notificationList);


  }

  Stream<List<NotificationData>> notifications() => _loadedData.stream;

}