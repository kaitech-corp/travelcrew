import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/database.dart';
import '../../../services/functions/cloud_functions/admin_functions.dart';

final CollectionReference<Object?> notificatonCollection = FirebaseFirestore
    .instance
    .collection('notifications')
    .doc(userService.currentUserID)
    .collection('notifications');

Future<void> removeNotificationData(String fieldID) async {
  try {
    await notificatonCollection.doc(fieldID).delete();
  } catch (e) {
    AdminCloudFunction().logError('Error removing notification data: $e');
  }
}
