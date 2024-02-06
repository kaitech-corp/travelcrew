import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../services/database.dart';
import '../blocs/generics/generic_bloc.dart';
import '../models/notification_model/notification_model.dart';

class NotificationRepository extends GenericBlocRepository<NotificationModel> {
  @override
  Stream<List<NotificationModel>> data() {
    final Query<Object> notificationCollection = FirebaseFirestore.instance
        .collection('notifications')
        .doc(userService.currentUserID)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    List<NotificationModel> notificationListFromSnapshot(
        QuerySnapshot<Object> snapshot) {
      try {
        return snapshot.docs.map((QueryDocumentSnapshot<Object?> doc) {
          return NotificationModel.fromJson(doc.data()! as Map<String, dynamic>);
        }).toList();
      } catch (e) {
        if (kDebugMode) {
          print('Error retrieving notification list: $e');
        }
        return <NotificationModel>[];
      }
    }

    return notificationCollection.snapshots().map(notificationListFromSnapshot);
  }
}
