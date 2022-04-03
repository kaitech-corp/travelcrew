import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nil/nil.dart';
import 'package:provider/provider.dart';


import '../../../blocs/notification_bloc/notification_bloc.dart';
import '../../../blocs/notification_bloc/notification_event.dart';
import '../../../blocs/notification_bloc/notification_state.dart';
import '../../../models/notification_model.dart';
import '../../../services/functions/cloud_functions.dart';
import '../../../services/widgets/loading.dart';
import '../../alerts/alert_dialogs.dart';
import 'notification_card.dart';

/// Notification page
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
                    padding: const EdgeInsets.all(0.0),
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
              return nil;
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

