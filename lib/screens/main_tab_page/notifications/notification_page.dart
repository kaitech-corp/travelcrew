import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:travelcrew/blocs/notifications_bloc/notification_bloc.dart';
import 'package:travelcrew/blocs/notifications_bloc/notification_event.dart';
import 'package:travelcrew/blocs/notifications_bloc/notification_state.dart';
import 'package:travelcrew/models/notification_model.dart';
import 'package:travelcrew/screens/alerts/alert_dialogs.dart';
import 'package:travelcrew/services/functions/cloud_functions.dart';
import 'package:travelcrew/services/widgets/loading.dart';

import 'notification_card.dart';

class NotificationPage extends StatefulWidget{

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationBloc bloc;
  
  @override
  void initState() {
    bloc = BlocProvider.of<NotificationBloc>(context);
    bloc.add(LoadingNotificationData());
    super.initState();
  }
  
  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state){
            if(state is NotificationLoadingState){
              return Loading();
            } else if (state is NotificationHasDataState){
              List<NotificationData> notifications = state.data;
              return Container (
                child: ListView.builder(
                    padding: EdgeInsets.all(0.0),
                    itemCount: notifications != null ? notifications.length : 0,
                    itemBuilder: (context, index){
                      var item = notifications[index];

                      return Dismissible(
                        direction: DismissDirection.endToStart,
                        // Show a red background as the item is swiped away.
                        background: Container(color: Colors.red,
                            alignment: AlignmentDirectional.centerStart,
                            child: const Align(
                              alignment: Alignment.centerRight,
                              child: const Icon(Icons.delete,
                                color: Colors.white,),
                            )),
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          setState(() {
                            notifications.removeAt(index);
                            CloudFunction().removeNotificationData(item.fieldID);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Notification removed.")));
                        },

                        child: NotificationsCard(notification: notifications[index],),
                      );
                    }),
              );
            } else {
              return Container();
            }
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TravelCrewAlertDialogs().deleteNotificationsAlert(context);
        },
        child: const Text('Clear All',textAlign: TextAlign.center,),

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class NotificationCount extends StatefulWidget{
  final ValueNotifier<int> notificationCount = ValueNotifier<int>(0);

  NotificationCount();
  @override
  _NotificationCountState createState() => _NotificationCountState();
}
class _NotificationCountState extends State<NotificationCount> {
  @override
  Widget build(BuildContext context) {
    final notifications = Provider.of<List<NotificationData>>(context);

    return ListView.builder(
        itemCount: notifications != null ? notifications.length : 0,
        itemBuilder: (context, index) {
          return NotificationsCard(notification: notifications[index]);
        });
  }

}

