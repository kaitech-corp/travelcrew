import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../blocs/notification_bloc/notification_bloc.dart';
import '../../../models/notification_model.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/theme/text_styles.dart';
import '../../alerts/alert_dialogs.dart';
import 'notification_card.dart';

/// Notification page
class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key, required this.notifications})
      : super(key: key);

  final List<NotificationData> notifications;

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late NotificationBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Intl.message('Notifications'),style: headlineSmall(context),),
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: widget.notifications.length,
          itemBuilder: (BuildContext context, int index) {
            final NotificationData item = widget.notifications[index];
            return Dismissible(
              direction: DismissDirection.endToStart,
              // Show a red background as the item is swiped away.
              background: Container(
                  color: Colors.red,
                  alignment: AlignmentDirectional.centerStart,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  )),
              key: UniqueKey(),
              onDismissed: (DismissDirection direction) {
                setState(() {
                  widget.notifications.removeAt(index);
                  CloudFunction().removeNotificationData(item.fieldID);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification removed.')));
              },

              child: NotificationsCard(
                notification: widget.notifications[index],
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TravelCrewAlertDialogs().deleteNotificationsAlert(context);
        },
        child: const Text(
          'Clear All',
          textAlign: TextAlign.center,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class NotificationCount extends StatefulWidget {
  NotificationCount({Key? key}) : super(key: key);
  final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);
  @override
  State<NotificationCount> createState() => _NotificationCountState();
}

class _NotificationCountState extends State<NotificationCount> {
  @override
  Widget build(BuildContext context) {
    final List<NotificationData> notifications =
        Provider.of<List<NotificationData>>(context);

    return ListView.builder(
        itemCount: notifications != null ? notifications.length : 0,
        itemBuilder: (BuildContext context, int index) {
          return NotificationsCard(notification: notifications[index]);
        });
  }
}
